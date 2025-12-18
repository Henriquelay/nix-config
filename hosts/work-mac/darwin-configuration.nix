{
  config,
  pkgs,
  lib,
  ...
}:
let
  username = "henriquelay";
in
{
  # System-level macOS configuration

  # Basic Nix settings
  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # macOS system packages (if any)
  environment.systemPackages = with pkgs; [
    # Add system-level packages if needed
  ];

  # Enable fish shell system-wide
  programs.fish.enable = true;

  # Home-manager integration
  home-manager = {
    backupFileExtension = "hmbackup";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit (config.specialArgs) helix-flake;
    };
    users.${username} = {
      imports = [ ./henriquelay/home.nix ];
    };
  };

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
  };

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.fish;
  };

  # Auto upgrade nix package and the daemon service
  services.nix-daemon.enable = true;
}
