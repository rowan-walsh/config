_default:
    just --list --unsorted

up:
    nix flake update

lint:
    statix check .

fmt:
    nix fmt

install MACHINE="carbonate":
    sudo nixos-rebuild switch --flake ".#{{ MACHINE }}"

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
