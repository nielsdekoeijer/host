{ nixpkgs, home-manager, disko, system }:
# note that we symlink but must still respect the relative path 
(import ../../systems/home-manager-only/default.nix) {
  inherit nixpkgs home-manager system;
  user = "niels";
  stateVersion = "25.11";
}

