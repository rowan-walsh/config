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

secrets-edit:
    sops secrets/secrets.yaml

secrets-rotate:
    for file in secrets/*; do sops --rotate --in-place "$file"; done
  
secrets-sync:
    for file in secrets/*; do sops updatekeys "$file"; done
