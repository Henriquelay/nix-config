# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true; # Turn on with computer
  };

  ## Graphics
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;

    extraPackages = with pkgs; [
      rocmPackages.clr.icd # OpenCL
    ];
  };
  # Workaround for HIP libraries
  systemd.tmpfiles.rules = let
    rocmEnv = pkgs.symlinkJoin {
      name = "rocm-combined";
      paths = with pkgs.rocmPackages; [
        rocblas
        hipblas
        clr
      ];
    };
  in [
    "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
  ];

  ## System/nix options
  # Reducing disk usage
  nix = {
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 2w";
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      trusted-users = [
        "root"
        "henriquelay"
      ];
    };
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Bootloader.
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        memtest86.enable = true;
      };
      efi.canTouchEfiVariables = true;
      # Limit the number of generations to keep
      systemd-boot.configurationLimit = 20;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  virtualisation = {
    libvirtd.enable = true;
    docker.enable = true;
  };

  ## Networking
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking = {
    hostName = "acad-router";
    nameservers = [
      "192.168.3.100"
      #"9.9.9.9"
    ];
    #networkmanager.enable = true;
    hosts = {
      "192.168.3.100" = ["netbook"];
    };
    stevenblack.enable = true;

    # WIFI
    wireless.networks = {
      "SEM INTERNET_5G".pskRaw = "6e460263308866cef1a01596c15630978dbae65cdae0baac75c339899dfea2c9";
      "SEM INTERNET".pskRaw = "2186a3307702e4946184ea36295cf2f55a11343f7fd0c9f214356f4bb4489d6b";
    };
  };

  ## TZ and Locale
  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = let
      locale = "pt_BR.UTF-8";
    in {
      LC_ADDRESS = locale;
      LC_IDENTIFICATION = locale;
      LC_MEASUREMENT = locale;
      LC_MONETARY = locale;
      LC_NAME = locale;
      LC_NUMERIC = locale;
      LC_PAPER = locale;
      LC_TELEPHONE = locale;
      LC_TIME = locale;
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  ## Users
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.henriquelay = {
    isNormalUser = true;
    description = "henriquelay";
    extraGroups = ["networkmanager" "wheel" "libvirtd" "gamemode" "docker"];
    shell = pkgs.fish;
  };
  home-manager.users.henriquelay = import henriquelay/home.nix {
    inherit config;
    inherit pkgs;
  };

  security.sudo.extraRules = [
    {
      users = ["henriquelay"];
      commands = [
        {
          # Allow me to sudo without passwd
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  ## Requirement for some home-manager programs, mostly security related
  security.pam.services.hyprlock = {};
  security.polkit.enable = true; # For Sway
  # needed for store VS Code auth token
  services.gnome.gnome-keyring.enable = true;

  # Enable automatic login for a user.
  # services.getty.autologinUser = "henriquelay";

  ## Some system-level programs
  # List packages installed in system profile. To search, run:
  # $ nix search wget

  environment.systemPackages = with pkgs; [
    helix
    wget
  ];
  programs = {
    fish.enable = true;
    hyprland.enable = true;
    virt-manager.enable = true;

    gamemode.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };

    appimage.binfmt = true;
  };

  environment.variables = {
    NIX_BUILD_CORES = 12;
    EDITOR = "hx";
    # Force usage of RADV (Mesa) Vulkan implementation
    AMD_VULKAN_ICD = "RADV";
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    (nerdfonts.override {fonts = ["FiraCode" "DroidSansMono"];})
  ];

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  ## Sound
  # Remove sound.enable or set it to false if you had it set previously, as sound.enable is only meant for ALSA-based configurations
  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
    image = ./henriquelay/blackpx.jpg; # only for i3
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
