# systems/personal-laptop/home-manager.nix
{
  pkgs,
  user,
  stateVersion,
  inputs,
  ...
}:
{
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
      pkgs.runelite
      pkgs.beancount
      pkgs.fava
      inputs.context.packages.${pkgs.system}.default
    ];
  };

  wayland.windowManager.hyprland.extraConfig = pkgs.lib.mkForce ''
    monitor=eDP-2,preferred,0x0,1.6
    monitor=eDP-4,1920x1080@165.00,auto,1
    misc {
        vrr = 0
    }

    exec-once = [workspace 1 silent] obsidian
    exec-once = [workspace 2 silent] firefox
  '';
}
