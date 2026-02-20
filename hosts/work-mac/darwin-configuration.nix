{
  pkgs,
  lib,
  helix-flake,
  ...
}:
let
  username = "henriquelay";
in
{
  # System-level macOS configuration

  # Basic Nix settings
  nix = {
    enable = false;
    settings.experimental-features = "nix-command flakes";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # macOS system packages (if any)
  environment.systemPackages = with pkgs; [
    terraform
    awscli2
    (python313.withPackages (
      pypkgs: with pypkgs; [
        boto3
        requests-aws4auth
        opensearch-py
        aioboto3
        aiohttp
        python-dateutil
      ]
    ))
  ];

  # Enable fish shell system-wide
  programs.fish.enable = true;

  # Home-manager integration
  home-manager = {
    backupFileExtension = "hmbackup";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit helix-flake;
    };
    users.${username} = {
      imports = [ ./henriquelay/home.nix ];
    };
  };

  # Enable sudo with Touch ID
  security.pam.services.sudo_local.touchIdAuth = true;

  # Enable SSH (Remote Login)
  system.activationScripts.postActivation.text = ''
    launchctl load -w /System/Library/LaunchDaemons/ssh.plist 2>/dev/null || true
  '';

  # macOS system settings (examples - adjust to your preferences)
  system = {
    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
      };
      dock = {
        autohide = true;
        show-recents = false;
      };
      finder = {
        AppleShowAllExtensions = true;
        ShowPathbar = true;
      };
    };
    stateVersion = 5;
    primaryUser = username;
  };

  users.knownUsers = [ username ];
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.fish;
    uid = 503;
  };
}
