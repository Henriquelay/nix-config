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
      "nt" = {
        command = "cargo";
        expansion = "nextest run";
      };
    };

    functions =
      let
        terminal = "${pkgs.kitty}/bin/kitty";
      in
      {
        work = # fish
          ''
            # cd into ~/Gits/Outroll/vestacp-private
            if not test -d ~/Gits/Outroll/vestacp-private
              echo "Directory ~/Gits/Outroll/vestacp-private does not exist."
              return 1
            end

            cd ~/Gits/Outroll/vestacp-private

            if not command --query ${terminal}
              echo "terminal is not available."
              return 1
            end

            # spawn a second terminal, completely detached from this one
            ${terminal} --detach --single-instance --directory ~/Gits/Outroll/vestacp-private --hold  --title "bacon" nix develop --command bacon clippy-all

            # spawn a third terminal, for general usage
            ${terminal} --detach --single-instance --directory ~/Gits/Outroll/vestacp-private --hold ${pkgs.fish}/bin/fish --command "nix develop"

            nix develop --command hx .
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
