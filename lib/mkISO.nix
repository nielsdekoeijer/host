{ nixpkgs, disko }:

{ system
, extraModules ? []
}:
let
  lib = nixpkgs.lib;
in lib.nixosSystem {
  inherit system;

  modules = [
    "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    disko.nixosModules.disko

    ({ pkgs, ... }: {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      networking.networkmanager.enable = true;
      networking.wireless.enable = lib.mkForce false;

      # to get wifi working... I just iterated until it worked
      nixpkgs.config.allowUnfree = true;
      hardware.enableAllFirmware = true;
      hardware.enableRedistributableFirmware = lib.mkForce true;
      boot.kernelPackages = pkgs.linuxPackages;

      # ssh
      services.openssh.enable = true;

      environment.systemPackages = with pkgs; [
        git
        neovim
        curl
        parted
        gptfdisk
        (pkgs.writeShellScriptBin "install-nixos" (builtins.readFile ../common/iso/install-nixos.sh))
      ];
    })
  ] ++ extraModules;
}
