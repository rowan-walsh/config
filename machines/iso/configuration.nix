{inputs, ...}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager

    ./../../modules/nixos/iso.nix
  ];

  # Use faster squashfs compression
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  home-manager.users."nixos" = import ./../../modules/home-manager/iso.nix;

  networking.hostName = "iso";
}
