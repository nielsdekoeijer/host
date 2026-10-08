{
  config,
  pkgs,
  user,
  hostName,
  stateVersion,
  lib,
  inputs,
  ...
}:
let
  pijpkijk = inputs.pijpkijk.packages.${pkgs.system}.default;

  pijpkijk-pick = pkgs.writeShellScriptBin "pijpkijk-pick" ''
    set -euo pipefail

    # mDNS discovery on the local link -> "name | ip" (IPv4, deduped)
    mapfile -t mdns_hosts < <(
      ${pkgs.avahi}/bin/avahi-browse -rtp _bangolufsen._tcp \
        | ${pkgs.gawk}/bin/awk -F';' \
            '/^=/ && $3=="IPv4" && !seen[$4,$8]++ {print $4 " | " $8}'
    )

    entries=( "''${mdns_hosts[@]}" "Manual entry…" )

    choice=$(printf '%s\n' "''${entries[@]}" \
      | ${pkgs.wofi}/bin/wofi --dmenu --prompt pijpkijk)
    [ -z "''${choice:-}" ] && exit 0

    if [ "$choice" = "Manual entry…" ]; then
      # ask for an IP (wofi returns whatever you type)
      ip=$(: | ${pkgs.wofi}/bin/wofi --dmenu --prompt ip)
    else
      ip=$(printf '%s' "$choice" | ${pkgs.gnused}/bin/sed 's/.*| *//')
    fi
    [ -z "''${ip:-}" ] && exit 0

    socket_dir=$(mktemp -d -p /tmp pijpkijk.XXXXXX)
    ssh_pid=""
    cleanup() {
      [ -n "$ssh_pid" ] && kill "$ssh_pid" 2>/dev/null || true
      rm -rf "$socket_dir"
    }
    trap cleanup EXIT

    ${pkgs.openssh}/bin/ssh -nNT \
      -o StrictHostKeyChecking=accept-new \
      -L "$socket_dir/pipewire-0:/run/pipewire/pipewire-0" \
      "root@$ip" &
    ssh_pid=$!

    for _ in $(seq 1 50); do
      [ -S "$socket_dir/pipewire-0" ] && break
      sleep 0.1
    done

    PIPEWIRE_RUNTIME_DIR="$socket_dir" ${lib.getExe pijpkijk}
  '';
in
{

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  imports = [
    ../../common/configuration.nix
    ../../common/intune/intune.nix
    ../../common/hardware/nvidia.nix
    ./wireguard.nix
    ../../common/mozart-netboot.nix
  ];

  services.mozart-netboot = {
    enable = true;
    inherit user;
  };

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
    pkgs.wl-screenrec
    pkgs.slurp
    pijpkijk
    pijpkijk-pick
    (pkgs.writeShellScriptBin "show-products" ''
      ${pkgs.avahi}/bin/avahi-browse -rtp _bangolufsen._tcp \
        | ${pkgs.gawk}/bin/awk -F';' '/^=/ && !seen[$4,$8]++ {print $4, $8}'
    '')
    (pkgs.writeShellScriptBin "screen-record" ''
      wl-screenrec -g "$(slurp)" -f my_recording.mp4
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
