{
  config,
  pkgs,
  lib,
  ...
}:
let
  enable = true;

  modifier = "Mod4";
  terminal = "${pkgs.kitty}/bin/kitty";

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
  programs.fish.loginShellInit = lib.mkIf enable ''
    if [ (tty) = "/dev/tty1" ]
      exec dbus-run-session sway &> ~/sway_output.log
    end
  '';

  home.packages = with pkgs; [
    sway-contrib.grimshot # Sway specific features
    sway-launch
  ];

  wayland.windowManager.sway = {
    enable = enable;
    wrapperFeatures.gtk = true;
    systemd = {
      enable = true;
      variables = [ "--all" ];
      xdgAutostart = true;
    };
    config = {
      modifier = modifier;
      terminal = terminal;
      input = {
        "*" = {
          xkb_layout = "br";
          xkb_numlock = "enabled";
        };
      };
      output = {
        DP-1 = {
          adaptive_sync = "on";
        };
      };
      floating.criteria = [
        { app_id = "launcher"; }
        { window_role = "pop-up"; }
        { window_role = "About"; }
      ];
      window = {
        border = 1;
        titlebar = false;
        hideEdgeBorders = "both";
        commands = [
          {
            command = "focus";
            criteria = {
              app_id = "^launcher$";
            };
          }
        ];
      };
      assigns = {
        "5" = [ { app_id = "^WebCord$"; } ];
        "10" = [ { app_id = "^org.qbittorrent.qBittorrent$"; } ];
      };
      defaultWorkspace = "workspace number 1";
      startup = [
        { command = "telegram-desktop -- %u"; }
        { command = "spotify %U"; }
        {
          command = "${pkgs.autotiling-rs}/bin/autotiling-rs";
          # always = true;
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
              bg = "#282828";
              red = "#cc241d";
              yellow = "#d79921";
              aqua = "#689d68";
              darkgray = "#1d2021";
            in
            {
              background = bg;
              statusline = yellow;
              separator = red;
              focusedWorkspace = {
                background = aqua;
                border = aqua;
                text = darkgray;
              };
              inactiveWorkspace = {
                background = darkgray;
                border = darkgray;
                text = yellow;
              };
              activeWorkspace = {
                background = darkgray;
                border = darkgray;
                text = yellow;
              };
              urgentWorkspace = {
                background = red;
                border = red;
                text = bg;
              };
            };
        }
      ];
      keybindings =
        {
          "${modifier}+Return" = "exec ${terminal}";
          "${modifier}+Shift+q" = "kill";
          "${modifier}+d" =
            "exec ${terminal} --app-id=launcher ${pkgs.sway-launcher-desktop}/bin/sway-launcher-desktop";
          "${modifier}+r" = "mode \"resize\"";
          "alt+tab" = "workspace back_and_forth";
          "${modifier}+b" = "splith";
          "${modifier}+v" = "splitv";
          "${modifier}+s" = "layout stacking";
          "${modifier}+t" = "layout tabbed";
          "${modifier}+e" = "layout toggle split";
          "${modifier}+F" = "fullscreen";
          "${modifier}+Shift+space" = "floating toggle";
          "${modifier}+A" = "focus parent";
          "Print" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot copy anything --notify";
          "${modifier}+Shift+I" =
            "exec ${terminal} hx /etc/nixos/henriquelay/home.nix --working-dir /etc/nixos/henriquelay";
          "${modifier}+Ctrl+Shift+I" =
            "exec ${terminal} hx /etc/nixos/configuration.nix --working-dir /etc/nixos";
          "${modifier}+Shift+O" = "exec ${terminal} hx ~/Notes";
          "XF86AudioPlay" = "exec playerctl play-pause";
          "XF86AudioNext" = "exec playerctl next";
          "XF86AudioPrev" = "exec playerctl previous";
        }
        // builtins.foldl' (acc: elem: acc // elem) { } (
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
        // builtins.foldl' (acc: elem: acc // elem) { } (
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
}
