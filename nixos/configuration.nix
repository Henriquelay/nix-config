# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  config,
  pkgs,
  ...
}: let
  pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    #<home-manager/nixos> # Not using home-manager as module
  ];

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = false; # powers up the default Bluetooth controller

  hardware.opengl = {
    enable = true;
    # radv: an open-source Vulkan driver from freedesktop (MESA)
    driSupport = true;
    driSupport32Bit = true;

    # Mesa from hyprland's unstable pkgs
    #package32 = pkgs-unstable.pkgsi686Linux.mesa.drivers;
    #package = pkgs-unstable.mesa.drivers;

    #extraPackages = with pkgs; [
    #  # amdvlk: an open-source Vulkan driver from AMD, usually performs worse than RADV
    #  amdvlk
    #  rocm-opencl-icd # OpenCL
    #  rocm-opencl-runtime # OpenCL
    #];
    #extraPackages32 = with pkgs; [
    #  driversi686Linux.amdvlk
    #];
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  programs.virt-manager.enable = true;

  # Reducing disk usage
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    trusted-users = [
      "root"
      "henriquelay"
    ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Limit the number of generations to keep
  boot.loader.systemd-boot.configurationLimit = 10;

  boot.initrd.luks.devices."luks-c258bf9d-345e-4140-a345-58465ed6370f".device = "/dev/disk/by-uuid/c258bf9d-345e-4140-a345-58465ed6370f";

  networking.hostName = "acad-router"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.nameservers = [
    #"192.168.3.100"
    "9.9.9.9"
  ];

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "br";
    variant = "";
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
    packages = with pkgs; [home-manager];
  };

  security.sudo.extraRules = [
    {
      users = ["henriquelay"];
      commands = [
        {
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
    # Force use of RADV Vulkan implementation
    AMD_VULKAN_ICD = "RADV";
  };

  programs = {
    fish.enable = true;
    hyprland = {
      enable = true;
      #package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    };

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
  system.stateVersion = "24.11"; # Did you read the comment?
}
