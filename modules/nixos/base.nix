{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops

    ./_packages.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  boot.initrd = {
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;
        hostKeys = ["/etc/ssh/initrd_ssh_host_ed25519_key"];
        authorizedKeys = config.users.users.rww.openssh.authorizedKeys.keys;
      };
    };

    secrets = {
      "initrd_ssh_host_ed25519_key" = "/etc/ssh/initrd_ssh_host_ed25519_key";
    };

    systemd.services.rollback = {
      description = "Rollback ZFS datasets to a pristine state";
      wantedBy = ["initrd.target"];
      after = ["zfs-import-rpool.service"]; # Is this right?
      before = ["sysroot.mount"];
      path = with pkgs; [zfs];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        zfs rollback -r rpool/local/root@blank && echo "Rollback complete"
      '';
    };
  };

  nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

  sops = {
    defaultSopsFile = ./../../secrets/secrets.yaml;
    age.sshKeyPaths = ["/etc/ssh/initrd_ssh_host_ed25519_key"];
    secrets."user-password" = {
      neededForUsers = true;
    };
  };

  environment.persistence."/persist" = {
    # Hide these mounts from the sidebar of file managers
    hideMounts = true;

    directories = [
      "/etc/NetworkManager/system-connections"
    ];

    files = [
      "/etc/adjtime"
      "/etc/machine-id"
      "/etc/ssh/initrd_ssh_host_ed25519_key.pub"
      "/etc/ssh/initrd_ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/var/lib/NetworkManager/secret_key"
      "/var/lib/NetworkManager/seen-bssids"
      "/var/lib/NetworkManager/timestamps"
    ];
  };

  users.mutableUsers = false;
  users.users.rww = {
    isNormalUser = true;
    description = "Rowan Walsh";
    extraGroups = ["networkmanager" "wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOqlX4bm2rUlVeonvpv2hxW0ajQg/UCCOUNJlmPSZ0dS"
    ];
    hashedPasswordFile = config.sops.secrets."user-password".path;
  };

  services = {
    openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
      openFirewall = true;
    };
  };

  networking = {
    firewall.enable = true;
  };

  security.sudo = {
    wheelNeedsPassword = false;
    extraConfig = ''
      # Rollback results in sudo lectures otherwise
      Defaults lecture = never
    '';
  };

  time.timeZone = "America/Vancouver";

  i18n.defaultLocale = "en_US.UTF-8";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
