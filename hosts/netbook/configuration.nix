# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking = {
    wireless.enable = false;
    hostName = "netbook";
    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networkmanager
    #networkmanager.enable = true;
    nameservers = [
      "9.9.9.9" "8.8.8.8" "8.8.4.4" "1.1.1.1"
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

  services.zerotierone = {
    enable = true;
    joinNetworks = [
      "ebe7fbd445ee2222"
    ];
  };


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
  services.xserver = {
    layout = "br";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.henriquelay = {
    isNormalUser = true;
    description = "henrique";
    extraGroups = [ "networkmanager" "wheel" "docker"];
    packages = with pkgs; [
      exa bat 
    ];
  };
  users.users.Thales = {
    isNormalUser = true;
    description = "Thales";
    extraGroups = [ "networkmanager" "wheel" "docker"];
    packages = with pkgs; [
      exa bat 
    ];
  };
  # Set default user shell
  users.defaultUserShell = pkgs.fish;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget helix fish trash-cli man-pages bottom qbittorrent-nox monero-cli
  ];

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
      qbittorrent-nox = {
        enable = false;
        description = "qBittorrent-nox service for user henriquelay";
        documentation = ["man:qbittorent-nox(1)"];
        wants = ["network-online.target"];
        after = ["local-fs.target" "network-online.target" "nss-lookup.target"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Type = "simple";
          PrivateTmp = false;
          User = "henriquelay";
          ExecStart = "/nix/store/62pzilri2vzq82ggkm47zr7801q356v4-qbittorrent-nox-4.5.2/bin/qbittorrent-nox";
        };
      };
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.fish.enable = true;

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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  # Enable Docker support
  virtualisation.docker.enable = true;

  # Disable sleep on lid close
  services.logind.lidSwitchExternalPower = "ignore";
}
