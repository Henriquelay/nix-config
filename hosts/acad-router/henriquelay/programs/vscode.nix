{ config, pkgs, ... }:
{
    stylix.targets.vscode.enable = false;
    programs.vscode = {
      enable = true;
      # package = pkgs.code-cursor;
    };
} 
