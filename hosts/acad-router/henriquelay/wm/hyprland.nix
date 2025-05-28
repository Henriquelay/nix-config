{
  config,
  pkgs,
  lib,
  ...
}:
let
  enable = true;

  modifier = "SUPER";
  terminal = "${pkgs.kitty}/bin/kitty";
  editor = "${pkgs.helix}/bin/hx";
in
{
  programs.fish.loginShellInit = lib.mkIf enable ''
    if [ (tty) = "/dev/tty1" ]
      exec Hyprland &> ~/hyprland_output.log
    end
  '';

  wayland.windowManager.hyprland = {
    enable = enable;
    package = null;
    portalPackage = null;
    settings = {
      input = {
        kb_layout = "br";
        numlock_by_default = "true";
      };
      monitor = [
        "DP-1,preferred,auto,1.5,vrr,1"
        ", preferred, auto, 1"
      ];
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
        gaps_out = -1;
        resize_on_border = true;
        extend_border_grab_area = 10;
      };
      dwindle = {
        force_split = 0;
      };
      windowrulev2 = [
        "float, class:^launcher$"
        "pin, class:^launcher$"
        "stayfocused, class:^launcher$"
        "bordersize 10, class:^launcher$"
        "dimaround, class:^launcher$"
        "rounding 5, class:^launcher$"
        "bordercolor ${config.lib.stylix.colors.base01}, class:^launcher$"
        "xray 1, class:^launcher$"
        "stayfocused, class:^(pinentry-)"
        "workspace 10 silent, class:^(Nextcloud)$"
      ];
      exec-once = [
        "[workspace 1 silent] telegram-desktop -- %u"
        "[workspace 1 silent] spotify %U"
        "i3bar-river"
      ];
      bindm = [
        "${modifier}, mouse:272, movewindow"
        "${modifier}, mouse:273, resizewindow"
      ];
      bindl = [
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];
      bind =
        [
          "${modifier}, D, exec, ${terminal} --app-id=launcher ${pkgs.sway-launcher-desktop}/bin/sway-launcher-desktop"
          "${modifier}, Return, exec, ${terminal}"
          "${modifier}&SHIFT, Q, killactive"
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
          "${modifier}&SHIFT, I, exec, ${terminal} ${editor} /etc/nixos/henriquelay/home.nix --working-dir /etc/nixos/henriquelay"
          "${modifier}&SHIFT, O, exec, ${terminal} ${editor} ~/Notes"
          "${modifier}&CTRL&SHIFT, I, exec, ${terminal} ${editor} /etc/nixos/configuration.nix --working-dir /etc/nixos"
          "${modifier}, mouse_down, workspace, e-1"
          "${modifier}, mouse_up, workspace, e+1"
          "ALT, TAB, workspace, previous_per_monitor"
          "${modifier}, F, fullscreen, 0"
          ", Print, exec, ${pkgs.grimblast}/bin/grimblast copy area --notify"
        ]
        ++ (builtins.concatLists (
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
        ));
    };
  };
}
