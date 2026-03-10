{ config, pkgs, ... }:
let
  beoguard = pkgs.writeShellScriptBin "beoguard" ''
    case "$1" in
      up)
        echo "Starting Beoguard (wg0)..."
        sudo systemctl start wg-quick-wg0.service
        ;;
      down)
        echo "Stopping Beoguard (wg0)..."
        sudo systemctl stop wg-quick-wg0.service
        ;;
      status)
        systemctl status wg-quick-wg0.service
        ;;
      *)
        echo "Usage: beoguard {up|down|status}"
        exit 1
        ;;
    esac
  '';
in
{
  environment.systemPackages = [ 
    pkgs.wireguard-tools 
    beoguard 
  ];
  
  networking.firewall.checkReversePath = "loose";
  age.identityPaths = [ "/home/niels/.ssh/agenix" ]; 
  age.secrets.wg_bo_config.file = ./wg0.age;
  
  networking.wg-quick.interfaces.wg0 = {
    autostart = false; 
    configFile = config.age.secrets.wg_bo_config.path;
  };
}
