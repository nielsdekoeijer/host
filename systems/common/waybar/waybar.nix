{ pkgs, ... }: {
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        position = "top";
        modules-left = [ "hyprland/workspaces" ];
        modules-right = [ "network" "cpu" "memory" "battery" "clock" ];
        tray = { spacing = 10; };
        network = { format = "{essid} {ipaddr}"; };
        cpu = { format = "CPU: {usage}%"; };
        memory = { format = "MEM: {}%"; };
        battery = { format = "BAT: {capacity}%"; };
        clock = { format = "{:%I:%M}"; };
      };
    };

    style = ''
      * { 
        font-family: "FantasqueSansM Nerd Font"; 
        font-weight: bold;
        border: none;
        border-radius: 0;
        font-size: 16px;
        min-height: 0;
      }

      window#waybar {
        background-color: rgba(0, 0, 0, 0.9);
        color: #ffffff;
      }

      #workspaces button {
        box-shadow: inset 0 -3px transparent;
        color: #ffffff;
      }

      #workspaces button.active {
        background-color: #64727D;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #network,
      #tray {
        padding: 0px 10px;
        margin: 6px 3px;
        color: #ffffff;
      }
    '';
  };
}
