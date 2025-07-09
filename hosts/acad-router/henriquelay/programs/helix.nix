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
          search_next_macro = ''@*vnv'';
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
            "C-l" = search_all_ocurrences_macro;
            "C-d" = search_next_macro;
          };
          select = {
            "C-l" = search_all_ocurrences_macro;
            "C-d" = search_next_macro;
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
        lsp-ai = {
          command = "${pkgs.lsp-ai}/bin/lsp-ai";
          config = {
            memory.file_store = { };
            # chat = {
            #   trigger = "!AI";
            #   action_display_name = "Chat";
            #   model = "copilot";
            #   parameters = {
            #     max_context = 4096;
            #     max_tokens = 1024;
            #     messages = [
            #       {
            #         role = "system";
            #         content = ''
            #           You are a code assistant chatbot. The user will ask you for assistance coding and you will do you best to answer succinctly and accurately
            #         '';
            #       }
            #     ];
            #   };
            # };
            # completion = {
            #   model = "copilot";
            #   parameters = {
            #     max_tokens = 64;
            #     max_context = 1024;
            #     messages = [
            #       {
            #         role = "system";
            #         content = ''
            #           Instructions:
            #             - You are an AI programming assistant.
            #             - Given a piece of code with the cursor location marked by "<CURSOR>", replace "<CURSOR>" with the correct code or comment.
            #             - First, think step-by-step.
            #             - Describe your plan for what to build in pseudocode, written out in great detail.
            #             - Then output the code replacing the "<CURSOR>"
            #             - Ensure that your completion fits within the language context of the provided code snippet (e.g., Python, JavaScript, Rust).
            #             Rules:
            #             - Only respond with code or comments.
            #             - Only replace "<CURSOR>"; do not include any previously written code.
            #             - Never include "<CURSOR>" in your response
            #             - If the cursor is within a comment, complete the comment meaningfully.
            #             - Handle ambiguous cases by providing the most contextually appropriate completion.
            #             - Be consistent with your responses.'';
            #       }

            #       {
            #         role = "user";
            #         content = ''
            #           def greet(name):
            #             print(f"Hello, {<CURSOR>}")'';
            #       }

            #       {
            #         role = "assistant";
            #         content = "name";
            #       }

            #       {
            #         role = "user";
            #         content = ''
            #           function sum(a, b) {
            #             return a + <CURSOR>;'';
            #       }

            #       {
            #         role = "assistant";
            #         content = "b";
            #       }

            #       {
            #         role = "user";
            #         content = ''
            #           fn multiply(a: i32, b: i32) -> i32 {
            #             a * <CURSOR>
            #           }'';
            #       }

            #       {
            #         role = "assistant";
            #         content = "b";
            #       }

            #       {
            #         role = "user";
            #         content = ''
            #           # <CURSOR>
            #           def add(a, b):
            #             return a + b'';
            #       }

            #       {
            #         role = "assistant";
            #         content = "Adds two numbers";
            #       }

            #       {
            #         role = "user";
            #         content = ''
            #           # This function checks if a number is even
            #           <CURSOR>'';

            #       }

            #       {
            #         role = "assistant";
            #         content = ''
            #           def is_even(n):
            #             return n % 2 == 0'';
            #       }

            #       {
            #         role = "user";
            #         content = "{CODE}";
            #       }

            #     ];
            #   };
            # };
            models = {
              copilot = {
                type = "open_ai";
                chat_endpoint = "https://api.githubcopilot.com/chat/completions";
                completions_endpoint = "https://api.githubcopilot.com/chat/completions";
                model = "";
                auth_token_env_var_name = "COPILOT_API_KEY";
              };
            };
          };
        };
      };
      language = [
        {
          name = "rust";
          language-servers = [
            "rust-analyzer"
            "helix-gpt"
            # "lsp-ai"
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
            # "lsp-ai"
            "harper-ls"
          ];
        }
        {
          name = "python";
          language-servers = [
            "ruff"
            "pyright"
            "helix-gpt"
            # "lsp-ai"
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
            # "lsp-ai"
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
            # "lsp-ai"
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
