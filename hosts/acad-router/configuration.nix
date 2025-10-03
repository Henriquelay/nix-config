{
  #lib,
  #inputs,
  config,
  pkgs,
  nur,
  helix-flake,
  ...
}:
{
  # services.logrotate.checkConfig = false;
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  hardware = {
    keyboard.qmk.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true; # Turn on with computer
    };
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        # rocmPackages.clr.icd # OpenCL
      ];
    };
    amdgpu = {
      initrd.enable = true;
      overdrive.enable = true;
    };
  };
  # GPU Controller
  services.lact.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  # Workaround for HIP libraries
  # https://wiki.nixos.org/wiki/AMD_GPU#HIP
  # systemd.tmpfiles.rules =
  #   let
  #     rocmEnv = pkgs.symlinkJoin {
  #       name = "rocm-combined";
  #       paths = with pkgs.rocmPackages; [
  #         rocblas
  #         hipblas
  #         clr
  #       ];
  #     };
  #   in
  #   [
  #     "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
  #   ];

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
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "henriquelay"
      ];
      # Hyprland cachix
      # substituters = [ "https://hyprland.cachix.org" ];
      # trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
  };
  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };

  # Bootloader.
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        memtest86.enable = true;
      };
      efi.canTouchEfiVariables = true;
      # Limit the number of generations to keep
      systemd-boot.configurationLimit = 10;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  virtualisation = {
    libvirtd.enable = true;
    docker.enable = true;
    incus = {
      enable = true;
      preseed = {
        networks = [
          {
            config = {
              "ipv4.address" = "10.0.100.1/24";
              "ipv4.nat" = "true";
            };
            name = "incusbr0";
            type = "bridge";
          }
        ];
        profiles = [
          {
            devices = {
              eth0 = {
                name = "eth0";
                network = "incusbr0";
                type = "nic";
              };
              root = {
                path = "/";
                pool = "default";
                size = "35GiB";
                type = "disk";
              };
            };
            name = "default";
          }
        ];
        storage_pools = [
          {
            config = {
              source = "/var/lib/incus/storage-pools/default";
            };
            driver = "dir";
            name = "default";
          }
        ];
      };

    };
  };

  ## Networking
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking = {
    nftables.enable = config.virtualisation.incus.enable; # Only for Incus
    firewall = {
      interfaces.incusbr0 = {
        allowedTCPPorts = [
          53
          67
        ];
        allowedUDPPorts = [
          53
          67
        ];
      };
      allowedTCPPorts = [
        23253 # bg3
      ];
      allowedUDPPorts = [
        23253 # bg3
      ];
    };

    hostName = "acad-router";
    nameservers = [
      "192.168.3.100"
      # "9.9.9.9"
    ];
    #networkmanager.enable = true;
    hosts = {
      "192.168.3.100" = [ "netbook" ];
    };
    stevenblack.enable = true;

    # WIFI
    wireless = {
      enable = true;
      networks = {
        # Not highly-sensitive information
        "SEM INTERNET_5G".pskRaw = "6e460263308866cef1a01596c15630978dbae65cdae0baac75c339899dfea2c9";
        "SEM INTERNET".pskRaw = "2186a3307702e4946184ea36295cf2f55a11343f7fd0c9f214356f4bb4489d6b";
        "henrique hotspot".psk = "henrique";
      };
    };

  };

  services.xserver = {
    enable = false;
    xkb.extraLayouts.abnt2colemak = {
      description = "Brazilian ABNT2 Colemak";
      languages = [ "por" ];
      symbolsFile = pkgs.writeText "abnt2colemak" ''
        default partial alphanumeric_keys
        xkb_symbols "basic" {
            include "br(abnt2)"
            name[Group1] = "Brazilian ABNT2 Colemak";

            // Colemak remapping - top row
            key <AD01> { [ q, Q ] };
            key <AD02> { [ w, W ] };
            key <AD03> { [ f, F ] };
            key <AD04> { [ p, P ] };
            key <AD05> { [ g, G ] };
            key <AD06> { [ j, J ] };
            key <AD07> { [ l, L ] };
            key <AD08> { [ u, U ] };
            key <AD09> { [ y, Y ] };
            key <AD10> { [ ccedilla, Ccedilla ] };

            // Colemak remapping - home row
            key <AC01> { [ a, A ] };
            key <AC02> { [ r, R ] };
            key <AC03> { [ s, S ] };
            key <AC04> { [ t, T ] };
            key <AC05> { [ d, D ] };
            key <AC06> { [ h, H ] };
            key <AC07> { [ n, N ] };
            key <AC08> { [ e, E ] };
            key <AC09> { [ i, I ] };
            key <AC10> { [ o, O ] };

            // Colemak remapping - bottom row
            key <AB01> { [ z, Z ] };
            key <AB02> { [ x, X ] };
            key <AB03> { [ c, C ] };
            key <AB04> { [ v, V ] };
            key <AB05> { [ b, B ] };
            key <AB06> { [ k, K ] };
            key <AB07> { [ m, M ] };
        };
      '';
    };
  };

  time.timeZone = "America/Sao_Paulo";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings =
      let
        locale = "pt_BR.UTF-8";
      in
      {
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

  console.keyMap = "br-abnt2";

  users.users.henriquelay = {
    isNormalUser = true;
    description = "henriquelay";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "gamemode"
      "docker"
      "incus-admin"
      "audio"
      # "rtkit"
      # config.services.kubo.group
    ];
    shell = pkgs.fish;
  };
  # Home manager
  home-manager = {
    backupFileExtension = "hmbackup";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit nur helix-flake; }; # Pass flakes to home-manager modules
    users.henriquelay = {
      imports = [ ./henriquelay/home.nix ];
    };
  };

  ## Users
  # Define a user account. Don't forget to set a password with ‘passwd’.
  security = {
    sudo.extraRules = [
      {
        users = [ "henriquelay" ];
        commands = [
          {
            # Allow me to sudo without passwd
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    ## Requirement for some home-manager programs, mostly security related
    # security.pam.services.hyprlock = { };

    # domain = "@audio": This specifies that the limits apply to users in the @audio group.
    # item = "memlock": Controls the amount of memory that can be locked into RAM.
    # value (`unlimited`) allows members of the @audio group to lock as much memory as needed. This is crucial for audio processing to avoid swapping and ensure low latency.
    #
    # item = "rtprio": Controls the real-time priority that can be assigned to processes.
    # value (`99`) is the highest real-time priority level. This setting allows audio applications to run with real-time scheduling, reducing latency and ensuring smoother performance.
    #
    # pam.loginLimits = [
    #   {
    #     domain = "@audio";
    #     item = "memlock";
    #     type = "-";
    #     value = "unlimited";
    #   }
    #   {
    #     domain = "@audio";
    #     item = "rtprio";
    #     type = "-";
    #     value = "99";
    #   }
    # ];
    polkit.enable = true; # For Sway
  };

  environment = {
    systemPackages = with pkgs; [
      helix
      wget
      # rtaudio # for Rocksmith
      vial
    ];
    variables = {
      NIX_BUILD_CORES = 12;
      EDITOR = "hx";
      # Force usage of RADV (Mesa) Vulkan implementation
      AMD_VULKAN_ICD = "RADV";
    };
  };

  qt.enable = true;

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    fish.enable = true;
    hyprland.enable = false;
    virt-manager.enable = false;
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        libsForQt5.quazip
        libsForQt5.qt5.qtbase
        libsForQt5.qt5.qtwayland
      ];
    };
    gamemode.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      package = pkgs.steam.override {
        extraLibraries = pkgs: [ pkgs.pkgsi686Linux.pipewire.jack ]; # Adds pipewire jack (32-bit)
        extraPkgs = pkgs: [ pkgs.wineasio ]; # Adds wineasio
      };
    };
    appimage = {
      enable = true;
      binfmt = true;
    };
    #droidcam.enable = true;
  };

  services = {
    udev.packages = with pkgs; [ vial ];
    dbus.implementation = "broker";
    zerotierone = {
      enable = true;
      joinNetworks = [
        # Not highly-sensitive information
        "ebe7fbd445ee2222"
      ];
    };

    # auto-mounting service
    udisks2.enable = true;
    # for storing VS Code auth token
    gnome.gnome-keyring.enable = true;
    sunshine = {
      enable = false;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };

    # ipfs server
    kubo = {
      enable = false;
      dataDir = "/vault/ipfs";
      enableGC = true;
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
      # jack.enable = true;
    };
    # ucodenix = {
    #   enable = true;
    #    cpuModelId = "00A60F12"; # Can be set to "auto", but then build won't be reproducible
    # };
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    font-awesome
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  # For realtime audio
  security.rtkit.enable = true;
  ## Extra
  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark.yaml";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
