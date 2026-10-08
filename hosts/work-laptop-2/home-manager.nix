# systems/development-laptop/home-manager.nix
{
  pkgs,
  user,
  stateVersion,
  inputs,
  ...
}:
let
  openconnect-sso = inputs.openconnect-sso.packages.${pkgs.system}.openconnect-sso;
  openconnect-sso-qtwayland =
    inputs.nixpkgs-openconnect-sso.legacyPackages.${pkgs.system}.qt6.qtwayland;
  openconnect-sso-wayland = pkgs.symlinkJoin {
    name = "openconnect-sso-wayland";
    paths = [ openconnect-sso ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/openconnect-sso \
        --set QT_QUICK_BACKEND software \
        --set QT_QPA_PLATFORM wayland \
        --prefix QT_PLUGIN_PATH : "${openconnect-sso-qtwayland}/lib/qt-6/plugins"
    '';
  };
in
{
  imports = [
    ../../common/home-manager.nix
  ];

  home = {
    username = user;
    stateVersion = stateVersion;

    packages = [
      pkgs.audacity_3
      pkgs.qpwgraph
      pkgs.libreoffice
      pkgs.wf-recorder
      pkgs.gemini-cli
      pkgs.perf
      pkgs.croc
      pkgs.uv
      pkgs.gh
      pkgs.gdb
      pkgs.liburing
      pkgs.signal-desktop

      # log viewer
      inputs.lazylog.packages.${pkgs.system}.default
      inputs.context.packages.${pkgs.system}.default
      openconnect-sso-wayland
      inputs.cimple.packages.${pkgs.system}.default
      inputs.cimple-fill.packages.${pkgs.system}.default
    ];
  };

  xdg.desktopEntries.pijpkijk-pick = {
    name = "pijpkijk (pick device)";
    comment = "Browse B&O products and open the remote PipeWire graph";
    exec = "pijpkijk-pick";
    terminal = false;
    categories = [
      "Audio"
      "Utility"
    ];
  };

  # monitor at work
  wayland.windowManager.hyprland.extraConfig = pkgs.lib.mkForce ''
    monitor=eDP-1,preferred,auto,1
    monitor=DP-8,preferred,auto,1

    exec-once = [workspace 9 silent] obsidian
    exec-once = [workspace 9 silent] microsoft-edge
    exec-once = [workspace 8 silent] firefox
  '';
}
