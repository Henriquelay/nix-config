{ config, pkgs, ... }:
{
  stylix.targets.kitty.enable = false;
  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    themeFile = "gruvbox-dark";
    font = {
      package = pkgs.nerd-fonts.hack;
      name = "Hack Nerd Font";
      size = 22;
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
