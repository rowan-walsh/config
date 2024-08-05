{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
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

  #TODO enable below once pw is handled with sops or something
  #users.mutableUsers = false;
  users.users.rww = {
    isNormalUser = true;
    description = "Rowan Walsh";
    extraGroups = ["networkmanager" "wheel"];
    # Set password with `passwd` for now
  };

  time.timeZone = "America/Vancouver";

  i18n.defaultLocale = "en_US.UTF-8";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
