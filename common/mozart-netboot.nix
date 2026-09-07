{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.mozart-netboot;
  userExists = cfg.user != null && builtins.hasAttr cfg.user config.users.users;
  configuredUser = if userExists then config.users.users.${cfg.user} else null;
  home = if cfg.homeDirectory != null then cfg.homeDirectory else configuredUser.home or "/var/empty";
  group = if cfg.group != null then cfg.group else configuredUser.group or "nogroup";
  nfsRoot = if cfg.nfsRoot != null then cfg.nfsRoot else "${home}/nfsroot";
  tftpRoot = if cfg.tftpRoot != null then cfg.tftpRoot else "${home}/tftpboot";
  exportLines = lib.concatMapStringsSep "\n" (
    client: "${nfsRoot} ${client}(rw,no_subtree_check,no_root_squash,async)"
  ) cfg.exportClients;

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

  yocto-sdk-bashrc = pkgs.writeText "yocto-sdk-bashrc" ''
    if [ -f ~/.bashrc ]; then
      source ~/.bashrc
    fi

    export MOZART_YOCTO_SDK_ENV=1
    PS1="[yocto-sdk-env] ''${PS1}"
  '';

  yocto-sdk-shell = pkgs.writeShellScript "yocto-sdk-shell" ''
    if [ "''${1:-}" = "--help" ] || [ "''${1:-}" = "-h" ]; then
      cat <<'EOF'
    Usage: yocto-sdk-env [--help] [-c COMMAND]

    Opens an FHS-compatible shell for the Mozart Yocto SDK and netboot tools.
    The interactive prompt is prefixed with [yocto-sdk-env].

    Values you must set:

         export MOZART_WORKSPACE="/path/to/mozart-workspace"
         export MOZART_LINUX_PATH="/path/to/linux-mozart"
         export MOZART_BUILD_TYPE="imx8-base"
         export MOZART_SDK_TAG="6.3.0.1019"

    MOZART_SDK_TAG is the four-part release tag from the mozart-imx8m-sdk
    repository. Use the SDK release intended for your work; it may have the
    same version as MOZART_TAG, but that is not guaranteed. Check a candidate:

         gh release view "$MOZART_SDK_TAG" --repo AudioStreamingPlatform/mozart-imx8m-sdk

    Values derived from the checked-out workspace:

         export MOZART_TAG=$(git -C "$MOZART_WORKSPACE" describe --tags --exact-match --match "$(cat "$MOZART_WORKSPACE/VERSION").*" HEAD)
         export MOZART_BRANCH=$(git -C "$MOZART_WORKSPACE" branch --show-current)
         export SERIES_INC="$MOZART_WORKSPACE/layers/meta-mozart/meta-mozart-bsp/recipes-kernel/linux/linux-mozart-6.4.7/patches/series.inc"
         export UMPF_TAG=$(sed -n 's/^# umpf-version: //p' "$SERIES_INC")
         printf 'branch=%s mozart=%s sdk=%s umpf=%s\n' "$MOZART_BRANCH" "$MOZART_TAG" "$MOZART_SDK_TAG" "$UMPF_TAG"

    1. Create and build the Yocto configuration (runs in Symphony/Docker):

         cd "$MOZART_WORKSPACE"
         ./build.sh -m "$MOZART_BUILD_TYPE" --dry-run
         ./scripts/symphony shell

         in the shell:

         . ./layers/poky/oe-init-build-env builds/$MOZART_BUILD_TYPE
         bitbake mozart-non-gva-bundle
         bitbake devicetree-mozart

         make sure to leave the shell in subsequent steps...!

    2. Prepare a Linux checkout with the UMPF tag used by the workspace.

       The derived UMPF_TAG above comes from the Linux 6.4.7 recipe used by the
       netboot script, rather than guessing or using the newest tag.

       UMPF rewrites the Linux checkout. Commit or stash any work in it first,
       including untracked files. Then reproduce the workspace's exact kernel:

         cd "$MOZART_LINUX_PATH"
         git fetch --all
         git fetch --tags
         umpf build -i "$UMPF_TAG"

       -i uses the precise topic commit hashes recorded by series.inc. Using
       -r origin instead would use branch tips which may have moved.

    3. Back in this shell, bootstrap the host-side netboot environment:

         cd "$MOZART_WORKSPACE"
         source ./netboot-bootstrap.sh "$MOZART_BUILD_TYPE" "$MOZART_SDK_TAG" "$MOZART_LINUX_PATH"

       MOZART_SDK_TAG is a released cross-toolchain version and is not the
       slash-separated UMPF_TAG.

    4. First-time initialization:

         netboot_help_first_time
         netboot_purge
         netboot_rootfs_purge
         netboot_rootfs_init
         netboot_linux_refresh

    Diagnostics from a normal host shell: netboot-info
    EOF
      exit 0
    fi

    exec bash --rcfile ${yocto-sdk-bashrc} "$@"
  '';

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
    runScript = yocto-sdk-shell;
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
  options.services.mozart-netboot = {
    enable = lib.mkEnableOption "Mozart/Barebox netboot development services";

    user = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "alice";
      description = "Local user that owns the netboot trees and runs TFTP.";
    };

    group = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Group owning the netboot trees; defaults to the user's primary group.";
    };

    homeDirectory = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Home directory; normally inferred from users.users.<name>.home.";
    };

    nfsRoot = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "NFS root path; defaults to <home>/nfsroot as expected by Barebox.";
    };

    tftpRoot = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "TFTP content path; defaults to <home>/tftpboot.";
    };

    exportClients = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "*" ];
      example = [ "192.168.10.0/24" ];
      description = "Hosts or networks allowed to mount the development NFS root.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open the fixed NFS, RPC, and TFTP ports in the NixOS firewall.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.user != null;
        message = "services.mozart-netboot.user must be set.";
      }
      {
        assertion = cfg.homeDirectory != null || userExists;
        message = "services.mozart-netboot.user must name a declared NixOS user, or homeDirectory must be set.";
      }
    ];

    warnings = lib.optional (cfg.exportClients == [ "*" ]) ''
      Mozart netboot exports NFS with no_root_squash to every reachable client.
      Prefer services.mozart-netboot.exportClients = [ "<development-subnet>" ].
    '';

    systemd.tmpfiles.rules = [
      "d ${nfsRoot} 0755 ${cfg.user} ${group} - -"
      "d ${tftpRoot} 0755 ${cfg.user} ${group} - -"
    ];

    # Barebox uses NFSv3 for its root filesystem. Fixed auxiliary ports make the
    # firewall configuration stable across rebuilds and reboots.
    services.nfs.server = {
      enable = true;
      exports = lib.mkAfter exportLines;
      mountdPort = 20048;
      statdPort = 4000;
    };
    services.nfs.settings.nfsd = {
      vers3 = true;
      udp = true;
      tcp = true;
    };

    # This kernel exposes lockd's ports through sysctl rather than accepting the
    # nfs.conf lockd section used by the NixOS lockdPort option.
    boot.kernel.sysctl = {
      "fs.nfs.nlm_tcpport" = 4001;
      "fs.nfs.nlm_udpport" = 4001;
    };

    environment.etc."tftpd.map".text = ''
      r ^ ${tftpRoot}/
    '';

    systemd.services.tftpd-hpa = {
      description = "TFTP server for embedded netboot";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.tftp-hpa}/bin/in.tftpd --foreground --user ${cfg.user} --address :69 --permissive --map-file /etc/tftpd.map --secure /";
        Restart = "on-failure";
        ProtectHome = false;
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
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
      pkgs.python3
      pkgs.tftp-hpa
      umpf
      yocto-sdk-env
    ];
  };
}
