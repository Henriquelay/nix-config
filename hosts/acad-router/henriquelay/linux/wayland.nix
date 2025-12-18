{ config, pkgs, lib, ... }:
{
  # Wayland-specific session variables for Linux
  home.sessionVariables = {
    # Hint electron apps to use Wayland
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    # Disable window decorator on QT applications
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };
}
