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
  };
  outputs = { self, nixpkgs, home-manager, disko, ... }:
    let
      # default development laptop system
      laptop = import ./systems/laptop/system.nix;

      # host system
      # TODO: this needs to autodetect
      hostSystem = "x86_64-linux";
    in {
      nixosConfigurations = {
        # configuration for a laptop / desktop system with development stuff
        # NOTE: currently, the only system, but we could have more.
        laptop-work-1 = laptop {
          user = "niels";
          stateVersion = "25.11";
          system = "x86_64-linux";
          hostName = "nixos-laptop";

          inherit nixpkgs home-manager disko;
        };
      };
    };
}
