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
        mouse = false;
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
            # ":set mouse false" # First disable mouse to hint helix into activating it
            # ":set mouse true"
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
            "C-j" = "save_selection";
            "C-s" = ":write";
            "C-S-s" = ":write-all";
            "C-d" = search_n "extend_search_next";
            "C-S-d" = search_n "extend_search_prev";
            # move/copy line below/above
            "A-j" = [
              "extend_to_line_bounds"
              "delete_selection"
              "paste_after"
            ];
            "A-k" = [
              "extend_to_line_bounds"
              "delete_selection"
              "move_line_up"
              "paste_before"
            ];
            "A-J" = [
              "extend_to_line_bounds"
              "yank"
              "paste_after"
            ];
            "A-K" = [
              "extend_to_line_bounds"
              "yank"
              "paste_before"
            ];

            "C-y" = [
              ":sh rm -f /tmp/unique-file"
              ":insert-output ${pkgs.yazi}/bin/yazi %{buffer_name} --chooser-file=/tmp/unique-file"
              '':insert-output echo "\x1b[?1049h\x1b[?2004h" > /dev/tty''
              ":open %sh{cat /tmp/unique-file}"
              # ":set mouse false" # First disable mouse to hint helix into activating it
              # ":set mouse true"
              ":redraw"
            ];

            "space" = {
              "x" = ":buffer-close";
              "S-x" = ":buffer-close-others";
              # Add ";" to the end of the line and return to the same position
              ";" = "@A;<esc>";
            };

            # New minor modes
            # "C-t" = {

            # g = run_external_command "lazygit";
            # s = run_external_command "scooter";
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
      # Keep as regular calls the commands you want to only be accessible when the Nix environment makes it available
      # Use ${pkgs.program}/bin/program to call program you want to be available everywhere
      language-server = {
        rust-analyzer.config = {
          check.command = "clippy";
          features = "all";
        };
        ruff.command = "ruff";
        tinymist.command = "tinymist";
        harper = {
          command = "${pkgs.harper}/bin/harper-ls";
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
            "harper"
          ];
        }
        {
          name = "nix";
          formatter.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
          auto-format = true;
          language-servers = [
            "nil"
            "helix-gpt"
            "harper"
          ];
        }
        {
          name = "python";
          language-servers = [
            "ruff"
            "pyright"
            "helix-gpt"
            "harper"
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
            "harper"
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
            "harper"
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
            "harper"
          ];
        }
        {
          name = "markdown";
          auto-format = true;
          language-servers = [
            "markdown-oxide"
            "helix-gpt"
            # "lsp-ai"
            "harper"
          ];
        }
      ];
    };
  };
}
