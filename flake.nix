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
      nixpkgs,
      home-manager,
      disko,
      ...
    }:
    let
      mkSystem = import ./lib/mkSystem.nix { inherit nixpkgs home-manager disko; };
      mkISO = import ./lib/mkISO.nix { inherit nixpkgs disko; };

      work-laptop = mkSystem {
        system = "x86_64-linux";
        hostName = "work-laptop";
        user = "niels";
        stateVersion = "25.11";
        diskoConfiguration = { ... }: import ./devices/work-laptop-1/disko.nix;
        configurationPath = ./devices/work-laptop-1/configuration.nix;
        homeManagerPath = ./devices/work-laptop-1/home-manager.nix;
      };

      work-laptop-2 = mkSystem {
        system = "x86_64-linux";
        hostName = "work-laptop-2";
        user = "niels";
        stateVersion = "25.11";
        diskoConfiguration = { ... }: import ./devices/work-laptop-2/disko.nix;
        configurationPath = ./devices/work-laptop-2/configuration.nix;
        homeManagerPath = ./devices/work-laptop-2/home-manager.nix;
      };

      personal-laptop = mkSystem {
        system = "x86_64-linux";
        hostName = "personal-laptop";
        user = "niels";
        stateVersion = "25.11";
        diskoConfiguration = { ... }: import ./devices/personal-laptop-1/disko.nix;
        configurationPath = ./devices/personal-laptop-1/configuration.nix;
        homeManagerPath = ./devices/personal-laptop-1/home-manager.nix;
      };

    in
    {
      nixosConfigurations.work-laptop = work-laptop;
      nixosConfigurations.work-laptop-2 = work-laptop-2;
      nixosConfigurations.personal-laptop = personal-laptop;

      nixosConfigurations.installer = mkISO {
        system = "x86_64-linux";
        extraModules = [ ./common/iso/installer.nix ];
      };

      packages."x86_64-linux" = {
        default = work-laptop;
        iso =
          (mkISO {
            system = "x86_64-linux";
            extraModules = [ ./common/iso/installer.nix ];
          }).config.system.build.isoImage;
      };
    };
}
