{
  lib,
  pkgs,
  config,
  ...
}:
{
  programs.claude-code = {
    enable = true;
  };

  # Dependency for vscode extension for claude code
  home.packages = lib.mkIf config.programs.claude-code.enable [
    pkgs.nodejs_22
  ];

  # Claude Code memory rules (symlink to git repo for live updates)
  home.file.".claude/rules" = lib.mkIf config.programs.claude-code.enable {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/programs/claude-code/rules";
  };
}
