{ config, pkgs, ... }:
{
  home.packages = with pkgs; [ wl-gammarelay-rs ];
  programs.i3status-rust = {
    enable = true;
    bars = {
      default = {
        theme = "gruvbox-dark";
        icons = "material-nf";

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
            block = "amd_gpu";
            format_alt = " $icon MEM: $vram_used_percents ($vram_used/$vram_total) ";
            icons_overrides = {
              gpu = "󰾲";
            };
          }
          {
            block = "music";
            player = "playerctld";
            format = " $icon {$combo.str(max_w:25,rot_interval:0.5) $play $next |}";
          }
          {
            block = "sound";
            show_volume_when_muted = true;
          }
          # {
          #   block = "keyboard_layout";
          #   driver = "sway";
          #   format = "🖮 $layout ($variant)";
          # }
          {
            block = "net";
            device = "enp14s0";
            format = " $icon ↓$speed_down ↑$speed_up";
            format_alt = "$icon ↓$graph_down ↑$graph_up";
          }
          {
            block = "custom";
            format = " 󱎴 |$text.pango-str()";
            # merge_with_next = true;
            command = "ddcutil getvcp 10 | grep -oP 'current value =\s*\K\d+'";
            click = [
              {
                button = "wheel_up";
                cmd = "ddcutil setvcp + 10";
                sync = true;
              }
              {
                button = "wheel_down";
                cmd = "ddcutil setvcp - 10";
                sync = true;
              }
            ];
          }
          {
            block = "hueshift";
            click_temp = 2500;
          }
          {
            block = "privacy";
            driver = [
              { name = "pipewire"; }
              { name = "v4l"; }
            ];
          }
          # {
          #   block = "weather";
          #   format = " $icon $weather $temp";
          #   service = {
          #     name = "openweathermap";
          #     api_key = "4d8b9e3c0cd2b311891fc18f52493a6e";
          #     city_id = "3445026";
          #     units = "metric";
          #   };
          # }
          {
            block = "time";
            interval = 1;
            format = " $timestamp.datetime(f:'%a %d/%m %R:%S')";
          }
        ];
      };
    };
  };
}
