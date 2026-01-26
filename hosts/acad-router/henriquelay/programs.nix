{
  config,
  pkgs,
  ...
}:
{
  # Linux-specific programs and packages only
  # Cross-platform programs are in shared home/profiles/
  imports = [
    ./programs/librewolf.nix
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
    ouch # [de]compression helper
    calibre

    # General programs
    # gogdl # GOG downloading module for heroic
    # heroic # Games launcher
    # jackett
    feh
    grc
    mpv
    # nur.repos.nltch.spotify-adblock
    pear-desktop
    obsidian
    presenterm # markdown slides. Support for typst and latex formulas
    qbittorrent
    telegram-desktop
    # webcord
    webcord-vencord
    bambu-studio

    fae_linux

    # Langs and lang servers. Dev stuff
    # Should most of these be here? Should be handled by a dev shell.
    # I'll keep only the scripting and ones I want quick access to.
    # quarto
    scooter # interactive find-and-replace. Pretty useful.

    slack
    postman # surt
    # Local packages
    # (callPackage ../../packages/notekit.nix {})
  ];

  # Linux-specific programs
  programs = {
    zathura = {
      enable = true;
      extraConfig = "set selection-clipboard clipboard";
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

    i3bar-river = {
      enable = true;
      settings = {
        command = "${pkgs.i3status-rust}/bin/i3status-rs config-default";
        tags_padding = 12.0;
      };
    };

    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-vaapi
      ];
    };
  };

  # Linux-specific services
  services = {
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
