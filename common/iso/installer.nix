{ pkgs, lib, ... }:
{
  networking.hostName = lib.mkForce "nixos-installer";
  services.getty.autologinUser = lib.mkForce "root";

  environment.etc."motd".text = ''

    NixOS Installer
    ────────────────
    Run `install-nixos` to begin.

  '';
}
