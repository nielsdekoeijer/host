{
  description = "Niels simple NixOS configuration";

  inputs = {
    # import the unstable branch of nixpkgs
    nixpkgs = { url = "github:nixos/nixpkgs?ref=nixos-unstable"; };

    # home manager is used to manage our home directory (like neovim config) but also
    # install tools (like git)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # disko allows us to do declarative disks
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # standard utils
    utils = { url = "github:numtide/flake-utils"; };
  };
  outputs = { nixpkgs, home-manager, disko, ... }:
    let
      device =
        (import ./device.nix) { inherit nixpkgs home-manager disko system; };
      system = "x86_64-linux";
    in {
      nixosConfigurations.${device.config.networking.hostName} = device;
      packages.${system}.default = device.config.system.build.toplevel;
    };
}
