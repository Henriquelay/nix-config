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
      model = "opusplan";
      effortLevel = "high";
      permissions.allow =
        let
          cargo_cmds = [
            "cargo check"
            "cargo clippy"
            "cargo fmt"
            "cargo nextext run"
            "cargo test"
          ];
          bash_cmds_all_subcommands = [
            "ip a"
            "cat"
            "grep"
            "git log"
            "git status"
            "find"
            "awk"
            "find"
            "gh pr diff"
            "gh pr list"
            "gh pr view"
            "gr pr checks"
          ];
        in
        builtins.concatLists [
          (builtins.map (command: "Bash(${command}:*)") (bash_cmds_all_subcommands ++ cargo_cmds))
          [
            "mcp__claude_ai__Context7__*"
          ]
        ];
    };
  };

  # Dependency for vscode extension for claude code
  home.packages = lib.mkIf config.programs.claude-code.enable [
    pkgs.nodejs_22
  ];
}
