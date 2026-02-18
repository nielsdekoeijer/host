#!/usr/bin/env bash
set -euo pipefail

FLAKE_REPO="https://github.com/nielsdekoeijer/host"
WORK_DIR="/tmp/nixos-config"

echo ""
echo "NixOS Installer"
echo ""

# clone
if [[ -d "$WORK_DIR" ]]; then
    git -C "$WORK_DIR" pull
else
    git clone "$FLAKE_REPO" "$WORK_DIR"
fi

# device name
read -rp "Device name (e.g. work-laptop-2): " DEVICE
[[ -z "$DEVICE" ]] && echo "Empty name." && exit 1

DEVICE_DIR="$WORK_DIR/devices/$DEVICE"
if [[ -d "$DEVICE_DIR" ]]; then
    echo "Using existing devices/$DEVICE"
else
    cp -r "$WORK_DIR/devices/basic" "$DEVICE_DIR"
    echo "Created devices/$DEVICE from template"
fi

# disko
echo ""
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
echo ""
cat "$DEVICE_DIR/disko.nix"
echo ""
read -rp "Edit disko config? (y/n) " EDIT_DISKO
[[ "$EDIT_DISKO" == "y" ]] && vi "$DEVICE_DIR/disko.nix"

echo ""
echo "THIS WILL ERASE THE TARGET DISK."
read -rp "Proceed? (yes/no) " CONFIRM
[[ "$CONFIRM" != "yes" && "$CONFIRM" != "y" ]] && echo "Aborted." && exit 1

# hostname
echo ""
read -rp "Hostname (e.g. work-laptop): " HOSTNAME
[[ -z "$HOSTNAME" ]] && echo "Empty hostname." && exit 1

# check flake
if ! grep -q "\"$HOSTNAME\"" "$WORK_DIR/flake.nix"; then
    echo "$HOSTNAME not in flake.nix yet, opening editor..."
    vi "$WORK_DIR/flake.nix"
fi

# git add (flakes need tracked files)
git -C "$WORK_DIR" add -A

# partition
nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
    --mode destroy,format,mount "$DEVICE_DIR/disko.nix"

echo "Copying configuration to new system..."
TARGET_USER="niels"
TARGET_DIR="/mnt/home/$TARGET_USER/repositories/personal/host"

mkdir -p "$TARGET_DIR"
cp -a "$WORK_DIR/." "$TARGET_DIR/"

nixos-enter --root /mnt -c "chown -R 1000:1000 /home/$TARGET_USER/repositories"

echo ""
echo "Done. Set password..."
