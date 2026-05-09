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
  ];
}
