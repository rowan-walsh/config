{
  imports = [
    ./_packages.nix
  ];

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = ["wheel"];
  };

  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  services.openssh = {
    enable = true;
  };

  system.stateVersion = "24.05";
}
