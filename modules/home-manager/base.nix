{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./_packages.nix
  ];

  home = {
    username = "rww";
    homeDirectory = "/home/rww";
    stateVersion = "24.05";
  };

  programs.git = {
    enable = true;
    userName = "Rowan Walsh";
    userEmail = "1158758+rowan-walsh@users.noreply.github.com";
    signing.signByDefault = true;
    signing.key = "7C222EAA5A246E8F";
    extraConfig = {
      init.defaultBranch = "main";
      core.autocrlf = "input";
    };
  };
  programs.bash = {
    enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
