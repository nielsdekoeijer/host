{ nixpkgs, home-manager, disko, system }:

# note that we symlink but must still respect the relative path 
(import ../../systems/development-laptop/system.nix) {
  inherit nixpkgs home-manager disko system;
  user = "niels";
  hostName = "nixos-laptop";
  stateVersion = "25.11";
  diskoConfiguration = { ... }: import ./disko.nix;
}

