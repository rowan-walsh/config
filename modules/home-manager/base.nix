{
  home = {
    username = "rww";
    homeDirectory = "/home/rww";
    stateVersion = "24.05";
  };

  programs.git = {
    enable = true;
    userName = "Rowan Walsh";
    userEmail = "1158758+rowan-walsh@users.noreply.github.com";
    extraConfig.init.defaultBranch = "main";
  };
  programs.bash.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
