{ config, pkgs, ... }:
{
  programs.rclone = {
    enable = true;
  };
}
