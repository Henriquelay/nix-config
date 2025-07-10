{
  config,
  pkgs,
  helix-flake,
  ...
}:
{
  programs.helix = {
    enable = true;
    package = helix-flake.packages.${pkgs.system}.default;
    defaultEditor = true;
    settings = {
      theme = "gruvbox";
      editor = {
        auto-format = true;
        bufferline = "multiple";
        color-modes = true;
        cursor-shape.insert = "bar";
        cursorline = true;
        end-of-line-diagnostics = "hint";
        line-number = "relative";
        popup-border = "all";
        soft-wrap.enable = true;
        undercurl = true;
        inline-diagnostics = {
          cursor-line = "hint";
          other-lines = "hint";
        };
        lsp = {
          display-inlay-hints = false;
          display-messages = true;
        };
      };
      keys =
        let
          search_all_ocurrences_macro = ''@*%s<ret>'';
          # search_next_macro = ''@*vnv'';
          search_n = command: [
            "search_selection_detect_word_boundaries"
            "select_mode"
            command
            "exit_select_mode"
          ];
          run_external_command = command: [
            ":write-all"
            ":new"
            ":insert-output ${pkgs.${command}}/bin/${command}"
            ":set mouse false" # First disable mouse to hint helix into activating it
            ":set mouse true"
            ":buffer-close!"
            ":redraw"
            ":reload-all"
          ];
        in
        {
          normal = {
            "F2" = "command_palette";
            # TODO for some reason this ignores CTRL key so we can't quit the program and the terminal is locked
            # "F3" = [
            #   ":write-all"
            #   ":insert-output ${pkgs.serpl}/bin/serpl >/dev/tty"
            #   ":redraw"
            #   ":reload-all"
            # ];
            "home" = "goto_first_nonwhitespace";
            "S-h" = "goto_previous_buffer";
            "S-l" = "goto_next_buffer";
            "C-l" = search_all_ocurrences_macro;
            "C-d" = search_n "extend_search_next";
            "C-S-d" = search_n "extend_search_prev";
            # move/copy line below/above
            # "A-j" = [ "extend_to_line_bounds", "delete_selection", "paste_after" ]
            # "A-k" = [ "extend_to_line_bounds", "delete_selection", "move_line_up", "paste_before" ]
            # "A-J" = [ "extend_to_line_bounds", "yank", "paste_after" ]
            # "A-K" = [ "extend_to_line_bounds", "yank", "paste_before" ]
            # New minor modes
            # "C-t" = {
            #   g = run_external_command "lazygit";
            #   s = run_external_command "scooter";
            # };
          };
          select = {
            "C-l" = search_all_ocurrences_macro;
            "C-d" = search_n "extend_search_next";
            "C-S-d" = search_n "extend_search_prev";
          };
          insert = {
            "F2" = "command_palette";
            "home" = "goto_first_nonwhitespace";
          };
        };
    };
    languages = {
      language-server = {
        rust-analyzer.config = {
          check.command = "clippy";
          features = "all";
        };
        ruff.command = "ruff-lsp";
        tinymist.command = "tinymist";
        harper-ls = {
          command = "harper-ls";
          args = [ "--stdio" ];
        };
        ltex.command = "${pkgs.ltex-ls}/bin/ltex-ls";
        helix-gpt = {
          command = "${pkgs.helix-gpt}/bin/helix-gpt";
          args = [
            "--handler"
            "copilot"
          ];
        };
      };
      language = [
        {
          name = "rust";
          language-servers = [
            "rust-analyzer"
            "helix-gpt"
            "harper-ls"
          ];
        }
        {
          name = "nix";
          formatter.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
          auto-format = true;
          language-servers = [
            "nil"
            "helix-gpt"
            "harper-ls"
          ];
        }
        {
          name = "python";
          language-servers = [
            "ruff"
            "pyright"
            "helix-gpt"
            "harper-ls"
          ];
          auto-format = true;
        }
        {
          name = "typst";
          language-servers = [
            "tinymist"
            "typst-lsp"
            # "ltex"
            "helix-gpt"
            "harper-ls"
          ];
          formatter.command = "${pkgs.typstyle}/bin/typstyle";
          auto-format = true;
        }
        {
          name = "latex";
          language-servers = [
            "ltex"
            "texlab"
            "helix-gpt"
            "harper-ls"
          ];
          auto-format = true;
        }
        {
          name = "toml";
          auto-format = true;
          formatter.command = "taplo";
          formatter.args = [
            "fmt"
            "-"
          ];
          language-servers = [
            "taplo"
            "harper-ls"
          ];
        }
        {
          name = "markdown";
          auto-format = true;
          language-servers = [
            "markdown-oxide"
            "helix-gpt"
            # "lsp-ai"
            "harper-ls"
          ];
        }
      ];
    };
  };
}
