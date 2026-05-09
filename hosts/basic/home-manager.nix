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
  };
}
