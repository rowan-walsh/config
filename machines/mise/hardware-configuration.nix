{
  inputs,
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
