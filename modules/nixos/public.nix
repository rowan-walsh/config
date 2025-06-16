{config, ...}: {
  sops.secrets."public-user-password" = {
    neededForUsers = true;
  };

  users.users."public" = {
    isNormalUser = true;
    description = "Public User";
    extraGroups = ["networkmanager"];
    hashedPasswordFile = config.sops.secrets."public-user-password".path;
  };

  # Enable automatic login for the user
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "public";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
}
