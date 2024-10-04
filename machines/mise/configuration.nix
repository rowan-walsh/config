{
  inputs,
  config,
  outputs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko

    ./disk-configuration.nix
    ./hardware-configuration.nix

    ./../../modules/nixos/base.nix
    ./../../services/blocky.nix
    ./../../services/kea.nix
  ];

  # nixos-hardware defines a different boot loader
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;

  # Static IP address since this is the DNS and DHCP server
  networking.interfaces."end0".ipv4.addresses = [
    {
      address = "192.168.1.2";
      prefixLength = 24;
    }
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      "rww" = {
        imports = [
          ./../../modules/home-manager/base.nix
        ];
      };
    };
  };

  services.kea.dhcp4.settings.interfaces-config.interfaces = ["end0"];

  networking.hostName = "mise";
  networking.hostId = builtins.substring 0 8 (builtins.hashString "sha256" config.networking.hostName);
}
