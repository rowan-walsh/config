_default:
    just --list --unsorted

up:
    nix flake update

lint:
    deadnix --fail .
    statix check .

fmt:
    nix fmt .

check:
    nix flake check

install CONFIG=`hostname` HOST="" USER=`whoami`:
    #!/usr/bin/env sh
    if [ -z "{{ HOST }}" ]; then
        echo -e "Installing \033[1m.#{{ CONFIG }}\033[0m config locally..."
        sudo nixos-rebuild switch --flake ".#{{ CONFIG }}"
    else
        echo -e "Installing \033[1m.#{{ CONFIG }}\033[0m config to \033[1m{{ USER }}@{{ HOST }}\033[0m..."
        nixos-rebuild switch --flake ".#{{ CONFIG }}" --sudo --ask-sudo-password --target-host "{{ USER }}@{{ HOST }}" --build-host "{{ USER }}@{{ HOST }}"
    fi

build-iso:
    nix --extra-experimental-features "nix-command flakes" build ".#nixosConfigurations.iso.config.system.build.isoImage"

build-wsl:
    nix --extra-experimental-features "nix-command flakes" run ".#nixosConfigurations.nuv6660-wsl.config.system.build.tarballBuilder"

secrets-edit:
    sops secrets/secrets.yaml

secrets-rotate:
    for file in secrets/*; do sops --rotate --in-place "$file"; done

secrets-sync:
    for file in secrets/*; do sops updatekeys "$file"; done
