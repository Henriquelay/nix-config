{ config, pkgs, ... }:
{
  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark.yaml";
    cursor = {
      package = pkgs.capitaine-cursors-themed;
      name = "Capitaine Cursors (Gruvbox)";
      size = 42;
    };
    targets = {
      vscode.enable = false;
      fish.enable = false;
      kitty.enable = false;
      helix.enable = false;
      librewolf.profileNames = [ "default" ];
    };
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.hack;
        name = "Hack";
      };
      emoji = {
        package = pkgs.font-awesome;
        name = "Font Awesome 6";
      };
    };
  };
} 
