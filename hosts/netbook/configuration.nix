# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  nix = {
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
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
    };
  };

  networking = {
    nftables.enable = config.virtualisation.incus.enable; # Only for Incus
    firewall.interfaces.incusbr0.allowedTCPPorts = [
      53
      67
    ];
    firewall.interfaces.incusbr0.allowedUDPPorts = [
      53
      67
    ];
    firewall.enable = false;

    wireless.enable = false;
    hostName = "netbook";
    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networkmanager
    #networkmanager.enable = true;
    nameservers = [
      "9.9.9.9"
      "8.8.8.8"
      "8.8.4.4"
      "1.1.1.1"
    ];
    defaultGateway = {
      address = "192.168.3.1";
      interface = "enp1s0";
    };
    interfaces = {
      enp1s0.ipv4.addresses = [
        {
          address = "192.168.3.100";
          prefixLength = 24;
        }
      ];
    };
  };

  services = {
    zerotierone = {
      enable = true;
      joinNetworks = [
        "ebe7fbd445ee2222"
      ];
    };
    # Disable sleep on lid close
    logind.lidSwitchExternalPower = "ignore";

    copyparty = {
      enable = true;
      settings = {
        i = "0.0.0.0";
        p = [
          80
          443
        ];
      };
      accounts = {
        # provide the path to a file containing the password, keeping it out of /nix/store
        # must be readable by the copyparty service user
        henriquelay.passwordFile = "/run/keys/copyparty/henriquelay_password";
        bruna.passwordFile = "/run/keys/copyparty/bruna_password";
      };

      # create a volume
      volumes = {
        # create a volume at "/" (the webroot), which will
        "/" = {
          # share the contents of "/srv/copyparty"
          path = "/srv/copyparty";
          # see `copyparty --help-accounts` for available options
          access = {
            r = "*";
            rw = [
              "henriquelay"
              "bruna"
            ];
          };
          # see `copyparty --help-flags` for available options
          flags = {
            # "fk" enables filekeys (necessary for upget permission) (4 chars long)
            fk = 4;
            # scan for new files every 60sec
            scan = 60;
            # volflag "e2d" enables the uploads database
            e2d = true;
            # "d2t" disables multimedia parsers (in case the uploads are malicious)
            d2t = false;
            # skips hashing file contents if path matches *.iso
            nohash = "\.iso$";
          };
        };
      };
      # you may increase the open file limit for the process
      openFilesLimit = 8192;
    };
  };

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
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
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    defaultUserShell = pkgs.fish;
    users.henriquelay = {
      isNormalUser = true;
      description = "henrique";
      initialPassword = "install";
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
      ];
      packages = with pkgs; [
        eza
        bat
      ];
    };
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    helix
    trash-cli
    man-pages
    bottom
    git
  ];

  boot.loader = {
    # systemd-boot = {
    #   # It is so old and weak it uses legacy boot
    #   enable = false;
    #   memtest86.enable = true;
    #   configurationLimit = 0;
    #   editor = false;
    # };
    timeout = 5;
    grub = {
      enable = true;
      device = "nodev"; # Let disko handle the device specification
      efiSupport = false;
    };
    # efi.canTouchEfiVariables = false;
  };

  # Custom services for pkgs that don't declare them
  systemd = {
    timers = {
      duckdns = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "5m";
          OnUnitActiveSec = "5m";
          Unit = "hello-world.service";
        };
      };
    };
    services = {
      duckdns = {
        script = ''
          bash -c 'echo url="https://www.duckdns.org/update?domains=damnorangecat&token=23c93e96-9e49-4706-bf7d-dec50098ac4e&ip=" | curl -k -o ~/duckdns/duck.log -K -'
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      };
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    fish.enable = true;
  };

  # List services that you want to enable:

  services = {
    openssh = {
      enable = true;
      # require public key authentication for better security
      settings.PasswordAuthentication = true;
      settings.KbdInteractiveAuthentication = false;
      #settings.PermitRootLogin = "yes";
    };
  };
  security.sudo.wheelNeedsPassword = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  # Enable Docker support
  virtualisation = {
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

}
