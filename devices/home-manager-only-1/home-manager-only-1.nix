# { nixpkgs, home-manager, disko, system }:
# # note that we symlink but must still respect the relative path 
# (import ../../systems/home-manager-only/default.nix) {
#   inherit nixpkgs home-manager system;
#   user = "niels";
#   stateVersion = "25.11";
# }

{ nixpkgs, home-manager, system, user, stateVersion }:

let
  pkgs = import nixpkgs { inherit system; };
in
  home-manager.lib.homeManagerConfiguration {
    inherit pkgs;

    modules = [
      {
        home.username = user;
        home.homeDirectory = "/Users/${user}";
        home.stateVersion = stateVersion;
      }
      ../../systems/home-manager-only/home-manager.nix
    ];
  }

