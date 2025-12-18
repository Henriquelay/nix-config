{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    # Import shared cross-platform profiles
    ../../../home/profiles/base.nix
    ../../../home/profiles/shell.nix
    ../../../home/profiles/development.nix

    # macOS-specific imports
    ./darwin/macos.nix
  ];

  home = {
    username = "henriquelay";
    homeDirectory = "/Users/henriquelay";
  };

  # macOS-specific packages (add as needed)
  home.packages = with pkgs; [
    # Add macOS-specific CLI tools here
  ];

  # macOS-specific overrides and settings
  programs = {
    # Override kitty font size for macOS
    kitty.font.size = lib.mkForce 14;

    # macOS-specific fish abbreviations (e.g., for darwin-rebuild)
    fish.shellAbbrs = {
      "drs" = {
        position = "anywhere";
        expansion = "darwin-rebuild switch --flake .";
      };
    };
  };

  # macOS-specific services
  services = {
    # macOS-specific pinentry for gpg-agent
    gpg-agent.pinentry.package = pkgs.pinentry_mac;
  };

  # No GTK on macOS
  gtk.enable = false;
}
