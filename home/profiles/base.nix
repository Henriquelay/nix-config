{ config, pkgs, lib, ... }:
{
  # Core cross-platform home-manager setup
  # NOTE: username and homeDirectory are set per-host in home.nix

  home = {
    # Home Manager release version compatibility
    stateVersion = "25.05";
  };

  # Enable home-manager
  programs.home-manager.enable = true;

  # Simple cross-platform programs (enable without configuration)
  programs = {
    bat.enable = true;
    ripgrep.enable = true;
    jq.enable = true;
    fd.enable = true;
    bottom.enable = true;
    bacon.enable = true;
  };
}
