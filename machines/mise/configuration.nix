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
    ./../../services/blocky.nix
    # ./../../services/kea.nix
  ];

  # Raspberry pi 4
  # nixos-hardware defines a different boot loader
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;
  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  # Static IP address since this is the DNS and DHCP server
  networking.interfaces."end0" = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "192.168.1.2";
        prefixLength = 24;
      }
    ];
  };
  networking.nameservers = ["127.0.0.1"]; # DNS server is this machine
  networking.defaultGateway = "192.168.1.1"; # router

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

  # services.kea.dhcp4.settings.interfaces-config.interfaces = ["end0"];

  networking.hostName = "mise";
  networking.hostId = builtins.substring 0 8 (builtins.hashString "sha256" config.networking.hostName);
}
