# systems/personal-laptop/home-manager.nix
{ pkgs, user, stateVersion, ... }: {
  imports = [
    ../../common/home-manager.nix
  ];

  home = {
    username = user;
    stateVersion = stateVersion;

    packages = [
      pkgs.audacity
      pkgs.discord
      pkgs.obsidian
      pkgs.wofi
    ];
  };

  wayland.windowManager.hyprland.extraConfig = pkgs.lib.mkForce ''
    monitor=eDP-2,preferred,0x0,1.6
    monitor=eDP-4,1920x1080@165.00,auto,1
    misc {
        vrr = 0
    }
  '';
}
