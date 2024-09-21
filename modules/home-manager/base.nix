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
        "user.name" = config.programs.git.userName;
        "user.email" = config.programs.git.userEmail;

        "ui.default-command" = "status";
        "ui.pager" = "less -FRX";
        "ui.editor" = "code --wait";
        "ui.diff-editor" = ":builtin";
        "ui.merge-editor" = ''["code", "--wait", "--merge", "$left", "$right", "$base", "$output"]'';
        "ui.merge-tools.code.merge-tool-edits-conflict-markers" = true;

        "signing.sign-all" = true;
        "signing.backend" = "gpg";
        "signing.key" = config.programs.git.signing.key;

        "template-aliases.'format_short_signature(signature)'" = "'signature.name()'";
      };
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
