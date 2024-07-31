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
    <home-manager/nixos>
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = false; # powers up the default Bluetooth controller

  hardware.opengl = {
    enable = true;
    driSupport = true;
    # package = pkgs.mesa.drivers;

    driSupport32Bit = true;
    # package32 = pkgs.pkgsi686Linux.mesa.drivers;

    # Mesa RADV will be used as default. Proprietary drivers will be provided too and program will choose which to use
    # extraPackages = with pkgs; [amdvlk libvdpau-va-gl ];
    # extraPackages32 = with pkgs.driversi686Linux; [amdvlk libvdpau-va-gl];

    # package = (pkgs.mesa.override {galliumDrivers = ["i915" "swrast" "radeonsi"];}).drivers;
  };

  # unstable (>24.05)
  # hardware.graphics = {
  #   enable = true;
  #   package = pkgs.hyprland-pkgs.mesa.drivers;
  #   enable32Bit = true;
  #   package32 = pkgs.hyprland-pkgs.pkgsi686Linux.mesa.drivers;

  #   # extraPackages = with pkgs; [mesa.drivers amdvlk libvdpau-va-gl];
  #   # extraPackages32 = with pkgs.driversi686Linux; [mesa.drivers amdvlk libvdpau-va-gl];
  # };

  # Reducing disk usage
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 2w";
  };
  nix.settings.auto-optimise-store = true;

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    # substituters = ["https://hyprland.cachix.org"];
    # trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    trusted-users = [
      "root"
      "henriquelay"
    ];
  };

  # Bootloader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      # Limit the number of generations to keep
      systemd-boot.configurationLimit = 10;
    };
    # kernelPackages = pkgs.hyprland-pkgs.linuxPackages_latest;
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;

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
    #wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    #networkmanager.enable = true;
    hosts = {
      "192.168.3.100" = ["netbook"];
    };
    stevenblack.enable = true;
  };

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = let
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

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    windowManager.i3.enable = true;
    # videoDrivers = ["amdgpu"];
    xkb = {
      layout = "br";
      variant = "";
    };
  };
  services.displayManager = {
    defaultSession = "none+i3";
  };
  # needed for store VS Code auth token
  services.gnome.gnome-keyring.enable = true;

  # Configure console keymap
  console.keyMap = "br-abnt2";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.henriquelay = {
    isNormalUser = true;
    description = "henriquelay";
    extraGroups = ["networkmanager" "wheel" "libvirtd" "gamemode" "docker"];
    shell = pkgs.fish;
  };
  home-manager.users.henriquelay = import ../henriquelay/home.nix {
    inherit pkgs;
    inherit config;
  };

  security.pam.services.hyprlock = {};
  security.polkit.enable = true; # For Sway

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

  # Enable automatic login for the user.
  # services.getty.autologinUser = "henriquelay";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    helix
    wget
    fish
  ];

  environment.variables = {
    NIX_BUILD_CORES = 12;
    EDITOR = "hx";
    # Force use of RADV (Mesa) Vulkan implementation
    AMD_VULKAN_ICD = "RADV";
  };

  programs = {
    fish.enable = true;
    hyprland = {
      enable = true;
      # package = pkgs.hyprland.hyprland;
    };
    virt-manager.enable = true;

    gamemode.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };

    appimage.binfmt = true;
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
    image = /home/henriquelay/nix-config/henriquelay/blackpx.jpg; # only for i3
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
