{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.bogo.intune;
  mib_url = "https://packages.microsoft.com/ubuntu/24.04/prod/pool/main/m/microsoft-identity-broker/microsoft-identity-broker_3.0.1-noble_amd64.deb";
  mib_sha = "sha256-cbG+HJ1nuOyxR/sd1P69QTEUaklywbJOP7o6K7l6SEs=";

  int_url = "https://packages.microsoft.com/ubuntu/24.04/prod/pool/main/i/intune-portal/intune-portal_1.2603.31-noble_amd64.deb";
  int_sha = "sha256-0braaXnRa04CUQdJx0ZFwe5qfjsJNzTtGqaKQV5Z6Yw=";

  intune-portal-wrapped = pkgs.writeShellScriptBin "intune-portal" ''
    set -e

    echo "==> Spoofing Ubuntu 24.04 in /etc/os-release..."
    FAKE_OS_RELEASE=$(mktemp)
    
    # Write the Ubuntu 24.04 (Noble Numbat) release info
    cat << 'EOF' > "$FAKE_OS_RELEASE"
    NAME="Ubuntu"
    VERSION="24.04 LTS (Noble Numbat)"
    ID=ubuntu
    ID_LIKE=debian
    PRETTY_NAME="Ubuntu 24.04 LTS"
    VERSION_ID="24.04"
    HOME_URL="https://www.ubuntu.com/"
    SUPPORT_URL="https://help.ubuntu.com/"
    BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
    PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
    VERSION_CODENAME=noble
    UBUNTU_CODENAME=noble
    EOF

    # Ensure cleanup happens when the script exits (Ctrl+C or normal close)
    trap 'echo "==> Restoring original /etc/os-release..."; sudo umount /etc/os-release; rm -f "$FAKE_OS_RELEASE"' EXIT

    # Apply the fake OS release
    sudo mount --bind "$FAKE_OS_RELEASE" /etc/os-release

    # Setup the environment for Intune/MSAL
    export GIO_EXTRA_MODULES="${pkgs.glib-networking}/lib/gio/modules"
    export SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"
    export SSL_CERT_DIR="/etc/ssl/certs"
    
    # Rendering and Sandbox fixes
    export WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS="1"
    export WEBKIT_DISABLE_DMABUF_RENDERER="1" 

    export GDK_BACKEND=x11
    export WEBKIT_DISABLE_COMPOSITING_MODE="1"
    export LIBGL_ALWAYS_SOFTWARE="1"
    
    export MSAL_ALLOW_PII="true"
    export MSAL_LOG_LEVEL="4"
    
    ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
    
    echo "==> Starting Intune Portal..."
    # Intentionally NOT using exec here so the trap can fire afterwards
    ${pkgs.intune-portal}/bin/intune-portal
  '';
in
{
  options.bogo.intune = {
    enable = lib.mkEnableOption "Microsoft Intune and Identity Broker setup";
  };

  config = lib.mkIf cfg.enable {
    services.intune.enable = true;
    programs.dconf.enable = true;

    services.gnome.gnome-keyring.enable = true;

    systemd.services.microsoft-identity-device-broker.environment = {
      GIO_EXTRA_MODULES = "${pkgs.glib-networking}/lib/gio/modules";
      SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
      SSL_CERT_DIR = "/etc/ssl/certs";
      WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS = "1";
      MSAL_ALLOW_PII = "true";
      MSAL_LOG_LEVEL = "4";
      GDK_BACKEND = "x11";
      WEBKIT_DISABLE_COMPOSITING_MODE = "1";
      LIBGL_ALWAYS_SOFTWARE = "1";
    };

    systemd.user.services.microsoft-identity-broker.environment = {
      GIO_EXTRA_MODULES = "${pkgs.glib-networking}/lib/gio/modules";
      SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
      SSL_CERT_DIR = "/etc/ssl/certs";
      WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS = "1";
      MSAL_ALLOW_PII = "true";
      MSAL_LOG_LEVEL = "4";
      GDK_BACKEND = "x11";
      WEBKIT_DISABLE_COMPOSITING_MODE = "1";
      LIBGL_ALWAYS_SOFTWARE = "1";
    };

    environment.systemPackages = [
      intune-portal-wrapped
      pkgs.glib-networking
      pkgs.seahorse
      pkgs.microsoft-edge
    ];

    nixpkgs.overlays = [
      (final: prev: {

        microsoft-identity-broker = prev.microsoft-identity-broker.overrideAttrs (previousAttrs: {
          src = pkgs.fetchurl {
            url = mib_url;
            sha256 = mib_sha;
          };
        });

        intune-portal = prev.intune-portal.overrideAttrs (old: rec {
          version = "1.2603.31";
          src = pkgs.fetchurl {
            url = int_url;
            hash = int_sha; 
          };
        });
      })
    ];
  };
}
