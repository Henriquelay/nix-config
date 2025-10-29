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

      "nrs" = {
        position = "anywhere";
        expansion = "nixos-rebuild switch";
      };

      "nt" = {
        command = "cargo";
        expansion = "nextest run --all-targets";
      };
    };

    functions =
      let
        terminal = "${pkgs.kitty}/bin/kitty";
      in
      {
        work = # fish
          ''
            set --local BASE ~/Gits
            # if not argv[1] is provided, quit
            if test (count $argv) -lt 1
              echo "Provide a directory to work in."
              ls $BASE
              return 1
            end


            set --function dir $BASE/$argv[1]
            if not test -d $dir
              echo "Directory $dir does not exist."
              return 1
            end

            cd $dir

            if not command --query ${terminal}
              echo "terminal is not available."
              return 1
            end

            # flake lives in $dir
            # if starts with `Surt/`, then use parent directory
            if string match -r '^Surt/' $argv[1]
              # split on first '/'
              set dir ..
            else
              set dir .
            end

            # spawn a second terminal, completely detached from this one
            # ${terminal} --detach --single-instance --directory . --hold  --title "bacon" nix develop $dir --command fish -c "bacon clippy-all; exec fish"

            # spawn a third terminal, for general usage
            ${terminal} --detach --single-instance --directory . --hold fish --command "nix develop $dir"

            nix develop $dir --command fish -c "hx .; exec fish"
          '';
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
