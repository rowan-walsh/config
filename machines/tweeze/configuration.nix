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
    ./../../modules/nixos/dolphin-emu.nix
    ./../../modules/nixos/public.nix
    ./../../modules/nixos/zfs.nix

    ({config, ...}:
      import ./../../modules/nixos/wifi.nix {
        inherit config;
        interface = "wlp2s0";
      })
  ];

  environment.persistence."/persist".directories = [
    {
      directory = "/srv/shared-games";
      mode = "0777";
    }
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      "rww" = {lib, ...}: {
        imports = [
          ./../../modules/home-manager/base.nix
          ./../../modules/home-manager/desktop.nix
        ];

        # Create a symlink to the shared games folder
        home.activation.linkGames = lib.hm.dag.entryAfter ["writeBoundary"] ''
          run ln -sfn $VERBOSE_ARG /srv/shared-games $HOME/Games
        '';
      };

      "public" = {lib, ...}: {
        imports = [
          ./../../modules/home-manager/base-public.nix
          ./../../modules/home-manager/desktop.nix
        ];

        # Create a symlink to the shared games folder
        home.activation.linkGames = lib.hm.dag.entryAfter ["writeBoundary"] ''
          run ln -sfn $VERBOSE_ARG /srv/shared-games $HOME/Games
        '';

        dconf = {
          settings = {
            "org/gnome/desktop/interface" = {
              text-scaling-factor = 1.25; # easier to read on TV
            };
            "org/gnome/desktop/session" = {
              idle-delay = lib.hm.gvariant.mkUint32 0; # Never lock the screen
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

  # Prevent auto-suspend from login page
  services.displayManager.gdm.autoSuspend = false;

  networking.hostName = "tweeze";
  networking.hostId = builtins.substring 0 8 (builtins.hashString "sha256" config.networking.hostName);
}
