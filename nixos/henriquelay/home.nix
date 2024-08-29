{
  config,
  pkgs,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "henriquelay";
  home.homeDirectory = "/home/henriquelay";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.
  nixpkgs.config.allowUnfree = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    # Desktop/WM stuff
    libnotify
    sway-launcher-desktop
    pavucontrol
    hyprcursor
    playerctl
    grimblast
    wineWowPackages.waylandFull
    pcmanfm

    # General programs
    telegram-desktop
    gvfs # For trash support and other stuff like that
    xdg-utils
    poppler
    (nerdfonts.override {fonts = ["Hack"];})
    grc
    webcord
    blueman
    qbittorrent
    jackett
    heroic # Games launcher
    gogdl # GOG downloading module for heroic
    obsidian
    feh
    config.nur.repos.nltch.spotify-adblock

    # Langs and lang servers. Dev stuff
    python312
    ruff-lsp
    pyright
    quarto
    typst
    tinymist
    typstyle
    nil
    alejandra
    rust-analyzer
    rustfmt
    clippy
    nix-your-shell
    marksman # markdown lsp
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/henriquelay/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # If cursors are invisible
    # WLR_NO_HARDWARE_CURSORS = "1";
    # Hint electron apps to use Wayland
    NIXOS_OZONE_WL = "1";
    # Disable window decorator on QT applications
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    TERMINAL = "kitty";
  };

  home.sessionPath = [
    "$HOME/.cargo/bin" # For some stuff interactively installed with `cargo install`
  ];
  stylix = {
    enable = true;
    polarity = "dark";
    image = ./blackpx.jpg; # required for enabling hyprland, I guess
    base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
    cursor.package = pkgs.rose-pine-cursor;
    cursor.name = "BreezeX-RosePine-Linux";
    targets = {
      vscode.enable = false;
      fish.enable = false;
      kitty.enable = false;
      helix.enable = false;
    };
  };

  programs = {
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
          exec Hyprland
        end
      '';
      shellInit = ''
        set -g fish_greeting # Disable greeting
        if command -q nix-your-shell
          nix-your-shell fish | source
        end
      '';
      functions = {
        yy = {
          body = ''
            set tmp (mktemp -t "yazi-cwd.XXXXX")
            yazi $argv --cwd-file="$tmp"
            if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
              builtin cd -- "$cwd"
            end
            rm -f -- "$tmp"
          '';
        };
      };

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
        # TODO can't change with stylix enabled
        # background_alpha = 0.5;
        # alpha = 0.9;
      };
    };

    kitty = {
      enable = true;
      shellIntegration.enableFishIntegration = true;
      theme = "Rosé Pine";
    };

    helix = {
      enable = true;
      defaultEditor = true;
      languages = {
        language = [
          {
            name = "nix";
            formatter.command = "${pkgs.alejandra}/bin/alejandra";
            auto-format = true;
          }
          {
            name = "python";
            language-servers = ["ruff" "pyright"];
            auto-format = true;
          }
          {
            name = "typst";
            language-servers = ["tinymist" "typst-lsp"];
            formatter.command = "${pkgs.typstyle}/bin/typstyle";
            auto-format = true;
          }
        ];

        language-server = {
          ruff.command = "ruff-lsp";
          tinymist.command = "tinymist";
        };
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
        };
      };
    };

    yazi = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        manager = {
          show_hidden = true;
          sort_by = "modified";
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
      };
    };

    gpg = {
      enable = true;
      mutableTrust = true;
      mutableKeys = true;
    };

    pyenv = {
      enable = true;
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
      icons = true;
      extraOptions = [
        "--group-directories-first"
        "--header"
      ];
    };

    hyprlock = {
      enable = true;
      settings = {
        general = {
          grace = 300;
          hide_cursor = true;
        };
        background = {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        };
        input-field = [
          {
            size = "200, 50";
            position = "0, -80";
            monitor = "";
            dots_center = true;
            fade_on_empty = false;
            # TODO use stylix colors
            font_color = "rgb(202, 211, 245)";
            inner_color = "rgb(91, 96, 120)";
            outer_color = "rgb(24, 25, 38)";
            outline_thickness = 5;
            placeholder_text = "Password...";
            shadow_passes = 2;
          }
        ];
      };
    };

    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };
    waybar = {
      enable = true;
      systemd.enable = true;
      systemd.target = "hyprland-session.target";
      settings = {
        waybar = {
          layer = "top";
          position = "top";
          modules-left = [
            "hyprland/workspaces"
            "custom/right-arrow-dark"
          ];

          modules-center = [
            # "custom/left-arrow-dark"
            # "clock#1"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            "hyprland/window"
            "custom/right-arrow-dark"
            "custom/right-arrow-light"
            # "clock#3"
            "custom/right-arrow-dark"
          ];
          modules-right = [
            "custom/left-arrow-dark"
            "mpd"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            "idle_inhibitor"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            "pulseaudio"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            # "network"
            # "custom/left-arrow-light"
            # "custom/left-arrow-dark"
            "disk#root"
            "disk#home"
            "disk#vault"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            "temperature"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            "cpu"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            "memory"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            "clock"
            "custom/left-arrow-light"
            "custom/left-arrow-dark"
            "tray"
          ];

          "custom/left-arrow-dark" = {
            "format" = "";
            "tooltip" = false;
          };
          "custom/left-arrow-light" = {
            "format" = "";
            "tooltip" = false;
          };
          "custom/right-arrow-dark" = {
            "format" = "";
            "tooltip" = false;
          };
          "custom/right-arrow-light" = {
            "format" = "";
            "tooltip" = false;
          };

          clock = {
            interval = 5;
            format = "{:%d/%m %A %T}";
          };

          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = " ";
              deactivated = " ";
            };
            tooltip-format-activated = "Activated. The computer will not idle";
            tooltip-format-deactivated = "Deactivated. The computer may idle";
          };

          "disk#root" = {
            interval = 30;
            format = "/ {percentage_used:2}%";
            path = "/";
          };
          "disk#home" = {
            interval = 30;
            format = "/home {percentage_used:2}%";
            path = "/home";
          };
          "disk#vault" = {
            interval = 30;
            format = "/vault {percentage_used:2}%";
            path = "/vault";
          };

          cpu = {
            interval = 2;
            format = "  {usage}% {load}";
          };

          pulseaudio = {
            format = "{icon}  {volume}%";
            format-bluetooth = "{volume}% {icon}";
            format-icons = {
              "alsa_output.pci-0000_00_1f.3.analog-stereo" = "";
              "alsa_output.pci-0000_00_1f.3.analog-stereo-muted" = "";
              car = "";
              default = ["" ""];
              hands-free = "";
              headphone = "";
              headset = "";
              phone = "";
              phone-muted = "";
              portable = "";
            };
            format-muted = "";
            ignored-sinks = ["Easy Effects Sink"];
            on-click = "pavucontrol";
            scroll-step = 1;
          };
          # "hyprland/workspaces" = { };
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

    nextcloud-client.enable = true;

    hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock"; # avoid starting multiple hyprlock instances.
          before_sleep_cmd = "loginctl lock-session"; # lock before suspend.
          after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
        };
        listener = [
          {
            timeout = 900; # in seconds. 15m
            on-timeout = "notify-send 'Screen off in 30s'"; # command to run when timeout has passed.
            on-resume = "notify-send 'Screen off canceled''"; # command to run when activity is detected after timeout has fired.
          }
          {
            timeout = 930; # 15:30min
            on-timeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
            on-resume = "hyprctl dispatch dpms on"; # screen on when activity is detected after timeout has fired.
          }
          {
            timeout = 3600; # 1h
            on-timeout = "systemctl suspend"; # suspend pc
          }
        ];
      };
    };
  };

  ## WM and visuals

  wayland.windowManager.hyprland = {
    enable = true;
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

      animation = "workspaces,0";

      general = {
        gaps_in = 0;
        gaps_out = 0;
        resize_on_border = true;
        extend_border_grab_area = 10;
      };
      dwindle = {
        force_split = 2;
        no_gaps_when_only = 1;
      };

      "windowrulev2" = [
        # Terminal Launcher rules
        "float, class:^(launcher)$"
        "pin, class:^(launcher)$"
        "stayfocused, class:^(launcher)$"
        "bordersize 10, class:^(launcher)$"
        "dimaround, class:^(launcher)$"
        "rounding 5, class:^(launcher)$"
        "bordercolor ${config.lib.stylix.colors.base01}, class:^(launcher)$"
        "opacity 0.7, class:^(launcher)$"
        "xray 1, class:^(launcher)$"
        # Fixes
        "stayfocused, class:^(pinentry-)" # fix pinentry losing focus
        "workspace 10 silent, class:^(Nextcloud)$" # Send Nextcloud to workspace 0
      ];

      # Autostart
      exec-once = [
        "[workspace 1 silent] telegram-desktop -- %u"
        "[workspace 1 silent] spotify %U"
        "[workspace 10 silent] qbittorrent"
      ];

      ## Binds
      "$mod" = "SUPER";
      "$term" = "kitty";
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
      bindl = [
        #", XF86AudioRaiseVolume, exec, vol --up"
        #", XF86AudioLowerVolume, exec, vol --down"
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
          "$mod, D, exec, $term --app-id=launcher sway-launcher-desktop"
          "$mod, Return, exec, $term"
          "$mod&SHIFT, Q, killactive" # Closes, don't kill pid despite the name
          "$mod, Up, movefocus, u"
          "$mod, Down, movefocus, d"
          "$mod, Left, movefocus, l"
          "$mod, Right, movefocus, r"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod&SHIFT, Up, movewindow, u"
          "$mod&SHIFT, Down, movewindow, d"
          "$mod&SHIFT, Left, movewindow, l"
          "$mod&SHIFT, Right, movewindow, r"
          "$mod&SHIFT, SPACE, togglefloating"
          "$mod&SHIFT, I, exec, $term hx ~/nix-config/nixos/henriquelay/home.nix"
          "$mod&CTRL&SHIFT, I, exec, $term hx ~/nix-config/nixos/configuration.nix"
          "$mod, mouse_down, workspace, e-1"
          "$mod, mouse_up, workspace, e+1"
          "ALT, TAB, workspace, previous_per_monitor"
          "$mod, F, fullscreen, 0"
          ", Print, exec, grimblast copy area"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          builtins.concatLists (builtins.genList (
              x: let
                ws = let
                  c = (x + 1) / 10;
                in
                  builtins.toString (x + 1 - (c * 10));
              in [
                "$mod, ${ws}, workspace, ${toString (x + 1)}"
                "$mod&SHIFT, ${ws}, movetoworkspacesilent, ${toString (x + 1)}"
              ]
            )
            10)
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
        offset = "5x5";

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

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {"x-scheme-handler/tg" = "org.telegram.desktop.desktop";};
  };

  xdg.desktopEntries = {
    virt-manager = {
      # Fix for virt-manager on wlr
      name = "Virtual Machine Manager (GDK_BACKEND=x11)";
      exec = "env GDK_BACKEND=x11 virt-manager";
      terminal = false;
      categories = ["Utility" "Emulator"];
    };
  };

  # TODO mimetypes and portal, open files on yazi
  xdg.portal = {
    enable = true;
    configPackages = [pkgs.xdg-desktop-portal-hyprland];
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
  };
}
