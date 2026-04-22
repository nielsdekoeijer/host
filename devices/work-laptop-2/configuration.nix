{
  config,
  pkgs,
  user,
  hostName,
  stateVersion,
  lib,
  ...
}:
let
  linux = pkgs.buildLinux rec {
    version = "6.18.10";
    modDirVersion = version;

    src = fetchTarball {
      url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${version}.tar.xz";
      sha256 = "sha256:1jrh1ylkaivgyqgdx72r3f9wnfffmvg3bzw37k84bq53z09i7zpd";
    };

    # Inherit sensible defaults from the current kernel packages
    kernelPatches = [ ];
    structuredExtraConfig = { };
  };

  kernelPackages = pkgs.linuxPackagesFor linux;
in
{

  boot.kernelPackages = kernelPackages;

  boot.kernelPatches = [
    {
      name = "v7_20251216_bin_du_add_amd_isp4_driver";
      patch = pkgs.fetchurl {
        url = "https://lore.kernel.org/all/20251216091326.111977-1-Bin.Du@amd.com/t.mbox.gz";
        # hash can change due to mailing list stuff...
        hash = "sha256-6n3Lxut2wrreZUzkKoJ7L7ItYC7GPhw39aE9I8W8xcg=";
      };
    }
  ];

  imports = [
    ../../common/configuration.nix
    ../../common/intune/intune.nix
    ../../common/hardware/nvidia.nix
    ./wireguard.nix
  ];

  # nix-ld libraries for precompiled binaries
  programs.nix-ld.libraries = with pkgs; [ stdenv.cc.cc ];

  # fucking intune
  bogo.intune.enable = true;

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
        | ${pkgs.gawk}/bin/awk -F';' '/^=/ && !seen[$4,$8]++ {print $4, $8}'
    '')
  ];

  # swap
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16384 * 2;
    }
  ];

}
