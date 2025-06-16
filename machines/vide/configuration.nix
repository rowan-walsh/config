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
    ./../../modules/nixos/steam.nix
    ./../../modules/nixos/zfs.nix

    ./../../services/tailscale.nix
  ];

  # Enable as tailscale exit node
  services.tailscale.extraSetFlags = config.services.tailscale.extraUpFlags or [] ++ ["--advertise-exit-node"];

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
          ./../../modules/home-manager/gpg.nix
        ];

        home.packages = with pkgs; [
          prusa-slicer
          signal-desktop
          tidal-hifi
          vlc
        ];

        dconf = {
          settings = {
            "org/gnome/desktop/interface" = {
              text-scaling-factor = 1.25; # easier to read on main monitor
            };
          };
        };
      };
    };
  };

  networking.hostName = "vide";
  networking.hostId = builtins.substring 0 8 (builtins.hashString "sha256" config.networking.hostName); # required for ZFS
}
