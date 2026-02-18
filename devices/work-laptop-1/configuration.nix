{
  config,
  pkgs,
  user,
  hostName,
  stateVersion,
  lib,
  ...
}:
{
  imports = [
    ../../common/configuration.nix
    ../../common/hardware/nvidia.nix
  ];

  # nix-ld libraries for precompiled binaries
  programs.nix-ld.libraries = with pkgs; [ stdenv.cc.cc ];

  # dev firewall ports
  networking.firewall.allowedTCPPorts = [
    8000
    9190
  ];

  # avahi (mDNS service discovery)
  services.avahi = {
    enable = true;
    publish.enable = true;
    publish.addresses = true;
  };

  # work-specific system packages
  environment.systemPackages = [
    pkgs.avahi
    (pkgs.writeShellScriptBin "show-products" ''
      ${pkgs.avahi}/bin/avahi-browse -rtp _bangolufsen._tcp \
        | ${pkgs.gawk}/bin/awk -F"\;" '/^=/ {print $4, $8}'
    '')
  ];
}
