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
    ./../../services/dns.nix
    # ./../../services/kea.nix
  ];

  # Static IP address since this is the DNS and DHCP server
  networking = {
    interfaces."enp0s31f6" = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.1.2";
          prefixLength = 24;
        }
      ];
    };
    nameservers = ["127.0.0.1"]; # DNS server is this machine
    defaultGateway = "192.168.1.1"; # router
  };

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

  networking.hostName = "misen";
  networking.hostId = builtins.substring 0 8 (builtins.hashString "sha256" config.networking.hostName);
}
