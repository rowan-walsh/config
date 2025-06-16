{
  imports = [
    ./_packages.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

  users.users.rww = {
    isNormalUser = true;
    description = "rww";
  };

  security.sudo.wheelNeedsPassword = false;
  time.timeZone = "America/Vancouver";
  wsl.defaultUser = "rww";
  wsl.enable = true;
  zramSwap.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
