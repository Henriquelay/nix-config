{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Cross-platform shell configuration
  imports = [
    ../programs/fish.nix
  ];

  home.shell.enableFishIntegration = config.programs.fish.enable;

  programs = {
    # Starship prompt
    starship = {
      enable = true;
      settings = {
        add_newline = true;
        line_break.disabled = false;
        aws.disabled = true;
      };
    };

    # Fuzzy finder
    fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    # Smart cd replacement
    zoxide = {
      enable = true;
      enableFishIntegration = true;
      options = [
        "--cmd"
        "cd"
      ];
    };

    # Modern ls replacement
    eza = {
      enable = true;
      icons = "auto";
      extraOptions = [
        "--group-directories-first"
        "--header"
      ];
    };

    # File manager
    yazi = {
      enable = true;
      settings = {
        mgr = {
          show_hidden = true;
          sort_by = "mtime";
          sort_dir_first = true;
          sort_reverse = true;
          prepend_keymap = {
            on = [ "C" ];
            run = "plugin ouch";
            desc = "compress with ouch";
          };
        };
        plugin = {
          prepend_previewers =
            let
              archiveMimes = [
                "application/*zip"
                "application/x-tar"
                "application/x-bzip2"
                "application/x-7z-compressed"
                "application/x-rar"
                "application/vnd.rar"
                "application/x-xz"
                "application/xz"
                "application/x-zstd"
                "application/zstd"
                "application/java-archive"
              ];
            in
            map (mime: {
              mime = mime;
              run = "ouch";
            }) archiveMimes;
        };
      };
      plugins = with pkgs.yaziPlugins; {
        ouch = ouch;
      };
    };
  };

  # Cross-platform shell utilities
  home.packages = with pkgs; [
    dust # Better du
    dua # du TUI
    ouch # [de]compression helper
    grc # Generic colouriser
  ];
}
