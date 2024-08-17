{
  imports = [./../../modules/nixos/iso.nix];

  # Use faster squashfs compression
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  networking.hostName = "iso";
}
