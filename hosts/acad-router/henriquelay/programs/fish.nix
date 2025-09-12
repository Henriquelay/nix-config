{ config, pkgs, ... }:
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
      cat = "bat";
    };

    shellAbbrs = {
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
            set --local BASE ~/Gits/Outroll

            # if not argv[1] is provided, quit
            if test (count $argv) -lt 1
              echo "Provide a directory to work in."
              ls $BASE
              return 1
            end


            set --local dir $BASE/$argv[1]
            if not test -d $dir
              echo "Directory $dir does not exist."
              return 1
            end

            cd $dir

            if not command --query ${terminal}
              echo "terminal is not available."
              return 1
            end

            # spawn a second terminal, completely detached from this one
            ${terminal} --detach --single-instance --directory . --hold  --title "bacon" nix develop --command fish -c "bacon clippy-all; exec fish"

            # spawn a third terminal, for general usage
            ${terminal} --detach --single-instance --directory . --hold fish --command "nix develop"

            nix develop --command fish -c "hx .; exec fish"
          '';
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
