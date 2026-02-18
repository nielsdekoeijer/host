#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 /dev/sdX"
    exit 1
fi

DEVICE="$1"
ISO=$(ls result/iso/*.iso 2>/dev/null | head -1)

if [[ -z "$ISO" ]]; then
    echo "No ISO found. Run ./iso-build.sh first."
    exit 1
fi

# Safety Checks
if [[ ! -b "$DEVICE" ]]; then
    echo "Error: $DEVICE is not a block device."
    exit 1
fi

if mount | grep -q "$DEVICE"; then
    echo "Error: $DEVICE seems to have mounted partitions. Unmount them first."
    echo "Run: sudo umount ${DEVICE}*"
    exit 1
fi

echo "========================================"
echo "ISO:    $ISO"
echo "Target: $DEVICE"
echo "========================================"
echo "Target Device Details:"
lsblk -o NAME,MODEL,SIZE,TYPE,FSTYPE,MOUNTPOINT "$DEVICE"
echo "========================================"
echo "WARNING: THIS WILL DESTROY ALL DATA ON $DEVICE"
read -rp "Are you absolutely sure? (Type 'YES' to confirm) > " CONFIRM

if [[ "$CONFIRM" != "YES" ]]; then
    echo "Aborted."
    exit 1
fi

# Use status=progress and fsync to ensure write is actually done
sudo dd if="$ISO" of="$DEVICE" bs=4M status=progress conv=fsync oflag=direct
echo "Done. Remove the USB and boot from it."
