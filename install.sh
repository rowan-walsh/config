#!/usr/bin/env bash

set -e -u -o pipefail

if [ "$(uname)" == "Linux" ]; then
    # Define disk
    DISK="/dev/nvme0n1"

    # Display warning, wait for confirmation
    echo "Linux detected"
    echo -e "\n\033[1;31m**Warning:** This script is irreversible and will prepare system for NixOS installation.\033[0m"
    read -n 1 -s -r -p "Press any key to continue or Ctrl+C to abort..."

    # Prompt user for swap size
    echo -e "\n\033[1mSwap Size:\033[0m"
    read -p "Enter swap size in GiB (e.g. '4'), for no swap leave blank: " SWAP_SIZE_GB
    if [ -z "$SWAP_SIZE_GB" ]; then
        echo -e "\033[32mNo swap partition will be created.\033[0m"
    elif [[ $SWAP_SIZE_GB =~ ^[1-9][0-9]*$ ]]; then
        echo -e "\033[32mSwap partition will be created with $SWAP_SIZE_GB GiB.\033[0m"
    else
        echo -e "\033[31mInvalid input. Please enter a numerical value for swap size.\033[0m"
        exit 1
    fi

    clear

    # Display disk layout
    echo -e "\n\033[1mDisk Layout:\033[0m"
    lsblk
    echo ""

    # Undo any previous changes
    echo -e "\n\033[1mUndoing any previous changes...\033[0m"
    set +e
    umount --recursive /mnt
    cryptsetup close cryptroot
    set -e
    echo -e "\033[32mPrevious changes undone.\033[0m"

    # Partition disk
    echo -e "\n\033[1mPartitioning disk...\033[0m"
    parted $DISK -- mklabel gpt
    parted $DISK -- mkpart ESP fat32 1MiB 513MiB
    parted $DISK -- set 1 boot on
    DISK_BOOT_PARTITION="/dev/nvme0n1p1"
    if [ -z "$SWAP_SIZE_GB" ]; then
        parted $DISK -- mkpart Nix ext4 513MiB 100%
        DISK_NIX_PARTITION="/dev/nvme0n1p2"
    else
        parted $DISK -- mkpart Swap linux-swap -${SWAP_SIZE_GB}GiB 100%
        parted $DISK -- mkpart Nix ext4 513MiB -${SWAP_SIZE_GB}GiB
        DISK_SWAP_PARTITION="/dev/nvme0n1p2"
        DISK_NIX_PARTITION="/dev/nvme0n1p3"
        mkswap $DISK_SWAP_PARTITION
        swapon $DISK_SWAP_PARTITION
    fi
    echo -e "\033[32mDisk partitioned successfully.\033[0m"

    # Set up encryption (will prompt for password)
    echo -e "\n\033[1mSetting up encryption, will prompt for crypt password...\033[0m"
    cryptsetup -q -v luksFormat $DISK_NIX_PARTITION
    cryptsetup -q -v open $DISK_NIX_PARTITION cryptroot
    echo -e "\033[32mEncryption set up successfully.\033[0m"

    # Creating filesystems
    echo -e "\n\033[1mCreating filesystems...\033[0m"
    mkfs.fat -F32 -n boot $DISK_BOOT_PARTITION
    mkfs.ext4 -F -L nix -m 0 /dev/mapper/cryptroot
    sleep 2 # Let mkfs catch its breath
    echo -e "\033[32mFilesystems created successfully.\033[0m"

    # Mounting filesystems
    echo -e "\n\033[1mMounting filesystems...\033[0m"
    mount -t tmpfs none /mnt
    mkdir -pv /mnt/{boot,nix,etc/ssh,var/{lib,log}}
    mount /dev/disk/by-label/boot /mnt/boot
    mount /dev/disk/by-label/nix /mnt/nix
    mkdir -pv /mnt/nix/{secret/initrd,persist/{etc/ssh,var/{lib,log}}}
    chmod 0700 /mnt/nix/secret
    mount -o bind /mnt/nix/persist/var/log /mnt/var/log
    echo -e "\033[32mFilesystems mounted successfully.\033[0m"
else
    echo -e "\033[31mUnsupported system type.\033[0m"
    echo "Exiting..."
fi
