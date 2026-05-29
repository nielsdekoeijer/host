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

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # random software
    lazylog = {
      url = "git+https://github.com/kaspernyhus/lazylog.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    context = {
      url = "git+https://github.com/nielsdekoeijer/context.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    remote-helvum = {
      url = "github:AudioStreamingPlatform/helvum-layout-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-openconnect-sso.url = "github:nixos/nixpkgs/46397778ef1f73414b03ed553a3368f0e7e33c2f";
    openconnect-sso = {
      url = "github:jcszymansk/openconnect-sso";
      inputs.nixpkgs.follows = "nixpkgs-openconnect-sso";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      disko,
      ...
    }@inputs:
    let
      mkSystem = import ./lib/mkSystem.nix {
        inherit
          nixpkgs
          home-manager
          disko
          inputs
          ;
      };
      mkISO = import ./lib/mkISO.nix { inherit nixpkgs disko; };

      user = "niels";
      stateVersion = "25.11";
      system = "x86_64-linux";
      hostsDir = ./hosts;
      pkgs = nixpkgs.legacyPackages.${system};

      # the hosts folder describes every host I have customized
      hostNames = nixpkgs.lib.attrNames (
        nixpkgs.lib.filterAttrs (n: v: v == "directory") (builtins.readDir hostsDir)
      );

      # function that generates my system based on a given hostname
      genSystem =
        name:
        mkSystem {
          inherit system user stateVersion;
          hostName = name; # Hostname is now exactly the folder name
          diskoConfiguration = { ... }: import (hostsDir + "/${name}/disko.nix");
          configurationPath = hostsDir + "/${name}/configuration.nix";
          homeManagerPath = hostsDir + "/${name}/home-manager.nix";
        };

      generatedSystems = nixpkgs.lib.genAttrs hostNames genSystem;

    in
    {
      formatter.${system} = pkgs.nixfmt;

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
