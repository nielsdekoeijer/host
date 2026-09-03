{ pkgs, user, ... }:

let
  home = "/home/${user}";
  nfsRoot = "${home}/nfsroot";
  tftpRoot = "${home}/tftpboot";

  umpf = pkgs.stdenvNoCC.mkDerivation {
    pname = "umpf";
    version = "0-unstable-2026-09-03";

    src = pkgs.fetchFromGitHub {
      owner = "pengutronix";
      repo = "umpf";
      rev = "0d713dcc31cf5ea0c385bb7b9ac4c45947d56729";
      hash = "sha256-6m0lXvZdW8h/uwuloKZYpwcEtorE5tV6LeXrKpZR/dY=";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      patchShebangs .
      install -Dm0755 umpf "$out/bin/umpf"
      install -Dm0644 bash_completion "$out/share/bash-completion/completions/umpf"
      runHook postInstall
    '';

    postFixup = ''
      wrapProgram "$out/bin/umpf" \
        --prefix PATH : ${
          pkgs.lib.makeBinPath [
            pkgs.coreutils
            pkgs.diffutils
            pkgs.gawk
            pkgs.git
            pkgs.gnugrep
            pkgs.gnused
            pkgs.patch
          ]
        }
    '';
  };

  # The vendor SDK contains binaries built for a conventional Linux filesystem.
  yocto-sdk-env = pkgs.buildFHSEnv {
    name = "yocto-sdk-env";
    targetPkgs =
      p: with p; [
        bash
        bc
        coreutils
        diffutils
        file
        findutils
        gawk
        gcc
        git
        gnugrep
        gnused
        gzip
        openssl
        patch
        perl
        python3
        xz
      ];
    extraOutputsToInstall = [ "dev" ];
    runScript = "bash";
  };

  netboot-info = pkgs.writeShellScriptBin "netboot-info" ''
    set -eu
    echo "Host IPv4 addresses:"
    ${pkgs.iproute2}/bin/ip -brief -4 address show scope global
    echo
    echo "Exports:"
    ${pkgs.nfs-utils}/bin/showmount --exports localhost
    echo
    ${pkgs.systemd}/bin/systemctl --no-pager --full status \
      nfs-server.service tftpd-hpa.service || true
  '';
in
{
  systemd.tmpfiles.rules = [
    "d ${nfsRoot} 0755 ${user} ${user} - -"
    "d ${tftpRoot} 0755 ${user} ${user} - -"
  ];

  # Barebox uses NFSv3 for its root filesystem. Fixed auxiliary ports make the
  # firewall configuration stable across rebuilds and reboots.
  services.nfs.server = {
    enable = true;
    exports = ''
      ${nfsRoot} *(rw,no_subtree_check,no_root_squash,async)
    '';
    mountdPort = 20048;
    statdPort = 4000;
    lockdPort = 4001;
  };
  services.nfs.settings.nfsd = {
    vers3 = true;
    vers4 = false;
    udp = true;
    tcp = true;
  };

  environment.etc."tftpd.map".text = ''
    r ^ ${tftpRoot}/
  '';

  systemd.services.tftpd-hpa = {
    description = "TFTP server for embedded netboot";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.tftp-hpa}/bin/in.tftpd --foreground --user ${user} --address :69 --permissive --map-file /etc/tftpd.map --secure /";
      Restart = "on-failure";
      ProtectHome = false;
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      111 # rpcbind
      2049 # NFS
      4000 # statd
      4001 # lockd
      20048 # mountd
    ];
    allowedUDPPorts = [
      69 # TFTP
      111
      2049
      4000
      4001
      20048
    ];
  };

  environment.systemPackages = [
    netboot-info
    pkgs.nfs-utils
    pkgs.picocom
    pkgs.tftp-hpa
    umpf
    yocto-sdk-env
  ];
}
