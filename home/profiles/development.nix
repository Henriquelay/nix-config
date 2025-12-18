{ config, pkgs, lib, ... }:
{
  # Cross-platform development tools
  imports = [
    ../programs/helix.nix
    ../programs/git.nix
    ../programs/vscode.nix
    ../programs/kitty.nix
    ../programs/rclone.nix
    ../programs/aider.nix
    ../programs/claude-code.nix
  ];

  programs = {
    # GPG
    gpg = {
      enable = true;
      mutableTrust = true;
      mutableKeys = true;
    };
  };

  services = {
    # GPG agent
    # Note: pinentry package is set per-host (pinentry-gtk2 on Linux, pinentry_mac on macOS)
    gpg-agent = {
      enable = true;
      enableFishIntegration = true;
      defaultCacheTtl = 604800; # 1 week
      enableSshSupport = true;
      extraConfig = ''
        debug-pinentry
      '';
    };
  };
}
