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

install MACHINE=`hostname` IP="" USER=`whoami`:
    #!/usr/bin/env sh
    if [ -z "{{ IP }}" ]; then
        sudo nixos-rebuild switch --fast --flake ".#{{ MACHINE }}"
    else
        nixos-rebuild switch --fast --flake ".#{{ MACHINE }}" --use-remote-sudo --target-host "{{ USER }}@{{ IP }}" --build-host "{{ USER }}@{{ IP }}"
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
