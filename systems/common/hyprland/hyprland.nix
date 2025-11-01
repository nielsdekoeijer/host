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
        "$mainMod" = "$mod";
        layout = "dwindle";
        gaps_in = 5;
        gaps_out = 10;
        border_size = 1;
      };

      # no rounding
      decoration = { rounding = 0; };

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
        "$mainMod, Q, exec, $terminal"
        "$mainMod, C, killactive"
        "$mainMod, M, exec, exit"
        "$mainMod, R, exec, $menu"
        "$mainMod, S, exec, togglesplit"
        "$mainMod, H, movefocus, l"
        "$mainMod, L, movefocus, r"
        "$mainMod, K, movefocus, u"
        "$mainMod, J, movefocus, d"

        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"

        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
      ];
    };

    extraConfig = ''
      monitor=eDP-1,preferred,auto,1.0
      monitor=,preferred,auto,1.0,mirror,eDP-1
    '';
  };
}
