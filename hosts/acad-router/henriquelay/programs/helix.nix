{
  config,
  pkgs,
  helix-flake,
  ...
}:
{
  stylix.targets.kitty.enable = false;
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
      keys.normal = {
        "F2" = "command_palette";
        "home" = "goto_first_nonwhitespace";
        "C-l" = [
          "search_selection"
          "select_all"
          "select_regex"
        ];
      };
      keys.insert = {
        "F2" = "command_palette";
        "home" = "goto_first_nonwhitespace";
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
            "ltex"
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
            "harper-ls"
          ];
        }
      ];
    };
  };
}
