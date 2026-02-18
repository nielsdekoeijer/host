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
}
