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

  # Claude Code memory rules (shared across hosts)
  home.file.".claude/rules" = lib.mkIf config.programs.claude-code.enable {
    source = ./claude-code/rules;
    recursive = true;
  };
}
