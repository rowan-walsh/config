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

    ./../../services/tailscale.nix
    ./../../services/grafana.nix
    ./../../services/prometheus
    ./../../services/prometheus/exporters/node.nix
  ];

  services.prometheus.scrapeConfigs = [
    {
      job_name = "node";
      static_configs = [
        {
          labels.alias = "misen";
          targets = ["misen:${toString config.services.prometheus.exporters.node.port}"];
        }
        {
          labels.alias = "tweeze";
          targets = ["tweeze:${toString config.services.prometheus.exporters.node.port}"];
        }
        {
          labels.alias = "vide";
          targets = ["vide:${toString config.services.prometheus.exporters.node.port}"];
        }
      ];
    }
    {
      job_name = "blocky";
      static_configs = [
        {
          labels.alias = "misen";
          targets = ["misen:4000"]; #TODO: Use config.services.blocky.settings.ports.http (need to make modules imported by not enabled)
        }
      ];
    }
    {
      job_name = "tailscale";
      static_configs = [
        {
          labels.alias = "misen";
          targets = ["misen:5252"];
        }
        {
          labels.alias = "tweeze";
          targets = ["tweeze:5252"];
        }
        {
          labels.alias = "vide";
          targets = ["vide:5252"];
        }
      ];
    }
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
