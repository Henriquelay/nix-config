{
  # config,
  pkgs,
  ...
}:
let

  sway-import-script = pkgs.writeShellApplication {
    name = "sway-import-script.sh";
    text = ''
      # systemctl --user set-environment "WAYLAND_DISPLAY=wayland-1" "XDG_CURRENT_DESKTOP=sway" "XDG_RUNTIME_DIR=/run/user/$(id -u)"
      #   # Import the WAYLAND_DISPLAY env var from sway into the d user session.
      #   dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway "XDG_RUNTIME_DIR=/run/user/$(id -u)"

        # Stop any services that are running, so that they receive the new env var when they restart.
        # systemctl --user stop pipewire wireplumber xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-hyprland
        # systemctl --user start wireplumber xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-hyprland

        # systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
        # dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
        dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP XDG_SESSION_TYPE NIXOS_OZONE_WL XCURSOR_THEME XCURSOR_SIZE; systemctl --user reset-failed && systemctl --user start sway-session.target && swaymsg -mt subscribe '[]' || true && systemctl --user stop sway-session.target
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
      sway-import-script
      pavucontrol
      playerctl
      sway-contrib.grimshot

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
      # slurp # For screencapture. Needed from xdg-desktop-portal-wlr

      # Langs and lang servers. Dev stuff
      # Should most of these be here? Should be handled by a dev shell.
      # I'll keep only the scripting and ones I want quick access to.
      helix-gpt
      taplo # TOML
      # python313
      ruff-lsp
      pyright
      # quarto
      # typst
      # tinymist
      # typstyle
      nil
      nixfmt-rfc-style
      rust-analyzer
      rustfmt
      clippy
      nix-your-shell
      # marksman # markdown lsp
      markdown-oxide
      # ltex-ls
      # texlab

      slack

      # Local packages
      # (callPackage ../../packages/notekit.nix {})
    ];

    file = {
    };

    sessionVariables = {
      # If cursors are invisible
      # WLR_NO_HARDWARE_CURSORS = "1";
      # Hint electron apps to use Wayland
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "sway";
      XDG_CURRENT_DESKTOP = "sway";
      GTK_USE_PORTAL = "1";
      # WAYLAND_DISPLAY = "wayland-1";
      # Disable window decorator on QT applications
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      TERMINAL = "${pkgs.kitty}/bin/kitty";
      sponge_purge_only_on_exit = "1";
    };

    sessionPath = [
      "$HOME/.cargo/bin" # For some stuff interactively installed with `cargo install`
    ];

  };
  stylix = {
    enable = true;
    polarity = "dark";
    # image = ./blackpx.jpg; # required for enabling hyprland, I guess
    base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
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
          exec dbus-run-session sway &> ~/sway_output.log
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
      enableSessionWide = false;
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
      themeFile = "rose-pine";
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
            ];
          }
        ];
      };
      settings = {
        theme = "rose_pine";
        editor = {
          color-modes = true;
          popup-border = "all";
          line-number = "relative";
          bufferline = "multiple";
          cursor-shape.insert = "bar";
          auto-format = true;
          soft-wrap.enable = true;
          cursorline = true;
          end-of-line-diagnostics = "hint";
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
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
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
      package = pkgs.vscode.fhs;
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
      enable = true;
      wrapperFeatures.gtk = true;
      # This needs to call a script because sway's execs are parallel and we want sequential
      extraConfigEarly = ''
        exec ${pkgs.lib.getExe sway-import-script}
      '';
      systemd = {
        enable = true;
        # variables = [ "--all" ];
        # xdgAutostart = true;
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

        gaps = {
          # smartGaps = true;
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
    # TODO mimetypes and portal, open files on yazi (xdg-desktop-portal-termfilechooser)
    portal = {
      enable = true;
      config = {
        # common = {
        #   default = [
        #     "gtk"
        #     "wlr"
        #   ];
        #   "org.freedesktop.impl.portal.ScreenCast" = "wlr";
        # };
        sway = {
          default = [
            "gtk"
            "wlr"
          ];
          "org.freedesktop.impl.portal.ScreenCast" = "wlr";
          "org.freedesktop.impl.portal.Screenshot" = "wlr";
          # xdg-desktop-portal-gtk's implementation uses org.gnome.SessionManager and
          # org.freedesktop.ScreenSaver, neither of which is implemented by Sway. This
          # will cause some programs (e.g. Firefox) to use Wayland's idle-inhibit
          # protocol instead, which sway does implement.
          "org.freedesktop.impl.portal.Inhibit" = "none";
        };
      };
      # configPackages = with pkgs; [
      #   xdg-desktop-portal-wlr
      # ];
      extraPortals = with pkgs; [
        # xdg-desktop-portal-hyprland
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
      #     xdgOpenUsePortal = true;
    };
  };
}
