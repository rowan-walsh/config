#!/usr/bin/env bash

set -e -u -o pipefail

echo -e "--- \033[1mRunning Install Script\033[0m ---"

# Prompt user for hostname
echo -e "\n\033[1mSelect NixOS configuration to install:\033[0m"
configs=$(nix flake show github:rowan-walsh/config --json | jq '.nixosConfigurations | keys[]' --raw-output)
PS3="Select configuration (by number): "
select config_name in $configs; do
  if [ -n "$config_name" ]; then
    echo -e "\033[32mSelected configuration '$config_name'.\033[0m"
    break
  else
    echo -e "\033[31mInvalid selection.\033[0m"
    exit 1
  fi
done

if [ "$(uname)" == "Linux" ]; then
    echo -e "\nLinux detected..."

    # Display disk layout
    echo -e "\n\033[1mExisting Disk Layout:\033[0m"
    lsblk

    # Display warning, wait for confirmation
    echo -e "\n\033[1;31mWarning: After this point the script is irreversible, all disk data will be lost.\033[0m"
    read -n 1 -s -r -p "Press Ctrl+C to abort, or any other key to continue..."

    # Unmount, format, and mount disk(s)
    echo -e "\n\033[1mRunning disko to format and mount disk(s)...\033[0m"
    sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
        --mode disko \
        --flake "github:rowan-walsh/config#$config_name" \
        --root-mountpoint /mnt
    echo -e "\033[32mDisks formatted and mounted successfully.\033[0m"

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
    echo -e "Then to install NixOS configuration, run the following command:"
    echo -e "    \033[1msudo nixos-install --no-root-passwd --root /mnt --flake github:rowan-walsh/config#$config_name\033[0m\n"
  else
    echo -e "\033[31mUnsupported system type.\033[0m"
    echo "Exiting..."
fi
