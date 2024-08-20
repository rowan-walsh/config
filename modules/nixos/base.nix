{
  inputs,
  config,
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
    network.ssh = {
      enable = true;
      port = 2222;
      hostKeys = ["/etc/ssh/initrd_ssh_host_ed25519_key"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkcgwjYMHqUDnx0JIOSXQ/TN80KEaFvvUWA2qH1AHFC"
      ];
    };

    secrets = {
      "initrd_ssh_host_ed25519_key" = "/etc/ssh/initrd_ssh_host_ed25519_key";
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

    files = [
      "/etc/machine-id"
      "/etc/ssh/initrd_ssh_host_ed25519_key.pub"
      "/etc/ssh/initrd_ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
    ];
  };

  users.mutableUsers = false;
  users.users.rww = {
    isNormalUser = true;
    description = "Rowan Walsh";
    extraGroups = ["networkmanager" "wheel"];
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

  time.timeZone = "America/Vancouver";

  i18n.defaultLocale = "en_US.UTF-8";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
