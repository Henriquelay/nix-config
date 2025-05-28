{ config, pkgs, ... }:
{
  stylix.targets.kitty.enable = false;
  programs.fish = {
    enable = true;
    loginShellInit = ''
      if [ (tty) = "/dev/tty1" ]
        exec Hyprland &> ~/hyprland_output.log
      end
    '';
    shellInit = ''
      set -g fish_greeting # Disable greeting
      if command -q ${pkgs.nix-your-shell}/bin/nix-your-shell
        ${pkgs.nix-your-shell}/bin/nix-your-shell fish | source
      end
    '';
    shellAliases = {
      cat = "bat";
    };
    plugins = with pkgs.fishPlugins; [
      {
        name = "sponge";
        src = sponge.src;
      }
      {
        name = "grc";
        src = grc.src;
      }
      {
        name = "done";
        src = done.src;
      }
      {
        name = "gruvbox";
        src = gruvbox.src;
      }
    ];
  };
} 
