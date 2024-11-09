{
  inputs,
  config,
  outputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko

    ./disk-configuration.nix
    ./hardware-configuration.nix

    ./../../modules/nixos/base.nix
    ./../../modules/nixos/desktop.nix

    ./../../services/dolphin-emu.nix

    ({config, ...}:
      import ./../../modules/nixos/wifi.nix {
        inherit config;
        interface = "enp0s31f6";
      })
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      "rww" = {
        imports = [
          ./../../modules/home-manager/base.nix
          ./../../modules/home-manager/desktop.nix
        ];
      };
    };
  };

  networking.hostName = "tweeze";
  networking.hostId = builtins.substring 0 8 (builtins.hashString "sha256" config.networking.hostName);
}
