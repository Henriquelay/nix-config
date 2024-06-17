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
  home.stateVersion = "23.05"; # Please read the comment before changing.
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

    libnotify
    sway-launcher-desktop
    nil
    alejandra
    pavucontrol
    telegram-desktop
    python312
    hyprcursor
    playerctl
    xfce.thunar
    xfce.thunar-volman
    xfce.thunar-archive-plugin
    poppler
    (nerdfonts.override {fonts = ["Hack"];})
    quarto
    typst
    gvfs # For trash support and other stuff like that
    xdg-utils
    grc
    #nur.repos.nltch.spotify-adblock # on flake
    grimblast
    webcord
    blueman
    mangohud
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
    EDITOR = "hx";
    # If cursors are invisible
    #WLR_NO_HARDWARE_CURSORS = "1";
    # Hint electron apps to use Wayland
    NIXOS_OZONE_WL = "1";

    # Disable window decorator on QT applications
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
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
        set fish_greeting # Disable greeting
        if [ (tty) = "/dev/tty1" ]
          exec Hyprland
        end
      '';

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

    kitty = {
      enable = true;
      shellIntegration.enableFishIntegration = true;
      theme = "Rosé Pine";
    };

    helix = {
      enable = true;
      languages.language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.alejandra}/bin/alejandra";
        }
      ];
      settings = {
        editor.cursor-shape.insert = "bar";
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
    zathura.enable = true;
    poetry.enable = true;
    bottom.enable = true;
    librewolf = {
      enable = true;
      settings = {
        "webgl.disabled" = false;
        "identity.fxaccounts.enabled" = true;
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
    };

    #eza = {
    #  enable = true;
    #  enableFishIntegration = true;
    #  icons = true;
    #};

    hyprlock = {
      enable = true;
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      enableFishIntegration = true;
      defaultCacheTtl = 10080; # 1 week
      enableSshSupport = true;
      pinentryPackage = pkgs.pinentry-tty;
      extraConfig = ''
        debug-pinentry
      '';
    };

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
            timeout = 300; # in seconds.
            on-timeout = "notify-send 'Screen off in 30s'"; # command to run when timeout has passed.
            on-resume = "notify-send 'Welcome back!'"; # command to run when activity is detected after timeout has fired.
          }
          {
            timeout = 330; # 5.5min
            on-timeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
            on-resume = "hyprctl dispatch dpms on"; # screen on when activity is detected after timeout has fired.
          }
          {
            timeout = 330; # 5.5min
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 1800; # 30min
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
      # Assumes a 4k monitor
      # change monitor to high resolution, the last argument is the scale factor
      # currently, fractional scaling on Wayland is very good! ...
      monitor = ",highres,auto,1.5";
      # ... but not on X. This is specially apparent with games.
      # unscale XWayland
      xwayland.force_zero_scaling = true;

      ## Style
      # name: Rosé Pine
      # author: jishnurajendran
      # upstream: https://github.com/jishnurajendran/hyprland-rosepine/blob/main/rose-pine.conf
      # All natural pine, faux fur and a bit of soho vibes for the classy minimalist
      "$base" = "0xff191724";
      "$surface" = "0xff1f1d2e";
      "$overlay" = "0xff26233a";
      "$muted" = "0xff6e6a86";
      "$subtle" = "0xff908caa";
      "$text" = "0xffe0def4";
      "$love" = "0xffeb6f92";
      "$gold" = "0xfff6c177";
      "$rose" = "0xffebbcba";
      "$pine" = "0xff31748f";
      "$foam" = "0xff9ccfd8";
      "$iris" = "0xffc4a7e7";
      "$highlightLow" = "0xff21202e";
      "$highlightMed" = "0xff403d52";
      "$highlightHigh" = "0xff524f67";
      ##
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
      "env" = ["HYPRCURSOR_SIZE,24" "HYPRCURSOR_THEME,hypr-rose-pine-dawn-cursor"];

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
          "$mod&SHIFT, Q, killactive" # Closes, don't kill despite the name
          "$mod, Up, movefocus, u"
          "$mod, Down, movefocus, d"
          "$mod, Left, movefocus, l"
          "$mod, Right, movefocus, r"
          "$mod&SHIFT, Up, movewindow, u"
          "$mod&SHIFT, Down, movewindow, d"
          "$mod&SHIFT, Left, movewindow, l"
          "$mod&SHIFT, Right, movewindow, r"
          "$mod&SHIFT, SPACE, togglefloating"
          "$mod&SHIFT, I, exec, $term home-manager edit"
          "$mod&CTRL&SHIFT, I, exec, $term hx ~/nix-config/nixos/configuration.nix"
          "$mod, mouse_down, workspace, e-1"
          "$mod, mouse_up, workspace, e+1"
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
        width = 400;
        offset = "5x5";

        progress_bar_min_width = 380;
        progress_bar_max_width = 380;
        progress_bar_corner_radius = 2;

        padding = 10;
        horizontal_padding = 10;
        frame_width = 1;
        gap_size = 3;
        font = "Monospace 14";

        enable_recursive_icon_lookup = true;
        corner_radius = 2;

        background = "#26233a";
        foreground = "#e0def4";
      };
      urgency_low = {
        background = "#26273d";
        highlight = "#31748f";
        frame_color = "#31748f";
        default_icon = "dialog-information";
        format = "<b><span foreground='#31748f'>%s</span></b>\n%b";
      };
      urgency_normal = {
        background = "#362e3c";
        highlight = "#f6c177";
        frame_color = "#f6c177";
        default_icon = "dialog-warning";
        format = "<b><span foreground='#f6c177'>%s</span></b>\n%b";
      };
      urgency_critical = {
        background = "#35263d";
        highlight = "#eb6f92";
        frame_color = "#eb6f92";
        default_icon = "dialog-error";
        format = "<b><span foreground='#eb6f92'>%s</span></b>\n%b";
      };
    };
  };

  #home.pointerCursor = {
  #  gtk.enable = true;
  #  # x11.enable = true;
  #  package = pkgs.rose-pine-cursor;
  #  name = "rose-pine-dawn-cursor";
  #  size = 18;
  #};

  gtk = {
    enable = true;
    theme = {
      package = pkgs.rose-pine-gtk-theme;
      name = "rose-pine-gtk";
    };

    iconTheme = {
      package = pkgs.rose-pine-icon-theme;
      name = "rose-pine-icons";
    };

    font = {
      name = "Sans";
      size = 11;
    };
  };

  # TODO mimetypes and portal
  #xdg.portal = {
  #  enable = true;
  #  extraPortals = pkgs.xdg-desktop-portal-wayland;
  #};
}
