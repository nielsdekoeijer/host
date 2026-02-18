#!/usr/bin/env bash
set -euo pipefail

FLAKE_REPO="https://github.com/nielsdekoeijer/host"

echo ""
echo "  NixOS Installer"
echo "  ════════════════"
echo ""

# ── Clone ────────────────────────────────────────────────────────
WORK_DIR="/tmp/nixos-config"
if [[ -d "$WORK_DIR" ]]; then
    echo "[*] Repo already at $WORK_DIR, pulling latest..."
    git -C "$WORK_DIR" pull
else
    echo "[*] Cloning $FLAKE_REPO..."
    git clone "$FLAKE_REPO" "$WORK_DIR"
fi
echo ""

# ── Pick device ──────────────────────────────────────────────────
echo "[*] Available devices:"
echo ""
for d in "$WORK_DIR"/devices/*/; do
    echo "    - $(basename "$d")"
done
echo ""
read -rp "Which device? > " DEVICE

if [[ ! -d "$WORK_DIR/devices/$DEVICE" ]]; then
    echo "[!] devices/$DEVICE does not exist. Aborting."
    exit 1
fi
echo ""

# ── Show disko config ────────────────────────────────────────────
echo "[*] Current block devices:"
echo ""
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
echo ""

DISKO_FILE="$WORK_DIR/devices/$DEVICE/disko.nix"
if [[ ! -f "$DISKO_FILE" ]]; then
    # fallback: check if device uses standard profile via flake
    DISKO_FILE="$WORK_DIR/disko/standard-nvme.nix"
fi

echo "[*] Disko config that will be applied:"
echo ""
cat "$DISKO_FILE"
echo ""

echo "[!] THIS WILL ERASE THE TARGET DISK."
read -rp "    Proceed? (yes/no) > " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo ""
    echo "    Aborting. You can edit the disko config and re-run:"
    echo "      vi $DISKO_FILE"
    echo "      install-nixos"
    exit 1
fi
echo ""

# ── Determine hostname ───────────────────────────────────────────
HOSTNAME=$(grep -A5 "\"$(basename "$DEVICE")\"\\|$(basename "$DEVICE")" "$WORK_DIR/flake.nix" \
    | grep "hostName" | head -1 | sed 's/.*"\(.*\)".*/\1/' || true)

if [[ -z "$HOSTNAME" ]]; then
    read -rp "[?] Could not detect hostname. Enter it: > " HOSTNAME
fi

echo "[*] Installing as: $HOSTNAME"
echo ""

# ── Partition ────────────────────────────────────────────────────
echo "[*] Running disko..."
nix run github:nix-community/disko -- --mode disko --flake "$WORK_DIR#$HOSTNAME"
echo ""
echo "[*] Mounts after disko:"
findmnt --target /mnt || mount | grep /mnt
echo ""

# ── Install ──────────────────────────────────────────────────────
echo "[*] Running nixos-install..."
nixos-install --flake "$WORK_DIR#$HOSTNAME" --no-root-passwd
echo ""
echo "  Done! Run 'reboot' to start your new system."
echo ""
