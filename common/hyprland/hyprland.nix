{ pkgs, ... }:
let
  wallpaper = ./wallpaper.jpg;
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {

      # on start
      exec-once = [
        "hyprctl setcursor Bibata-Modern-Ice 16"
        "waybar &"
        "swww-daemon &"
        "swww img ${wallpaper}"
      ];

      # default programs
      "$mod" = "SUPER";
      "$terminal" = "ghostty";
      "$menu" = "wofi --show drun";

      # set super + looks
      general = {
        layout = "dwindle";
        gaps_in = 5;
        gaps_out = 10;
        border_size = 1;
      };

      # no rounding
      decoration = {
        rounding = 0;
      };

      # disable anime girl
      misc = {
        "force_default_wallpaper" = 0;
        "disable_hyprland_logo" = "true";
        vrr = 1;
      };

      animations = {
        enabled = true;

        # define a snappy bezier curve (starts fast, eases out)
        bezier = [ "snappy, 0.16, 1, 0.3, 1" ];

        # apply the curve to different animations with a fast duration
        animation = [
          "windows, 1, 3, snappy, gnomed"
          "windowsMove, 1, 3, snappy, gnomed"
          "workspaces, 1, 3, snappy, fade"
          "specialWorkspace, 1, 3, snappy, fade"

          "border, 1, 3, snappy"
          "borderangle, 1, 3, snappy"

          "fadeIn, 1, 3, snappy"
          "fadeOut, 1, 3, snappy"
        ];
      };

      # bindings for hyprland
      bind = [
        "$mod, Q, exec, $terminal"
        "$mod, C, killactive"
        "$mod, M, exec, exit"
        "$mod, R, exec, $menu"
        "$mod, S, exec, togglesplit"
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"

        "$mod SHIFT, F, togglefloating"
        "$mod SHIFT, H, swapwindow, l"
        "$mod SHIFT, L, swapwindow, r"
        "$mod SHIFT, K, swapwindow, u"
        "$mod SHIFT, J, swapwindow, d"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
      ];
    };

    extraConfig = ''
      monitor=eDP-1,preferred,auto,1.0
      monitor=,preferred,auto,1.0,mirror,eDP-1
      # monitor=,preferred,auto,1
    '';
  };
}
