{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./_packages.nix
  ];

  home = {
    # username = "rww";
    stateVersion = "24.05";
  };

  programs = {
    git = {
      enable = true;
    };
    bash = {
      enable = true;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
