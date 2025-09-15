{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    alejandra # for nix formatting
    claude-code
    deadnix # for nix linting
    devenv
    just
    gcc
    rustup
    sops # for secrets
    statix # for nix linting
    tinymist # for typst LSP
  ];

  programs = {
    vscode = {
      enable = true;
      profiles.default = {
        enableExtensionUpdateCheck = false;
        extensions = with pkgs.nix-vscode-extensions; [
          vscode-marketplace.bbenoist.nix
          vscode-marketplace.charliermarsh.ruff
          vscode-marketplace.chouzz.vscode-better-align
          vscode-marketplace.editorconfig.editorconfig
          vscode-marketplace.github.copilot
          vscode-marketplace.golang.go
          vscode-marketplace.lencerf.beancount
          vscode-marketplace.ms-python.debugpy
          vscode-marketplace.ms-python.python
          vscode-marketplace.ms-python.vscode-pylance
          vscode-marketplace.ms-vscode.hexeditor
          vscode-marketplace.ms-vscode.powershell
          vscode-marketplace.myriad-dreamin.tinymist
          vscode-marketplace.nefrob.vscode-just-syntax
          vscode-marketplace.pkief.material-icon-theme
          vscode-marketplace.redhat.vscode-xml
          vscode-marketplace.rust-lang.rust-analyzer
          vscode-marketplace.t3dotgg.vsc-material-theme-but-i-wont-sue-you
          vscode-marketplace.tamasfe.even-better-toml
          vscode-marketplace.timonwong.shellcheck
          vscode-marketplace.tomoki1207.pdf

          vscode-marketplace-release.github.copilot-chat
        ];
        userSettings = lib.importJSON ./vscode/settings.json;
      };
    };

    jujutsu = {
      enable = true;
      settings = {
        user.name = config.programs.git.userName;
        user.email = config.programs.git.userEmail;

        ui = {
          default-command = "status";
          pager = "less -FRX";
          editor = "code --wait";
          diff-editor = ":builtin";
          merge-editor = ["code" "--wait" "--merge" "$left" "$right" "$base" "$output"];
          merge-tools.code.merge-tool-edits-conflict-markers = true;
        };

        template-aliases."format_short_signature(signature)" = "signature.name()";

        aliases.l = ["log" "-n10"];
        aliases.logall = ["log" "-r" "all()"];
      };
    };

    uv = {
      enable = true;
      settings = {
        python-downloads = "never";
        python-preference = "only-system";
      };
    };

    go.enable = true;

    direnv.enable = true;
  };
}
