{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.fish = {
    enable = true;
    shellInit =
      # fish
      ''
        set -g fish_greeting # Disable greeting
        if command -q ${pkgs.nix-your-shell}/bin/nix-your-shell
          ${pkgs.nix-your-shell}/bin/nix-your-shell fish | source
        end
      '';

    shellAliases = {
      cat = "${pkgs.bat}/bin/bat";
      du = "${pkgs.dust}/bin/dust";
    };

    shellAbbrs = {
      "cd.." = {
        position = "command";
        expansion = "cd ..";
      };

      "nt" = {
        command = "cargo";
        expansion = "nextest run --all-targets";
      };
    };

    # Platform-specific functions (like "work") should be added in host-specific configs
    functions = {
      # Add cross-platform functions here if needed
    };

    plugins =
      let
        pluginSources = with pkgs.fishPlugins; {
          autopair = autopair.src;
          colored-man-pages = colored-man-pages.src;
          done = done.src;
          fish-you-should-use = fish-you-should-use.src;
          grc = grc.src;
          gruvbox = gruvbox.src;
          sponge = sponge.src;
        };
      in
      lib.mapAttrsToList (name: src: { inherit name src; }) pluginSources;
  };
}
