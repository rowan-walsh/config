{
  inputs,
  config,
  outputs,
  lib,
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
    ./../../modules/nixos/dolphin-emu.nix
    ./../../modules/nixos/public.nix
    ./../../modules/nixos/zfs.nix

    ({config, ...}:
      import ./../../modules/nixos/wifi.nix {
        inherit config;
        interface = "wlp2s0";
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

      "public" = {
        imports = [
          ./../../modules/home-manager/base-public.nix
          ./../../modules/home-manager/desktop.nix
        ];

        dconf = {
          settings = {
            "org/gnome/desktop/session" = with lib.gvariant; {
              idle-delay = mkUint32 0; # Never lock the screen
            };
            "org/gnome/settings-daemon/plugins/power" = {
              sleep-inactive-ac-type = "nothing"; # Never suspend
              power-button-action = "interactive"; # Power button powers off
            };
          };
        };
      };
    };
  };

  networking.hostName = "tweeze";
  networking.hostId = builtins.substring 0 8 (builtins.hashString "sha256" config.networking.hostName);
}
