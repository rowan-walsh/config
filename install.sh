#!/usr/bin/env bash

set -e -u -o pipefail

if [ "$(uname)" == "Linux" ]; then
    # Display warning, wait for confirmation
    echo "Linux detected"
    echo -e "\n\033[1;31m**Warning:** This script is irreversible and will prepare system for NixOS installation.\033[0m"
    read -n 1 -s -r -p "Press any key to continue or Ctrl+C to abort..."

    # Display disk layout
    echo -e "\n\033[1mExisting Disk Layout:\033[0m"
    lsblk
    echo ""

    # Prompt user for disk name
    echo -e "\033[1mSelect Disk:\033[0m"
    read -p "Enter disk name (e.g. '/dev/nvme0n1'): " DISK
    if [ -b "$DISK" ]; then
        echo -e "\033[32mDisk '$DISK' will be used.\033[0m"
    else
        echo -e "\033[31mInvalid disk name.\033[0m"
        exit 1
    fi
    DISK_SUFFIX=$([[ $DISK =~ [0-9]$ ]] && echo "p") # Suffix is 'p' if disk ends with a number

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
    DISK_BOOT_PARTITION="${DISK}${DISK_SUFFIX}1"
    if [ -z "$SWAP_SIZE_GB" ]; then
        parted $DISK -- mkpart Nix ext4 513MiB 100%
        DISK_NIX_PARTITION="${DISK}${DISK_SUFFIX}2"
    else
        parted $DISK -- mkpart Swap linux-swap 513MiB $((513 + 1024*SWAP_SIZE_GB))MiB
        parted $DISK -- mkpart Nix ext4 $((513 + 1024*SWAP_SIZE_GB))MiB 100%
        DISK_SWAP_PARTITION="${DISK}${DISK_SUFFIX}2"
        DISK_NIX_PARTITION="${DISK}${DISK_SUFFIX}3"
    fi
    echo -e "\033[32mDisk partitioned successfully.\033[0m"

    # Set up encryption (will prompt for password)
    echo -e "\n\033[1mSetting up encryption, will prompt for crypt password...\033[0m"
    cryptsetup -q -v --verify-passphrase luksFormat $DISK_NIX_PARTITION
    cryptsetup -q -v open $DISK_NIX_PARTITION cryptroot
    DISK_NIX_ENCRYPT="/dev/mapper/cryptroot"
    echo -e "\033[32mEncryption set up successfully.\033[0m"

    # Creating filesystems
    echo -e "\n\033[1mCreating filesystems...\033[0m"
    mkfs.vfat -n boot $DISK_BOOT_PARTITION
    if [ ! -z "$SWAP_SIZE_GB" ]; then
        mkswap -L swap $DISK_SWAP_PARTITION
        swapon $DISK_SWAP_PARTITION
    fi
    mkfs.btrfs -L nix $DISK_NIX_ENCRYPT
    sleep 2 # Let mkfs catch its breath
    echo -e "\033[32mFilesystems created successfully.\033[0m"

    # Mounting filesystems
    echo -e "\n\033[1mMounting filesystems...\033[0m"
    mount -t btrfs $DISK_NIX_ENCRYPT /mnt
    btrfs subvolume create /mnt/root
    btrfs subvolume create /mnt/home
    btrfs subvolume create /mnt/nix
    btrfs subvolume create /mnt/persist
    btrfs subvolume create /mnt/log
    btrfs subvolume snapshot -r /mnt/root /mnt/root-blank # For rollback
    umount /mnt
    mount -o subvol=root,compress=zstd,noatime $DISK_NIX_ENCRYPT /mnt
    mkdir -pv /mnt/{boot,home,nix,persist,var/log}
    mount $DISK_BOOT_PARTITION /mnt/boot
    mount -o subvol=home,compress=zstd,noatime $DISK_NIX_ENCRYPT /mnt/home
    mount -o subvol=nix,compress=zstd,noatime $DISK_NIX_ENCRYPT /mnt/nix
    mount -o subvol=persist,compress=zstd,noatime $DISK_NIX_ENCRYPT /mnt/persist
    mount -o subvol=log,compress=zstd,noatime $DISK_NIX_ENCRYPT /mnt/var/log
    echo -e "\033[32mFilesystems mounted successfully.\033[0m"

    # Generating initrd SSH host key
    echo -e "\n\033[1mGenerating initrd SSH host keys...\033[0m"
    mkdir -pv /mnt/etc/ssh
    chown root:root /mnt/etc/ssh
    chmod 700 /mnt/etc/ssh
    ssh-keygen -t ed25519 -N "" -C "" -f  /mnt/etc/ssh/initrd_ssh_host_ed25519_key
    chown root:root /mnt/etc/ssh/initrd_ssh_host_ed25519_key
    chmod 600 /mnt/etc/ssh/initrd_ssh_host_ed25519_key
    echo -e "\033[32mSSH host keys generated successfully.\033[0m"

    # Creating public age key for sops-nix
    echo -e "\n\033[1mConverting initrd public SSH host key into public age key for sops-nix...\033[0m"
    sudo nix-shell --extra-experimental-features flakes -p ssh-to-age --run 'cat /mnt/etc/ssh/initrd_ssh_host_ed25519_key.pub | ssh-to-age'
    echo -e "\033[32mAge public key generated successfully.\033[0m"

    # Completed
    echo -e "\n\033[1;32mAll steps completed successfully. NixOS is now ready to be installed.\033[0m\n"
    echo -e "Remember to add the server's host public key to sops-nix before installing!"
    echo -e "To install NixOS configuration for hostname, run the following command:\n"
    echo -e "\033[1msudo nixos-install --no-root-passwd --root /mnt --flake github:rowan-walsh/config#[HOSTNAME]\033[0m\n"
  else
    echo -e "\033[31mUnsupported system type.\033[0m"
    echo "Exiting..."
fi
