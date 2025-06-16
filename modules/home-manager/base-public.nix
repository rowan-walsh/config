{
  home = {
    username = "public";
    homeDirectory = "/home/public";
    stateVersion = "24.05";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
