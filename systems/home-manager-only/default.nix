{ inputs, pkgs, ... }:

{
  homeConfigurations.non-nixos = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [ ./home-manager.nix ];
  };
}

