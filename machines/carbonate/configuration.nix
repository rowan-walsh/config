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
    ./../../modules/nixos/desktop.nix
    ./../../modules/nixos/portable.nix
    ./../../modules/nixos/zfs.nix

    (import ./../../modules/nixos/wifi.nix {
      inherit config;
      interface = "wlp2s0";
    })

    ./../../services/tailscale.nix
    ./../../services/prometheus/exporters/node.nix
    ./../../services/alloy.nix
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
          ./../../modules/home-manager/dev.nix
          ./../../modules/home-manager/fonts.nix
        ];
      };
    };
  };

  # Configure keyboard mapping
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Configure sound
  security.rtkit.enable = true;
  services = {
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  networking.hostName = "carbonate";
  networking.hostId = builtins.substring 0 8 (builtins.hashString "sha256" config.networking.hostName); # required for ZFS
}
