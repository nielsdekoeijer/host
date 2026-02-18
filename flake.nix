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

    utils = {
      url = "github:numtide/flake-utils";
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

      work-laptop = mkSystem {
        system = "x86_64-linux";
        hostName = "work-laptop";
        user = "niels";
        stateVersion = "25.11";
        diskoConfiguration = { ... }: import ./devices/work-laptop-1/disko.nix;
        configurationPath = ./systems/development-laptop/configuration.nix;
        homeManagerPath = ./systems/development-laptop/home-manager.nix;
      };

      personal-laptop = mkSystem {
        system = "x86_64-linux";
        hostName = "personal-laptop";
        user = "niels";
        stateVersion = "25.11";
        diskoConfiguration = { ... }: import ./devices/personal-laptop-1/disko.nix;
        configurationPath = ./systems/personal-laptop/configuration.nix;
        homeManagerPath = ./systems/personal-laptop/home-manager.nix;
      };

    in
    {
      nixosConfigurations.work-laptop = work-laptop;
      nixosConfigurations.personal-laptop = personal-laptop;

      packages."x86_64-linux".default = work-laptop;

    };
}
