# systems/development-laptop/home-manager.nix
{
  pkgs,
  user,
  stateVersion,
  ...
}:
{
  imports = [ ../../common/home-manager.nix ];

  home = {
    username = user;
    stateVersion = stateVersion;

    packages = [
      pkgs.audacity
      pkgs.qpwgraph
      pkgs.libreoffice
      pkgs.wf-recorder
      pkgs.gemini-cli
      pkgs.perf
      pkgs.croc
    ];
  };

  # monitor at work
  wayland.windowManager.hyprland.extraConfig = pkgs.lib.mkForce ''
    monitor=eDP-1,preferred,auto,1
    monitor=DP-8,preferred,auto,1
  '';
}
