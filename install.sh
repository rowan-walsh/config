#!/usr/bin/env bash

set -e -u -o pipefail

echo -e "--- \033[1mRunning Install Script\033[0m ---"
if [ "$(uname)" == "Linux" ]; then
    echo -e "\nLinux detected..."

    # Display disk layout
    echo -e "\n\033[1mExisting Disk Layout:\033[0m"
    lsblk
    echo ""

    # Prompt user for disk name
    echo -e "\033[1mSelect Disk:\033[0m"
    read -r -p "Enter disk name (e.g. '/dev/nvme0n1'): " DISK
    if [ -b "$DISK" ]; then
        echo -e "\033[32mDisk '$DISK' will be used.\033[0m"
    else
        echo -e "\033[31mInvalid disk name.\033[0m"
        exit 1
    fi
    DISK_SUFFIX=$([[ $DISK =~ [0-9]$ ]] && echo "p") # Suffix is 'p' if disk ends with a number

    # Display system memory
    echo -e "\n\033[1mSystem Memory:\033[0m"
    MEM_TOTAL_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    MEM_TOTAL_MiB=$((MEM_TOTAL_KB * 1000 / 1024 ** 2))
    echo -e "Total memory: $MEM_TOTAL_MiB MiB"

    # Prompt user for swap size
    echo -e "\n\033[1mSwap Size:\033[0m"
    read -r -p "Enter swap size in GiB (e.g. '4'), for no swap leave blank: " SWAP_SIZE_GiB
    if [ -z "$SWAP_SIZE_GiB" ]; then
        echo -e "\033[32mNo swap partition will be created.\033[0m"
    elif [[ $SWAP_SIZE_GiB =~ ^[1-9][0-9]*$ ]]; then
        echo -e "\033[32mSwap partition will be created with $SWAP_SIZE_GiB GiB ($((SWAP_SIZE_GiB * 1024)) MiB).\033[0m"
    else
        echo -e "\033[31mInvalid input. Please enter a numerical value for swap size.\033[0m"
        exit 1
    fi

    # Prompt user for reserve size
    echo -e "\n\033[1mReserve Size:\033[0m"
    read -r -p "Enter reserve size in GiB (e.g. '4'), for no reserve leave blank: " RESERVE_SIZE_GiB
    if [ -z "$RESERVE_SIZE_GiB" ]; then
        RESERVE_SIZE_GiB=0
        echo -e "\033[32mNo reserve partition will be created.\033[0m"
    elif [[ $RESERVE_SIZE_GiB =~ ^[1-9][0-9]*$ ]]; then
        echo -e "\033[32mReserve partition will be created with $RESERVE_SIZE_GiB GiB ($((RESERVE_SIZE_GiB * 1024)) MiB).\033[0m"
    else
        echo -e "\033[31mInvalid input. Please enter a numerical value for reserve size.\033[0m"
        exit 1
    fi

    # Display warning, wait for confirmation
    echo -e "\n\033[1;31mWarning: After this point the script is irreversible, all disk data will be lost.\033[0m"
    read -n 1 -s -r -p "Press Ctrl+C to abort, or any other key to continue..."
    echo -e "\n"

    # Undo any previous changes
    echo -e "\n\033[1mUndoing any previous changes...\033[0m"
    set +e
    umount --recursive /mnt
    cryptsetup close cryptroot
    set -e
    echo -e "\033[32mPrevious changes undone.\033[0m"

    # Partition disk
    echo -e "\n\033[1mPartitioning disk...\033[0m"
    parted "$DISK" -- mklabel gpt
    parted "$DISK" -- mkpart ESP fat32 1MiB 513MiB
    parted "$DISK" -- set 1 boot on
    DISK_BOOT_PARTITION="${DISK}${DISK_SUFFIX}1"
    if [ -z "$SWAP_SIZE_GiB" ]; then
        parted "$DISK" -- mkpart Nix ext4 513MiB -"${RESERVE_SIZE_GiB}"GiB
        DISK_NIX_PARTITION="${DISK}${DISK_SUFFIX}2"
    else
        parted "$DISK" -- mkpart Swap linux-swap 513MiB $((513 + 1024*SWAP_SIZE_GiB))MiB
        parted "$DISK" -- mkpart Nix ext4 $((513 + 1024*SWAP_SIZE_GiB))MiB -"${RESERVE_SIZE_GiB}"GiB
        DISK_SWAP_PARTITION="${DISK}${DISK_SUFFIX}2"
        DISK_NIX_PARTITION="${DISK}${DISK_SUFFIX}3"
    fi
    echo -e "\033[32mDisk partitioned successfully.\033[0m"

    # Set up encryption (will prompt for password)
    echo -e "\n\033[1mSetting up encryption (script will prompt for crypt password)...\033[0m"
    cryptsetup -q -v --verify-passphrase luksFormat "$DISK_NIX_PARTITION"
    cryptsetup -q -v open "$DISK_NIX_PARTITION" cryptroot
    DISK_NIX_ENCRYPT="/dev/mapper/cryptroot"
    echo -e "\033[32mEncryption set up successfully.\033[0m"

    # Creating filesystems
    echo -e "\n\033[1mCreating filesystems...\033[0m"
    mkfs.vfat -n boot "$DISK_BOOT_PARTITION"
    if [ -n "$SWAP_SIZE_GiB" ]; then
        mkswap -L swap "$DISK_SWAP_PARTITION"
        swapon "$DISK_SWAP_PARTITION"
    fi
    sleep 1 # Let mkfs catch its breath
    zpool create \
        -o ashift=12 \
        -o autotrim=on \
        -R /mnt \
        -O acltype=posixacl \
        -O canmount=off \
        -O dnodesize=auto \
        -O normalization=formD \
        -O relatime=on \
        -O xattr=sa \
        -O mountpoint=none \
        rpool \
        $DISK_NIX_ENCRYPT
    echo -e "\033[32mFilesystems created successfully.\033[0m"

    # Mounting filesystems
    echo -e "\n\033[1mMounting filesystems...\033[0m"
    zfs create -p -o mountpoint=legacy rpool/local/root
    zfs snapshot rpool/local/root@blank # For rollback
    zfs create -p -o mountpoint=legacy rpool/safe/home
    zfs create -p -o mountpoint=legacy rpool/local/nix
    zfs create -p -o mountpoint=legacy rpool/safe/persist
    zfs create -p -o mountpoint=legacy rpool/safe/log
    mount -t zfs rpool/local/root /mnt
    mkdir -pv /mnt/{boot,home,nix,persist,var/log}
    mount "$DISK_BOOT_PARTITION" /mnt/boot
    mount -t zfs rpool/safe/home /mnt/home
    mount -t zfs rpool/local/nix /mnt/nix
    mount -t zfs rpool/safe/persist /mnt/persist
    mount -t zfs rpool/safe/log /mnt/var/log
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
    ssh-to-age < /mnt/etc/ssh/initrd_ssh_host_ed25519_key.pub
    echo -e "\033[32mAge public key generated successfully.\033[0m"

    # Completed
    echo -e "\n\033[1;32mAll steps completed successfully. NixOS is now ready to be installed.\033[0m\n"
    echo -e "Remember to add the server's host public key to sops-nix before installing!"
    echo -e "To install NixOS configuration for hostname, run the following command:\n"
    echo -e "    \033[1msudo nixos-install --no-root-passwd --root /mnt --flake github:rowan-walsh/config#[HOSTNAME]\033[0m\n"
  else
    echo -e "\033[31mUnsupported system type.\033[0m"
    echo "Exiting..."
fi
