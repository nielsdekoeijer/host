{ pkgs, ... }:
{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        position = "top";
        magin = "10 10";
        margin-top = 10;
        margin-left = 10;
        margin-right = 10;
        modules-left = [ "hyprland/workspaces" ];
        modules-right = [
          "network"
          "cpu"
          "memory"
          "battery"
          "clock"
          "tray"
        ];
        "hyprland/workspaces" = {
          format = "{name}";
        };
        tray = {
          spacing = 10;
        };
        network = {
          format = "󰤥  {essid}";
          format-disconnected = "󰤮  Disconnected";
          tooltip-format = "{ifname} via {gwaddr} ";
          tooltip-format-wifi = "{essid} ({signalStrength}%) ";
          tooltip-format-ethernet = "{ifname} ";
          tooltip-format-disconnected = "Disconnected";
          on-click = "nm-connection-editor";
        };
        cpu = {
          format = "  {usage}%";
        };
        memory = {
          format = "󰍛  {}%";
        };
        battery = {
          format = "  {capacity}%";
        };
        clock = {
          format = "  {:%I:%M %p}";
        };
      };
    };

    style = ''
      * {
        font-family: "FantasqueSansM Nerd Font";
        font-weight: bold;
        border: none;
        border-radius: 0; /* Set to 8px or so if you want rounded corners */
        font-size: 16px;
        min-height: 0;
      }

      /* === Main Bar === */
      window#waybar {
        background-color: rgba(33, 28, 47, 0.8);;
        color: #e7d3fb; /* Bright White */
        border: 1px solid #ffffff;
        transition-property: background-color;
        transition-duration: .5s;
      }

      /* === Workspaces === */
      #workspaces button {
        padding: 0px 10px;
        margin: 6px 3px;
        color: #645775; /* Dim color for inactive */
      }

      #workspaces button.active {
        background-color: #3f4060; /* Selection background */
        color: #e7d3fb; /* Bright White */
      }

      #workspaces button:hover {
        background-color: #3f4060;
      }

      /* === Modules === */
      #clock,
      #battery,
      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #tray {
        padding: 0px 10px;
        margin: 6px 3px;
      }

      /* Color-code modules with theme accents */
      #clock {
        color: #ecc48d; /* Yellow */
      }

      #battery {
        color: #addb67; /* Green */
      }

      #battery.warning, #battery.critical, #battery.danger {
        color: #ff5874; /* Red */
      }

      #cpu {
        color: #ff5874; /* Red */
      }

      #memory {
        color: #be9af7; /* Purple */
      }

      #network {
        color: #54CED6; /* Cyan */
      }

      #network.disconnected {
        color: #645775; /* Dim */
      }

      #tray {
        color: #e7d3fb;
      }
    '';
  };
}
