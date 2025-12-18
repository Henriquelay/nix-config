{ config, pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    themeFile = "gruvbox-dark";
    font = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "Jetbrains Mono Nerd Font";
      size = 16; # Default size, override per-host (20 on Linux, 14 on macOS)
    };
    actionAliases = {
      "launch_tab" = "launch --cwd=current --type=tab";
      "launch_window" = "launch --cwd=current --type=os-window";
    };
    keybindings = {
      "f1" = "launch --cwd=current --type=os-window";
    };
  };
}
