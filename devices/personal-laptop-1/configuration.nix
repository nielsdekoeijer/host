{
  config,
  pkgs,
  user,
  hostName,
  stateVersion,
  lib,
  ...
}:
{
  imports = [
    ../../common/configuration.nix
    ../../common/hardware/nvidia.nix
  ];

  # nvidia
  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };

    # Bus IDs extracted from your earlier kernel logs
    amdgpuBusId = "PCI:5:0:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  # extra
  fonts.packages = with pkgs; [
    corefonts
    vista-fonts
  ];

  # steam
  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  # permanent 16 GB swap file
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16384; 
    }
  ];
}
