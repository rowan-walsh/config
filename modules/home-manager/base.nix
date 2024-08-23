{
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

  programs = {
    git = {
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
    bash = {
      enable = true;
    };
    jujutsu = {
      enable = true;
      settings = {
        "user.name" = "Rowan Walsh";
        "user.email" = "1158758+rowan-walsh@users.noreply.github.com";

        "ui.default-command" = "status";
        "ui.pager" = "less -FRX";
        "ui.editor" = "code --wait";
        "ui.diff-editor" = ":builtin";
        "ui.merge-editor" = ''["code", "--wait", "--merge", "$left", "$right", "$base", "$output"]'';
        "ui.merge-tools.code.merge-tool-edits-conflict-markers" = true;

        "signing.sign-all" = true;
        "signing.backend" = "gpg";
        "signing.key" = "7C222EAA5A246E8F";
      };
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
