{
  lib,
  pkgs,
  config,
  ...
}:
{
  programs.claude-code = {
    enable = true;
    rulesDir = ./claude-code/rules;
    settings = {
      includeCoAuthoredBy = false;
      alwaysThinkingEnabled = true;
      model = "opus";
      permissions.allow = builtins.concatLists [
        (builtins.map (command: "Bash(${command})") [
          "ip a:*"
          "cat:*"
        ])
      ];
    };
  };

  # Dependency for vscode extension for claude code
  home.packages = lib.mkIf config.programs.claude-code.enable [
    pkgs.nodejs_22
  ];
}
