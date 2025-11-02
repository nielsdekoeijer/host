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
      work-laptop-1 = (import ./devices/work-laptop-1/work-laptop-1.nix) {
        inherit nixpkgs home-manager disko;
        system = "x86_64-linux";
      };

      personal-laptop-1 =
        (import ./devices/personal-laptop-1/personal-laptop-1.nix) {
          inherit nixpkgs home-manager disko;
          system = "x86_64-linux";
        };

    in {
      nixosConfigurations.${work-laptop-1.config.networking.hostName} =
        work-laptop-1;

      nixosConfigurations.${personal-laptop-1.config.networking.hostName} =
        personal-laptop-1;

      packages."x86_64-linux".default = work-laptop-1;

      # TODO: rework this
      homeConfigurations."home-manager-only-darwin" =
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-darwin"; };
          modules = [ ./systems/home-manager-only/home-manager.nix ];
          extraSpecialArgs = {
            user = "demomaclr";
            stateVersion = "25.11";
          };
        };

      # TODO: rework this
      homeConfigurations."home-manager-only-wsl" =
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          modules = [ ./systems/home-manager-only/home-manager.nix ];
          extraSpecialArgs = {
            user = "niels";
            stateVersion = "25.11";
          };
        };
    };
}
