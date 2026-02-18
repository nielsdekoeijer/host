#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 /dev/sdX"
    exit 1
fi

DEVICE="$1"
ISO=$(ls result/iso/*.iso 2>/dev/null | head -1)

if [[ -z "$ISO" ]]; then
    echo "No ISO found. Run ./build-iso.sh first."
    exit 1
fi

echo "Will write: $ISO"
echo "To device:  $DEVICE"
echo ""
lsblk "$DEVICE"
echo ""
echo "THIS WILL ERASE $DEVICE"
read -rp "    Proceed? (yes/no) > " CONFIRM

if [[ "$CONFIRM" != "yes" && "$CONFIRM" != "y" ]]; then
    echo "Aborted."
    exit 1
fi

sudo dd if="$ISO" of="$DEVICE" bs=4M status=progress oflag=sync
sync
echo "Done. Remove the USB and boot from it."
