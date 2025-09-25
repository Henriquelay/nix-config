{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./programs/fish.nix
    ./programs/git.nix
    ./programs/helix.nix
    ./programs/kitty.nix
    ./programs/vscode.nix
    ./programs/librewolf.nix
    ./programs/rclone.nix
    ./wm/hyprland.nix
    ./wm/sway.nix
    ./wm/i3status-rust.nix
  ];

  home.packages = with pkgs; [
    # Desktop/WM stuff
    sway-launcher-desktop
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    slurp # For screencapture. Needed from xdg-desktop-portal-wlr
    # wf-recorder

    # System utilities
    blueman
    gvfs # For trash support and other stuff like that
    libnotify
    pavucontrol
    playerctl
    poppler
    xdg-utils
    xcb-util-cursor # for Nextcloud-client
    qpwgraph
    unzip
    dust # Better `du`
    dua # `du` TUI
    _7zz

    # General programs
    # gogdl # GOG downloading module for heroic
    # heroic # Games launcher
    # jackett
    feh
    grc
    mpv
    nur.repos.nltch.spotify-adblock
    youtube-music
    obsidian
    presenterm # markdown slides. Support for typst and latex formulas
    qbittorrent
    telegram-desktop
    webcord

    fae_linux

    # Langs and lang servers. Dev stuff
    # Should most of these be here? Should be handled by a dev shell.
    # I'll keep only the scripting and ones I want quick access to.
    # quarto
    scooter # interactive find-and-replace. Pretty useful.

    # slack
    postman # surt

    # Local packages
    # (callPackage ../../packages/notekit.nix {})
  ];

  programs = {
    home-manager.enable = true;

    bat.enable = true;
    ripgrep.enable = true;
    jq.enable = true;
    fd.enable = true;
    zathura = {
      enable = true;
      extraConfig = ''set selection-clipboard clipboard'';
    };
    bottom.enable = true;
    bacon.enable = true;

    starship = {
      enable = true;
      enableFishIntegration = true;
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

    yazi = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        mgr = {
          show_hidden = true;
          sort_by = "mtime";
          sort_dir_first = true;
          sort_reverse = true;
        };
      };
    };

    i3bar-river = {
      enable = true;
      settings = {
        command = "${pkgs.i3status-rust}/bin/i3status-rs config-default";
        tags_padding = 12.0;
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
      enable = false; # Replaced by skim
      enableFishIntegration = true;
    };

    skim = {
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
  };

  services = {
    gpg-agent = {
      enable = true;
      enableFishIntegration = true;
      defaultCacheTtl = 604800; # 1 week
      enableSshSupport = true;
      pinentry.package = pkgs.pinentry-gtk2;
      extraConfig = ''
        debug-pinentry
      '';
    };

    syncthing.enable = true;

    udiskie = {
      enable = true;
      settings = {
        # workaround for
        # https://github.com/nix-community/home-manager/issues/632
        program_options = {
          # replace with your favorite file manager
          file_manager = "${pkgs.kitty}/bin/kitty ${pkgs.yazi}/bin/yazi";
        };
      };
    };

    nextcloud-client = {
      enable = true;
      startInBackground = true;
    };

    dunst = {
      enable = true;
      iconTheme = {
        package = pkgs.gruvbox-dark-icons-gtk;
        name = "gruvbox-dark-gtl";
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

          enable_recursive_icon_lookup = true;
          corner_radius = 2;
        };
      };
    };
  };
}
