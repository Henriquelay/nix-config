{
  config,
  pkgs,
  ...
}:
let

  sway-launch = pkgs.writeShellApplication {
    name = "sway-launch";
    text = ''
      #! /usr/bin/env sh

      # see: https://man.sr.ht/~kennylevinsen/greetd/#how-to-set-xdg_session_typewayland

      set -eu

      # __dotfiles_wayland_teardown() {
      #   # true: as long as we try it's okay
      #   systemctl --user stop sway-session.target || true

      #   # this teardown makes it easier to switch between compositors
      #   unset DISPLAY SWAYSOCK WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE
      #   systemctl --user unset-environment DISPLAY SWAYSOCK WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE
      #   if command -v dbus-update-activation-environment >/dev/null; then
      #     dbus-update-activation-environment XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE
      #   fi
      # }
      # __dotfiles_wayland_teardown

      export XDG_CURRENT_DESKTOP=sway  # xdg-desktop-portal
      export XDG_SESSION_DESKTOP=sway  # systemd
      export XDG_SESSION_TYPE=wayland  # xdg/systemd
      export WAYLAND_DISPLAY=wayland-1 # hack, hardcoded by me

      if command -v dbus-update-activation-environment >/dev/null; then
        dbus-update-activation-environment XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE WAYLAND_DISPLAY
      fi
      # without this, systemd starts xdg-desktop-portal without these environment variables,
      # and the xdg-desktop-portal does not start xdg-desktop-portal-wrl as expected
      # https://github.com/emersion/xdg-desktop-portal-wlr/issues/39#issuecomment-638752975
      systemctl --user import-environment XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE WAYLAND_DISPLAY

      unset WAYLAND_DISPLAY
      dbus-run-session sway

      # use systemd-run here, because systemd units inherit variables from ~/.config/environment.d
      # true: ignore errors here so we always do the teardown afterwards
      ## shellcheck disable=SC2068
      # systemd-run --quiet --unit=sway --user --wait sway --config ~/.config/sway/config $@ || true

      # __dotfiles_wayland_teardown
    '';
  };
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home = {
    username = "henriquelay";
    homeDirectory = "/home/henriquelay";
    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "25.05"; # Please read the comment before changing.
    packages = with pkgs; [
      # Desktop/WM stuff
      libnotify
      sway-launcher-desktop
      sway-launch
      pavucontrol
      playerctl
      sway-contrib.grimshot # Sway specific features
      grimblast
      i3bar-river # Port of i3bar for river and other wlroots wms

      # General programs
      telegram-desktop
      gvfs # For trash support and other stuff like that
      xdg-utils
      poppler
      grc
      webcord
      blueman
      qbittorrent
      # jackett
      # heroic # Games launcher
      # gogdl # GOG downloading module for heroic
      obsidian
      feh
      nur.repos.nltch.spotify-adblock
      mpv
      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      slurp # For screencapture. Needed from xdg-desktop-portal-wlr
      wf-recorder

      # Langs and lang servers. Dev stuff
      # Should most of these be here? Should be handled by a dev shell.
      # I'll keep only the scripting and ones I want quick access to.
      helix-gpt
      harper
      taplo # TOML
      # python313
      # ruff-lsp
      # pyright
      # quarto
      # typst
      # tinymist
      # typstyle
      nil
      nixfmt-rfc-style
      rust-analyzer
      # rustfmt
      # clippy
      nix-your-shell
      # marksman # markdown lsp
      markdown-oxide
      # ltex-ls
      # texlab

      slack

      # Local packages
      # (callPackage ../../packages/notekit.nix {})
    ];

    sessionVariables = {
      # If cursors are invisible
      # WLR_NO_HARDWARE_CURSORS = "1";
      # Hint electron apps to use Wayland
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      # XDG_SESSION_TYPE = "wayland";
      # XDG_SESSION_DESKTOP = "sway";
      # XDG_CURRENT_DESKTOP = "sway";
      # WAYLAND_DISPLAY = "wayland-1";
      # Disable window decorator on QT applications
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      TERMINAL = "${pkgs.kitty}/bin/kitty";
    };

    sessionPath = [
      "$HOME/.cargo/bin" # For some stuff interactively installed with `cargo install`
    ];

  };
  stylix = {
    enable = true;
    polarity = "dark";
    # image = ./blackpx.jpg; # required for enabling hyprland, I guess
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/ashen.yaml";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
    # base16Override = '' # TODO finish replacing with ASHEN
    #   # Ashen scheme for the Base16 Builder (git.sr.ht/~ficd/ashen)
    #   system: "base16"
    #   name: "Ashen"
    #   author: "Daniel Fichtinger (sr.ht/~ficd)"
    #   variant: "dark"
    #   palette:
    #     base00: "#1C2023" # ----
    #     base01: "#393F45" # ---
    #     base02: "#565E65" # --
    #     base03: "#747C84" # -
    #     base04: "#ADB3BA" # +
    #     base05: "#C7CCD1" # ++
    #     base06: "#DFE2E5" # +++
    #     base07: "#F3F4F5" # ++++
    #     base08: "#C7AE95" # orange
    #     base09: "#C7C795" # yellow
    #     base0A: "#AEC795" # poison green
    #     base0B: "#95C7AE" # turquois
    #     base0C: "#95AEC7" # aqua
    #     base0D: "#AE95C7" # purple
    #     base0E: "#C795AE" # pink
    #     base0F: "#C79595" # light red
    # '';
    cursor = {
      package = pkgs.rose-pine-cursor;
      name = "BreezeX-RosePine-Linux";
      size = 32;
    };
    targets = {
      vscode.enable = false;
      # fish.enable = false;
      kitty.enable = false;
      helix.enable = false;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.hack;
        name = "Hack";
      };
      emoji = {
        package = pkgs.font-awesome;
        name = "Font Awesome 6";
      };
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      userName = "Henriquelay";
      userEmail = "37563861+Henriquelay@users.noreply.github.com";
      signing = {
        key = "B3903EAC57AD1331995CD96202843DDA217C9D81";
        signByDefault = true;
      };
      aliases = {
        sw = "switch";
        br = "branch";
        co = "checkout";
        st = "status";
      };
      extraConfig = {
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
      };
    };

    fish = {
      enable = true;
      loginShellInit = ''
        if [ (tty) = "/dev/tty1" ]
          # exec ${pkgs.lib.getExe sway-launch} &> ~/sway_output.log
          # exec sway &> ~/sway_output.log
          exec Hyprland &> ~/hyprland_output.log
        end
      '';
      shellInit = ''
        set -g fish_greeting # Disable greeting
        if command -q nix-your-shell
          nix-your-shell fish | source
        end
      '';
      # functions = {
      # yy = {
      #   body = ''
      #     set tmp (mktemp -t "yazi-cwd.XXXXX")
      #     yazi $argv --XDG_CURRENT_DESKTOP=sway dbus-run-session swaycwd-file="$tmp"
      #     if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
      #       builtin cd -- "$cwd"
      #     end
      #     rm -f -- "$tmp"
      #   '';
      # };
      # };

      shellAliases = {
        cat = "bat";
      };

      plugins = with pkgs.fishPlugins; [
        {
          name = "tide";
          src = tide.src;
        }
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
      ];
    };

    mangohud = {
      enable = true;
      enableSessionWide = true;
      settings = {
        preset = 3;
        # no_display = true;
        # TODO can't change with stylix enabled
        # background_alpha = 0.5;
        # alpha = 0.9;
      };
    };

    kitty = {
      enable = true;
      shellIntegration.enableFishIntegration = true;
      # themeFile = "rose-pine";
      font = {
        package = pkgs.nerd-fonts.hack;
        name = "Hack Nerd Font";
        size = 18;
      };
      actionAliases = {
        "launch_tab" = "launch --cwd=current --type=tab";
        "launch_window" = "launch --cwd=current --type=os-window";
      };
      keybindings = {
        "f1" = "launch --cwd=current --type=os-window";
      };

    };

    helix = {
      enable = true;
      defaultEditor = true;
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
            # formatter.command = "rustfmt";
            # auto-format = true;
          }
          {
            name = "nix";
            formatter.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
            auto-format = true;
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
              "texlab" # not in this config. Start a nix-shell
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
          }
          {
            name = "markdown";
            auto-format = true;
            language-servers = [
              "markdown-oxide"
              # "marksman"
              "helix-gpt"
              "harper-ls"
            ];
          }
        ];
      };
      themes = {
        ashen = {
          attribute = "g_4";
          "type" = "blue";
          "type.builtin" = "blue";
          "type.parameter" = "orange_glow";
          "type.enum.variant" = "orange_blaze";
          "constructor" = "g_1";
          "constant" = "orange_blaze";
          "constant.builtin" = "blue";
          "constant.character" = {
            "fg" = "red_glowing";
            "modifiers" = [ "bold" ];
          };
          "constant.character.escape" = "g_2";
          "constant.numeric" = "blue";
          "string" = "red_glowing";
          "string.regexp" = "orange_glow";
          "string.special" = "g_2";
          "string.special.url" = {
            "fg" = "red_glowing";
            "modifiers" = [ "bold" ];
          };
          "string.special.path" = {
            "fg" = "red_glowing";
            "modifiers" = [ "bold" ];
          };
          "string.special.symbol" = "orange_smolder";
          "comment" = {
            "fg" = "g_6";
            "modifiers" = [ "italic" ];
          };
          "comment.block.documentation" = {
            "fg" = "g_5";
            "modifiers" = [ "italic" ];
          };
          "variable" = "g_3";
          "variable.parameter" = {
            "fg" = "g_2";
            "modifiers" = [ "italic" ];
          };
          "variable.builtin" = "blue";
          "variable.other.member" = {
            "fg" = "g_2";
          };
          "label" = "red_ember";
          "punctuation" = "g_2";
          "punctuation.special" = "orange_golden";
          "punctuation.bracket" = "g_6";
          "punctuation.delimiter" = "orange_smolder";
          "keyword" = "red_ember";
          "keyword.operator" = "orange_blaze";
          "keyword.directive" = {
            "fg" = "red_ember";
            "modifiers" = [ "italic" ];
          };
          "keyword.storage.modifier" = {
            "fg" = "red_ember";
            "modifiers" = [ "italic" ];
          };
          "operator" = "orange_glow";
          "function" = {
            "fg" = "g_3";
            "modifiers" = [ "bold" ];
          };
          "function.builtin" = {
            "fg" = "g_3";
            "modifiers" = [
              "bold"
              "italic"
            ];
          };
          "function.macro" = "red_ember";
          "tag" = {
            "fg" = "orange_glow";
            "modifiers" = [ "italic" ];
          };
          "namespace" = {
            "fg" = "orange_glow";
            "modifiers" = [ "bold" ];
          };
          "special" = "orange_smolder";
          "markup.heading" = {
            "fg" = "red_glowing";
            "modifiers" = [ "bold" ];
          };
          "markup.list" = "orange_glow";
          "markup.bold" = {
            "modifiers" = [ "bold" ];
          };
          "markup.italic" = {
            "modifiers" = [ "italic" ];
          };
          "markup.link.url" = {
            "fg" = "red_glowing";
            "modifiers" = [
              "italic"
              "underlined"
            ];
          };
          "markup.link.text" = "red_ember";
          "markup.raw" = {
            "fg" = "g_2";
            "bg" = "g_10";
          };
          "markup.quote" = {
            "modifiers" = [ "italic" ];
          };
          "diff.plus" = "g_6";
          "diff.minus" = "red_ember";
          "diff.delta" = "brown";
          "ui.background" = {
            "fg" = "text";
            "bg" = "background";
          };
          "ui.linenr" = {
            "fg" = "g_8";
          };
          "ui.linenr.selected" = {
            "fg" = "g_6";
          };
          "ui.statusline" = {
            "fg" = "g_3";
            "bg" = "g_9";
          };
          "ui.statusline.inactive" = {
            "fg" = "g_5";
            "bg" = "g_10";
          };
          "ui.statusline.normal" = {
            "fg" = "background";
            "bg" = "orange_blaze";
            "modifiers" = [ "bold" ];
          };
          "ui.statusline.insert" = {
            "fg" = "g_1";
            "bg" = "g_7";
            "modifiers" = [ "bold" ];
          };
          "ui.statusline.select" = {
            "fg" = "background";
            "bg" = "orange_golden";
            "modifiers" = [ "bold" ];
          };
          "ui.popup" = {
            "fg" = "text";
            "bg" = "g_10";
          };
          "ui.info" = {
            "fg" = "orange_blaze";
            "bg" = "g_10";
          };
          "ui.window" = {
            "fg" = "g_7";
          };
          "ui.help" = {
            "fg" = "text";
            "bg" = "g_10";
            "modifiers" = [ "bold" ];
          };
          "ui.bufferline" = {
            "fg" = "text";
            "bg" = "background";
          };
          "ui.bufferline.active" = {
            "fg" = "g_2";
            "bg" = "g_10";
            "underline" = {
              "color" = "orange_blaze";
              "style" = "line";
            };
          };
          "ui.bufferline.background" = {
            "bg" = "background";
          };
          "ui.text" = "text";
          "ui.text.focus" = {
            "fg" = "g_2";
            "bg" = "g_10";
            "underline" = {
              "color" = "red_ember";
              "style" = "line";
            };
            "modifiers" = [ "bold" ];
          };
          "ui.text.inactive" = {
            "fg" = "g_7";
          };
          "ui.text.directory" = {
            "fg" = "red_ember";
          };
          "ui.virtual" = "g_5";
          "ui.virtual.ruler" = {
            "bg" = "cursorline";
          };
          "ui.virtual.whitespace" = "g_7";
          "ui.virtual.indent-guide" = "g_7";
          "ui.virtual.wrap" = "g_7";
          "ui.virtual.inlay-hint" = {
            "fg" = "g_6";
            "modifiers" = [ "italic" ];
          };
          "ui.virtual.jump-label" = {
            "fg" = "background";
            "bg" = "orange_blaze";
            "modifiers" = [ "bold" ];
          };
          "ui.selection" = {
            "bg" = "brown_dark";
          };
          "ui.cursor.normal" = {
            "fg" = "background";
            "bg" = "orange_muted";
          };
          "ui.cursor.insert" = {
            "fg" = "background";
            "bg" = "g_7";
          };
          "ui.cursor.select" = {
            "fg" = "background";
            "bg" = "golden_muted";
          };
          "ui.cursor.primary.normal" = {
            "fg" = "background";
            "bg" = "orange_blaze";
            "modifiers" = [ "bold" ];
          };
          "ui.cursor.primary.insert" = {
            "fg" = "background";
            "bg" = "g_3";
            "modifiers" = [ "bold" ];
          };
          "ui.cursor.primary.select" = {
            "fg" = "background";
            "bg" = "orange_golden";
            "modifiers" = [ "bold" ];
          };
          "ui.cursor.match" = {
            "fg" = "orange_smolder";
            "modifiers" = [ "underlined" ];
          };
          "ui.cursorline.primary" = {
            "bg" = "cursorline";
          };
          "ui.cursorline" = {
            "bg" = "g_12";
          };
          "ui.highlight" = {
            "fg" = "orange_blaze";
            "bg" = "cursorline";
            "underline" = {
              "color" = "red_ember";
              "style" = "line";
            };
            "modifiers" = [ "bold" ];
          };
          "ui.menu" = {
            "fg" = "g_2";
            "bg" = "g_10";
          };
          "ui.menu.selected" = {
            "fg" = "background";
            "bg" = "orange_blaze";
            "modifiers" = [ "bold" ];
          };
          "diagnostic.error" = {
            "underline" = {
              "color" = "red_flame";
              "style" = "curl";
            };
          };
          "diagnostic.warning" = {
            "underline" = {
              "color" = "orange_golden";
              "style" = "curl";
            };
          };
          "diagnostic.info" = {
            "underline" = {
              "color" = "g_4";
              "style" = "dotted";
            };
          };
          "diagnostic.hint" = {
            "underline" = {
              "color" = "g_5";
              "style" = "dotted";
            };
          };
          "diagnostic.unnecessary" = {
            "modifiers" = [ "dim" ];
          };
          "error" = {
            "fg" = "red_flame";
            "bg" = "g_10";
          };
          "warning" = {
            "fg" = "orange_golden";
            "bg" = "g_10";
          };
          "info" = {
            "fg" = "g_2";
            "bg" = "g_10";
          };
          "hint" = {
            "fg" = "g_4";
            "bg" = "g_10";
          };
          "palette" = {
            "cursorline" = "#191919";
            "text" = "#b4b4b4";
            "red_flame" = "#C53030";
            "red_glowing" = "#DF6464";
            "red_ember" = "#B14242";
            "orange_glow" = "#D87C4A";
            "orange_blaze" = "#C4693D";
            "orange_muted" = "#6D3B22";
            "orange_smolder" = "#E49A44";
            "orange_golden" = "#E5A72A";
            "golden_muted" = "#6D4D0D";
            "brown" = "#89492a";
            "brown_dark" = "#322119";
            "blue" = "#4A8B8B";
            "background" = "#121212";
            "g_1" = "#e5e5e5";
            "g_2" = "#d5d5d5";
            "g_3" = "#b4b4b4";
            "g_4" = "#a7a7a7";
            "g_5" = "#949494";
            "g_6" = "#737373";
            "g_7" = "#535353";
            "g_8" = "#323232";
            "g_9" = "#212121";
            "g_10" = "#1d1d1d";
            "g_11" = "#191919";
            "g_12" = "#151515";
          };
        };
      };
      settings = {
        theme = "rose_pine";
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
        };
        keys.insert = {
          "F2" = "command_palette";
          "home" = "goto_first_nonwhitespace";
        };
      };
    };

    yazi = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        manager = {
          show_hidden = true;
          sort_by = "mtime";
          sort_dir_first = true;
          sort_reverse = true;
        };
      };
    };

    bat.enable = true;
    ripgrep.enable = true;
    jq.enable = true;
    fd.enable = true;
    zathura = {
      enable = true;
      extraConfig = ''set selection-clipboard clipboard'';
    };
    bottom.enable = true;
    librewolf = {
      enable = true;
      settings = {
        "webgl.disabled" = false;
        "identity.fxaccounts.enabled" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheetums" = true;
        # "privacy.clearOnShutdown.history" = false;
        # "privacy.clearOnShutdown.cookies" = false;
        # "network.cookie.lifetimePolicy" = 0;

        # "privacy.donottrackheader.enabled" = true;
        # "privacy.fingerprintingProtection" = true;
        "privacy.resistFingerprinting" = false;
        # "privacy.trackingprotection.emailtracking.enabled" = true;
        # "privacy.trackingprotection.enabled" = true;
        # "privacy.trackingprotection.fingerprinting.enabled" = true;
        # "privacy.trackingprotection.socialtracking.enabled" = true;
      };
    };

    gpg = {
      enable = true;
      mutableTrust = true;
      mutableKeys = true;
    };

    pyenv = {
      enable = false; # Should be handled by devShell, or use user package.
      enableFishIntegration = true;
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
      options = [
        "--cmd"
        "cd"
      ];
    };

    vscode = {
      enable = true;
      # package = pkgs.code-cursor;
    };

    eza = {
      enable = true;
      enableFishIntegration = true;
      icons = "auto";
      extraOptions = [
        "--group-directories-first"
        "--header"
      ];
    };

    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-vaapi
      ];
    };

    i3status-rust = {
      enable = true;

      bars = {
        default = {
          theme = "ctp-frappe";
          icons = "awesome6";
          blocks = [
            {
              block = "focused_window";
            }
            {
              block = "docker";
              interval = 10;
              format = " $icon $running/$total";
            }
            {
              block = "disk_space";
              path = "/";
              format = " $icon / $available";
              info_type = "available";
              alert_unit = "GB";
              interval = 20;
              warning = 20.0;
              alert = 10.0;
            }
            {
              block = "disk_space";
              path = "/home";
              format = " $icon /home $available";
              info_type = "available";
              alert_unit = "GB";
              interval = 20;
              warning = 20.0;
              alert = 10.0;
            }
            {
              block = "disk_space";
              path = "/vault";
              format = " $icon /vault $available";
              info_type = "available";
              alert_unit = "GB";
              interval = 20;
              warning = 30.0;
              alert = 10.0;
            }
            {
              block = "memory";
              format = " $icon $mem_used/$mem_total ($mem_avail free)";
              format_alt = " $icon_swap $swap_used/$swap_total ($swap_used_percents)";
              interval = 3;
            }
            {
              block = "cpu";
              interval = 2;
              format = " $icon $utilization $frequency $boost ";
            }
            {
              block = "temperature";
              format = " $icon $average";
            }
            {
              block = "music";
              player = "spotify";
              format = " $icon {$combo.str(max_w:25,rot_interval:0.5) $play $next |}";
            }
            {
              block = "sound";
              show_volume_when_muted = true;
            }
            {
              block = "net";
              device = "enp14s0";
              format = " $icon ↓$speed_down ↑$speed_up";
              format_alt = "$icon ↓$graph_down ↑$graph_up";
            }
            {
              block = "weather";
              format = " $icon $weather $temp";
              service = {
                name = "openweathermap";
                api_key = "4d8b9e3c0cd2b311891fc18f52493a6e";
                city_id = "3445026";
                units = "metric";
              };
            }
            {
              block = "time";
              interval = 1;
              format = " $timestamp.datetime(f:'%a %d/%m %R:%S')";
            }
          ];
        };
      };
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      enableFishIntegration = true;
      defaultCacheTtl = 604800; # 1 week
      enableSshSupport = true;
      pinentryPackage = pkgs.pinentry-gtk2;
      extraConfig = ''
        debug-pinentry
      '';
    };

    syncthing.enable = true;

    # nextcloud-client.enable = true;

  };

  ## WM and visuals

  wayland.windowManager.sway =
    let
      modifier = "Mod4";
      terminal = "${pkgs.kitty}/bin/kitty";
    in
    {
      enable = false;
      wrapperFeatures.gtk = true;
      systemd = {
        enable = true;
        variables = [ "--all" ];
        xdgAutostart = true;
      };
      config = {
        modifier = modifier;
        # Use kitty as default terminal
        terminal = terminal;
        input = {
          "*" = {
            xkb_layout = "br";
            xkb_numlock = "enabled";
          };
        };
        output = {
          DP-1 = {
            # scale = "1.5";
            adaptive_sync = "on";
            # TODO ICC
          };
        };

        floating.criteria = [ { class = "launcher"; } ];
        window = {
          border = 1;
          titlebar = false;
          hideEdgeBorders = "both";
          commands = [
            # {
            #   command = "floating enable";
            #   criteria = {
            #     app_id = "^launcher$";
            #   };
            # }
            {
              command = "focus";
              criteria = {
                app_id = "^launcher$";
              };
            }
          ];
        };
        assigns = {
          "5" = [
            { app_id = "^WebCord$"; }
          ];
          "10" = [
            { app_id = "^org.qbittorrent.qBittorrent$"; }
          ];
        };
        defaultWorkspace = "workspace number 1";

        startup = [
          { command = "${pkgs.telegram-desktop}/bin/telegram-desktop -- %u"; }
          {
            command = "${pkgs.nur.repos.nltch.spotify-adblock}/bin/spotify %U";
          }
          # { command = "${pkgs.qbittorrent}/bin/qbittorrent"; }
          {
            command = "${pkgs.autotiling-rs}/bin/autotiling-rs";
            always = true;
          }
        ];
        bars = [
          {
            fonts = {
              names = [
                "Hack Nerd Font"
                "Font Awesome 6 Free-Regular"
              ];
              style = "Regular";
              size = 12.0;
            };
            position = "top";
            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs config-default";
            colors =
              let
                base = "#191724";
                surface = "#1f1d2e";
                overlay = "#26233a";
                muted = "#6e6a86";
                subtle = "#908caa";
                text = "#e0def4";
                love = "#eb6f92";
                gold = "#f6c177";
                rose = "#ebbcba";
                pine = "#31748f";
                foam = "#9ccfd8";
                iris = "#c4a7e7";
                highlightlow = "#21202e";
                highlightmed = "#403d52";
                highlighthigh = "#524f67";
              in
              {
                # activeWorkspace = ;
                background = base;
                # bindingMode = ;
                # focusedBackground = ;
                # focusedSeparator = ;
                # focusedBackground = ;
                # focusedWorkspace = ;
                # inactiveWorkspace = ;
                separator = pine;
                # statusline = ;
                urgentWorkspace = {
                  background = base;
                  border = love;
                  text = text;
                };

              };
          }
        ];
        keybindings =
          {
            # Basics
            "${modifier}+Return" = "exec ${terminal}";
            "${modifier}+Shift+q" = "kill";
            "${modifier}+d" =
              "exec ${terminal} --app-id=launcher ${pkgs.sway-launcher-desktop}/bin/sway-launcher-desktop";
            "${modifier}+r" = "mode \"resize\"";
            "alt+tab" = "workspace back_and_forth";

            # Layout
            "${modifier}+b" = "splith";
            "${modifier}+v" = "splitv";
            "${modifier}+s" = "layout stacking";
            "${modifier}+t" = "layout tabbed";
            "${modifier}+e" = "layout toggle split";

            "${modifier}+F" = "fullscreen";
            "${modifier}+Shift+space" = "floating toggle";
            "${modifier}+A" = "focus parent";

            #   # Quick access
            "Print" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot copy anything --notify";
            "${modifier}+Shift+I" = "exec ${terminal} hx /etc/nixos/henriquelay/home.nix";
            "${modifier}+Ctrl+Shift+I" = "exec ${terminal} hx /etc/nixos/configuration.nix";
            "XF86AudioPlay" = "exec playerctl play-pause";
            "XF86AudioNext" = "exec playerctl next";
            "XF86AudioPrev" = "exec playerctl previous";
            # ", XF86AudioRaiseVolume, exec, vol --up"
            # ", XF86AudioLowerVolume, exec, vol --down"
            # ", XF86MonBrightnessUp, exec, bri --up"
            # ", XF86MonBrightnessDown, exec, bri --down"
            # ", XF86Search, exec, launchpad"
            # ", XF86AudioMute, exec, amixer set Master toggle"
            # ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

          }
          # Not a comment, attrset update
          //
            # Focus and move to direction
            builtins.foldl' (acc: elem: acc // elem) { } (
              builtins.attrValues (
                builtins.mapAttrs
                  (
                    direction: key_names:
                    builtins.foldl' (acc: elem: acc // elem) { } (
                      builtins.map (key: {
                        "${modifier}+${key}" = "focus ${direction}";
                        "${modifier}+Shift+${key}" = "move ${direction}";
                      }) key_names
                    )
                  )
                  {
                    # $left is the left home row jey (usually h), defined by default
                    # Left is the left arrow key
                    left = [
                      "h"
                      "Left"
                    ];
                    right = [
                      "l"
                      "Right"
                    ];
                    up = [
                      "k"
                      "Up"
                    ];
                    down = [
                      "j"
                      "Down"
                    ];
                  }
              )
            )
          # Not a comment, attrset update
          //
            # Workspace moves
            builtins.foldl' (acc: elem: acc // elem) { } (
              builtins.genList (
                x:
                let
                  ws =
                    let
                      c = (x + 1) / 10;
                    in
                    builtins.toString (x + 1 - (c * 10));
                in
                {
                  "${modifier}+${ws}" = "workspace number " + toString (x + 1);
                  "${modifier}+Shift+${ws}" = "move container to workspace number " + toString (x + 1);
                }
              ) 10
            );

      };
    };

  home.file = {

    ".config/i3bar-river/config.toml".text = ''
      command = "i3status-rs config-default"

      tags_padding = 8.0
    '';

  };

  wayland.windowManager.hyprland =
    let
      modifier = "SUPER";
      terminal = "${pkgs.kitty}/bin/kitty";
      editor = "${pkgs.helix}/bin/hx";
    in
    {
      enable = true;
      package = null;
      portalPackage = null;
      settings = {
        ## Basics
        input = {
          kb_layout = "br";
          numlock_by_default = "true";
        };
        monitor = [
          # For the main monitor
          # Assumes a 4k monitor
          # fourth arg is the scale factor
          # currently, fractional scaling on Wayland is very good! ...
          "DP-1,preferred,auto,1.5,vrr,1"
          ", preferred, auto, 1" # Fallback monitor rule
        ];
        # ... but not on X. This is specially apparent with games.
        # unscale XWayland
        xwayland.force_zero_scaling = true;
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };
        animation = [
          "workspaces, 0"
          "global, 1, 1, default"
        ];
        general = {
          gaps_in = 0;
          gaps_out = 0;
          resize_on_border = true;
          extend_border_grab_area = 10;
        };
        dwindle = {
          force_split = 0;
        };
        windowrulev2 = [
          # Terminal Launcher rules
          "float, class:^(launcher)$"
          "pin, class:^(launcher)$"
          "stayfocused, class:^(launcher)$"
          "bordersize 10, class:^(launcher)$"
          "dimaround, class:^(launcher)$"
          "rounding 5, class:^(launcher)$"
          "bordercolor ${config.lib.stylix.colors.base01}, class:^(launcher)$"
          # "opacity 0.7, class:^(launcher)$"
          "xray 1, class:^(launcher)$"
          # Fixes
          "stayfocused, class:^(pinentry-)" # fix pinentry losing focus
          "workspace 10 silent, class:^(Nextcloud)$" # Send Nextcloud to workspace 10
        ];
        # Autostart
        exec-once = [
          "[workspace 1 silent] telegram-desktop -- %u"
          "[workspace 1 silent] spotify %U"
          # "[workspace 10 silent] qbittorrent"
          "i3bar-river"
        ];
        ## Binds
        bindm = [
          "${modifier}, mouse:272, movewindow"
          "${modifier}, mouse:273, resizewindow"
        ];
        bindl = [
          # ", XF86AudioRaiseVolume, exec, vol --up"
          # ", XF86AudioLowerVolume, exec, vol --down"
          #", XF86MonBrightnessUp, exec, bri --up"
          #", XF86MonBrightnessDown, exec, bri --down"
          #", XF86Search, exec, launchpad"
          #", XF86AudioMute, exec, amixer set Master toggle"
          #", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioPlay, exec, playerctl play-pause" # the stupid key is called play , but it toggles
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPrev, exec, playerctl previous"
        ];
        bind =
          [
            "${modifier}, D, exec, ${terminal} --app-id=launcher ${pkgs.sway-launcher-desktop}/bin/sway-launcher-desktop"
            "${modifier}, Return, exec, ${terminal}"
            "${modifier}&SHIFT, Q, killactive" # Closes, don't kill (-9) pid despite the name
            "${modifier}, Up, movefocus, u"
            "${modifier}, Down, movefocus, d"
            "${modifier}, Left, movefocus, l"
            "${modifier}, Right, movefocus, r"
            "${modifier}, K, movefocus, u"
            "${modifier}, J, movefocus, d"
            "${modifier}, H, movefocus, l"
            "${modifier}, L, movefocus, r"
            "${modifier}&SHIFT, Up, movewindow, u"
            "${modifier}&SHIFT, Down, movewindow, d"
            "${modifier}&SHIFT, Left, movewindow, l"
            "${modifier}&SHIFT, Right, movewindow, r"
            "${modifier}&SHIFT, K, movewindow, u"
            "${modifier}&SHIFT, J, movewindow, d"
            "${modifier}&SHIFT, H, movewindow, l"
            "${modifier}&SHIFT, L, movewindow, r"
            "${modifier}&SHIFT, SPACE, togglefloating"

            # Shortcuts
            "${modifier}&SHIFT, I, exec, ${terminal} ${editor} /etc/nixos/henriquelay/home.nix"
            "${modifier}&CTRL&SHIFT, I, exec, ${terminal} ${editor} /etc/nixos/configuration.nix"

            "${modifier}, mouse_down, workspace, e-1"
            "${modifier}, mouse_up, workspace, e+1"
            "ALT, TAB, workspace, previous_per_monitor"
            "${modifier}, F, fullscreen, 0"
            ", Print, exec, ${pkgs.grimblast}/bin/grimblast copy area --notify"
          ]
          ++ (
            # workspaces
            # binds ${modifier} + [shift +] {1..10} to [move to] workspace {1..10}
            builtins.concatLists (
              builtins.genList (
                x:
                let
                  ws =
                    let
                      c = (x + 1) / 10;
                    in
                    builtins.toString (x + 1 - (c * 10));
                in
                [
                  "${modifier}, ${ws}, workspace, ${toString (x + 1)}"
                  "${modifier}&SHIFT, ${ws}, movetoworkspacesilent, ${toString (x + 1)}"
                ]
              ) 10
            )
          );
      };
    };

  services.dunst = {
    enable = true;
    iconTheme = {
      package = pkgs.rose-pine-icon-theme;
      name = "rose-pine-icons";
    };
    settings = {
      global = {
        width = "(300, 800)";
        offset = "(5, 5)";

        progress_bar_min_width = 380;
        progress_bar_max_width = 680;
        progress_bar_corner_radius = 2;

        padding = 10;
        horizontal_padding = 10;
        frame_width = 1;
        gap_size = 3;
        # font = "Hack 14";

        enable_recursive_icon_lookup = true;
        corner_radius = 2;
      };
    };
  };

  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.rose-pine-icon-theme;
      name = "rose-pine-icons";
    };
  };

  xdg = {
    desktopEntries = {
      virt-manager = {
        # Fix for virt-manager on wlr
        name = "Virtual Machine Manager (GDK_BACKEND=x11)";
        exec = "env GDK_BACKEND=x11 virt-manager";
        terminal = false;
        categories = [
          "Utility"
          "Emulator"
        ];
      };
    };
  };
}
