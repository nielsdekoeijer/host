# systems/development-laptop/home-manager.nix
{
  pkgs,
  user,
  stateVersion,
  inputs,
  ...
}:
let

in
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
      pkgs.uv
      pkgs.gh

      # log viewer
      inputs.lazylog.packages.${pkgs.system}.default
      inputs.context.packages.${pkgs.system}.default
      inputs.remote-helvum.packages.${pkgs.system}.default
      inputs.openconnect-sso.packages.${pkgs.system}.openconnect-sso
    ];
  };

  # monitor at work
  wayland.windowManager.hyprland.extraConfig = pkgs.lib.mkForce ''
    monitor=eDP-1,preferred,auto,1
    monitor=DP-8,preferred,auto,1
  '';
}
