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

  nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

  sops = {
    defaultSopsFile = ./../../secrets/secrets.yaml;
    age.sshKeyPaths = ["/home/rww/.ssh/id_ed25519.pub"]; #TODO change
    secrets.user-password.neededForUsers = true;
    secrets.user-password = {};
  };

  users.mutableUsers = false;
  users.users.rww = {
    isNormalUser = true;
    description = "Rowan Walsh";
    extraGroups = ["networkmanager" "wheel"];
    hashedPasswordFile = config.sops.secrets.user-password.path;
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
