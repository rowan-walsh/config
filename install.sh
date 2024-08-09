#!/usr/bin/env bash

set -e -u -o pipefail

if [ "$(uname)" == "Linux" ]; then
    # Define disk
    DISK="/dev/nvme0n1"
    DISK_BOOT_PARTITION="/dev/nvme0n1p1"
    DISK_NIX_PARTITION="/dev/nvme0n1p2"

    # Display warning, wait for confirmation
    echo "Linux detected"
    echo -e "\n\033[1;31m**Warning:** This script is irreversible and will prepare system for NixOS installation.\033[0m"
    read -n 1 -s -r -p "Press any key to continue or Ctrl+C to abort..."

    # Clear screen
    clear

    # Display disk layout
    echo -e "\n\033[1mDisk Layout:\033[0m"
    lsblk
    echo ""

    # Undo any previous changes
    echo -e "\n\033[1mUndoing any previous changes...\033[0m"
    set +e
    umount -R /mnt
    cryptsetup close cryptroot
    set -e
    echo -e "\033[32mPrevious changes undone.\033[0m"


else
    echo "Unsupported system type"
    echo "Exiting..."
fi
