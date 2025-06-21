{ system, nixpkgs, disko, home-manager, user, stateVersion, hostName
, diskoConfiguration }:
let
  # extract pkgs out of the nixpkgs channel
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  # extract lib out of the nixpkgs channel
  lib = nixpkgs.lib;
in lib.nixosSystem {
  inherit system;

  specialArgs = { inherit user stateVersion hostName diskoConfiguration; };

  modules = [
    # provide disko for disk management
    disko.nixosModules.disko
    diskoConfiguration

    # add the Home Manager module,
    {
      imports = [ home-manager.nixosModules.home-manager ];
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${user} =
          import ./home-manager.nix { inherit user stateVersion pkgs; };
      };
    }

    # imports host-specific NixOS configuration
    ./configuration.nix
  ];
}
