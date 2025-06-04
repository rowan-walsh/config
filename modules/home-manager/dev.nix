{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.vscode = {
    enable = true;
    profiles.default = {
      enableExtensionUpdateCheck = false;
      extensions = with pkgs.vscode-extensions;
        [
          bbenoist.nix
          charliermarsh.ruff
          elixir-lsp.vscode-elixir-ls
          editorconfig.editorconfig
          github.copilot
          github.copilot-chat
          golang.go
          ms-azuretools.vscode-docker
          ms-python.debugpy
          ms-python.python
          ms-python.vscode-pylance
          ms-toolsai.jupyter
          ms-toolsai.jupyter-keymap
          ms-toolsai.jupyter-renderers
          ms-toolsai.vscode-jupyter-cell-tags
          ms-toolsai.vscode-jupyter-slideshow
          ms-vscode-remote.remote-containers
          ms-vscode-remote.remote-ssh
          ms-vscode-remote.remote-ssh-edit
          ms-vscode-remote.remote-wsl
          ms-vscode.cpptools
          ms-vscode.hexeditor
          ms-vscode.makefile-tools
          ms-vscode.powershell
          nefrob.vscode-just-syntax
          pkief.material-icon-theme
          redhat.vscode-xml
          rust-lang.rust-analyzer
          tamasfe.even-better-toml
          timonwong.shellcheck
          vadimcn.vscode-lldb
          ziglang.vscode-zig
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "alignment";
            publisher = "annsk";
            version = "0.3.0";
            sha256 = "da29a516efb6dcdff716eb8150a664a5102f6be4ee95cc463f65d5f41d5933b0";
          }
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "vsc-material-theme-but-i-wont-sue-you";
            publisher = "t3dotgg";
            version = "35.0.3";
            sha256 = "453601d71405eea40273bce752b501e0f90a957175caf82b102ad96cd57b2440";
          }
        ];
      userSettings = lib.importJSON ./vscode/settings.json;
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user.name = config.programs.git.userName;
      user.email = config.programs.git.userEmail;

      ui.default-command = "status";
      ui.pager = "less -FRX";
      ui.editor = "code --wait";
      ui.diff-editor = ":builtin";
      ui.merge-editor = ["code" "--wait" "--merge" "$left" "$right" "$base" "$output"];
      ui.merge-tools.code.merge-tool-edits-conflict-markers = true;

      signing.behavior = "own";
      signing.backend = "gpg";
      signing.key = config.programs.git.signing.key;

      template-aliases."format_short_signature(signature)" = "signature.name()";

      aliases.l = ["log" "-n10"];
      aliases.logall = ["log" "-r" "all()"];
    };
  };
}
