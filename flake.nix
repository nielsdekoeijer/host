{
  description = "Niels simple NixOS configuration";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      disko,
      ...
    }:
    let
      mkSystem = import ./lib/mkSystem.nix { inherit nixpkgs home-manager disko; };
      mkISO = import ./lib/mkISO.nix { inherit nixpkgs disko; };

      user = "niels";
      stateVersion = "25.11";
      system = "x86_64-linux";
      devicesDir = ./devices;
      deviceNames = nixpkgs.lib.attrNames (
        nixpkgs.lib.filterAttrs (n: v: v == "directory") (builtins.readDir devicesDir)
      );

      genSystem =
        name:
        mkSystem {
          inherit system user stateVersion;
          hostName = name; # Hostname is now exactly the folder name
          diskoConfiguration = { ... }: import (devicesDir + "/${name}/disko.nix");
          configurationPath = devicesDir + "/${name}/configuration.nix";
          homeManagerPath = devicesDir + "/${name}/home-manager.nix";
        };

      generatedSystems = nixpkgs.lib.genAttrs deviceNames genSystem;

    in
    {
      nixosConfigurations = generatedSystems // {
        installer = mkISO {
          inherit system;
          extraModules = [ ./common/iso/installer.nix ];
        };
      };

      packages.${system} = {
        # Defaults to one of your known hosts for convenience
        default = self.nixosConfigurations.basic.config.system.build.toplevel;

        iso =
          (mkISO {
            inherit system;
            extraModules = [ ./common/iso/installer.nix ];
          }).config.system.build.isoImage;
      };
    };
}
