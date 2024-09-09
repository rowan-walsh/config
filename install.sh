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
    sudo umount --recursive /mnt
    sudo cryptsetup close cryptroot
    set -e
    echo -e "\033[32mPrevious changes undone.\033[0m"

    # Partition disk
    echo -e "\n\033[1mPartitioning disk...\033[0m"
    sudo parted "$DISK" -- mklabel gpt
    sudo parted "$DISK" -- mkpart ESP fat32 1MiB 513MiB
    sudo parted "$DISK" -- set 1 boot on
    DISK_BOOT_PARTITION="${DISK}${DISK_SUFFIX}1"
    if [ -z "$SWAP_SIZE_GiB" ]; then
        sudo parted "$DISK" -- mkpart Nix ext4 513MiB -"${RESERVE_SIZE_GiB}"GiB
        DISK_NIX_PARTITION="${DISK}${DISK_SUFFIX}2"
    else
        sudo parted "$DISK" -- mkpart Swap linux-swap 513MiB $((513 + 1024*SWAP_SIZE_GiB))MiB
        sudo parted "$DISK" -- mkpart Nix ext4 $((513 + 1024*SWAP_SIZE_GiB))MiB -"${RESERVE_SIZE_GiB}"GiB
        DISK_SWAP_PARTITION="${DISK}${DISK_SUFFIX}2"
        DISK_NIX_PARTITION="${DISK}${DISK_SUFFIX}3"
    fi
    echo -e "\033[32mDisk partitioned successfully.\033[0m"

    # Set up encryption (will prompt for password)
    echo -e "\n\033[1mSetting up encryption (script will prompt for crypt password several times)...\033[0m"
    sudo cryptsetup -q --verify-passphrase luksFormat "$DISK_NIX_PARTITION"
    sudo cryptsetup -q open "$DISK_NIX_PARTITION" cryptroot
    DISK_NIX_ENCRYPT="/dev/mapper/cryptroot"
    echo -e "\033[32mEncryption set up successfully.\033[0m"

    # Creating filesystems
    echo -e "\n\033[1mCreating filesystems...\033[0m"
    sudo mkfs.vfat -n BOOT "$DISK_BOOT_PARTITION"
    sleep 1 # Let mkfs catch its breath
    if [ -n "$SWAP_SIZE_GiB" ]; then
        sudo mkswap -L SWAP "$DISK_SWAP_PARTITION"
        sudo swapon "$DISK_SWAP_PARTITION"
    fi
    sleep 1 # Let mkfs catch its breath
    sudo zpool create \
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
    sudo zfs create -v -p -o mountpoint=legacy rpool/local/root
    sudo zfs snapshot rpool/local/root@blank # For rollback
    sudo zfs create -v -p -o mountpoint=legacy rpool/safe/home
    sudo zfs create -v -p -o mountpoint=legacy rpool/local/nix
    sudo zfs create -v -p -o mountpoint=legacy rpool/safe/persist
    sudo zfs create -v -p -o mountpoint=legacy rpool/safe/log
    sudo mount -v -t zfs rpool/local/root /mnt
    sudo mkdir -pv /mnt/{boot,home,nix,persist,var/log}
    sudo mount -v -o umask=077 "$DISK_BOOT_PARTITION" /mnt/boot
    sudo mount -v -t zfs rpool/safe/home /mnt/home
    sudo mount -v -t zfs rpool/local/nix /mnt/nix
    sudo mount -v -t zfs rpool/safe/persist /mnt/persist
    sudo mount -v -t zfs rpool/safe/log /mnt/var/log
    echo -e "\033[32mFilesystems mounted successfully.\033[0m"

    # Generating initrd SSH host key
    echo -e "\n\033[1mGenerating initrd SSH host keys...\033[0m"
    sudo mkdir -pv /mnt/persist/secret
    sudo chown root:root /mnt/persist/secret
    sudo chmod 700 /mnt/persist/secret
    sudo ssh-keygen -t ed25519 -N "" -C "" -f /mnt/persist/secret/initrd_ssh_host_ed25519_key
    sudo chown root:root /mnt/persist/secret/initrd_ssh_host_ed25519_key
    sudo chmod 600 /mnt/persist/secret/initrd_ssh_host_ed25519_key
    echo -e "\033[32mSSH host keys generated successfully.\033[0m"

    # Creating public age key for sops-nix
    echo -e "\n\033[1mConverting initrd public SSH host key into public age key for sops-nix...\033[0m"
    # Use nix-shell to run ssh-to-age with flakes (latest), if not available use ssh-to-age directly
    sudo nix-shell --extra-experimental-features flakes -p ssh-to-age \
        --run 'sudo cat /mnt/persist/secret/initrd_ssh_host_ed25519_key.pub | ssh-to-age' || \
        sudo cat /mnt/persist/secret/initrd_ssh_host_ed25519_key.pub | ssh-to-age
    echo -e "\033[32mAge public key generated successfully.\033[0m"

    # Completed
    echo -e "\n\033[1;32mAll steps completed successfully. NixOS is now ready to be installed.\033[0m\n"
    echo -e "Before installing, update the configuration repo:"
    echo -e "    - Add the server's age public key (echoed above) to the sops-nix config"
    echo -e "      Update .sops.yaml and then run \033[1mjust secrets-sync\033[0m"
    echo -e "    - Use the server disk UUIDs where necessary in its hardware-configuration.nix"
    echo -e "      The UUIDs can be retrieved with: \033[1mlsblk -o NAME,MAJ:MIN,SIZE,TYPE,MOUNTPOINTS,UUID\033[0m"
    echo -e "Then to install NixOS configuration (for [hostname]), run the following command:"
    echo -e "    \033[1msudo nixos-install --no-root-passwd --root /mnt --flake github:rowan-walsh/config#[hostname]\033[0m\n"
  else
    echo -e "\033[31mUnsupported system type.\033[0m"
    echo "Exiting..."
fi
