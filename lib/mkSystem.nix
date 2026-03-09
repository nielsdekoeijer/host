{
  nixpkgs,
  home-manager,
  disko,
  inputs,
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

  specialArgs = { inherit user stateVersion hostName inputs; };

  modules = [
    disko.nixosModules.disko
    diskoConfiguration

    {
      imports = [ home-manager.nixosModules.home-manager ];
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit inputs user stateVersion hostName pkgs; };
        users.${user} = homeManagerPath;
      };
    }

    configurationPath
  ];
}
