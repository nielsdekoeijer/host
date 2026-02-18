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
      boot.kernelPackages = pkgs.linuxPackages_latest;
      boot.supportedFilesystems.zfs = lib.mkForce false;
      hardware.enableRedistributableFirmware = lib.mkForce true;
      hardware.wirelessRegulatoryDatabase = true;

      # ssh
      services.openssh.enable = true;

      environment.systemPackages = with pkgs; [
        linux-firmware
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
