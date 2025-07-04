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
    ./../../services/prometheus/exporters/node.nix
  ];

  # Enable as tailscale exit node
  services.tailscale.extraSetFlags = ["--advertise-exit-node"]; # Add exit node flag
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1; # Enable IPv4 forwarding
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1; # Enable IPv6 forwarding

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
