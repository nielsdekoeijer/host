{
  nixpkgs,
  home-manager,
  disko,
}:

{
  system,
  hostName,
  user,
  stateVersion,
  diskoConfiguration,
  configurationPath,
  homeManagerPath,
}:
let
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  lib = nixpkgs.lib;
in
lib.nixosSystem {
  inherit system;

  specialArgs = { inherit user stateVersion hostName; };

  modules = [
    disko.nixosModules.disko
    diskoConfiguration

    {
      imports = [ home-manager.nixosModules.home-manager ];
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${user} = import homeManagerPath { inherit user stateVersion pkgs; };
      };
    }

    configurationPath
  ];
}
