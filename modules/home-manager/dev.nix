{
  config,
  lib,
  pkgs,
  ...
}: {
  programs = {
    vscode = {
      enable = true;
      profiles.default = {
        enableExtensionUpdateCheck = false;
        extensions = with pkgs.vscode-extensions;
          [
            bbenoist.nix
            charliermarsh.ruff
            editorconfig.editorconfig
            github.copilot
            github.copilot-chat
            golang.go
            ms-python.debugpy
            ms-python.python
            ms-python.vscode-pylance
            ms-vscode.hexeditor
            ms-vscode.powershell
            nefrob.vscode-just-syntax
            pkief.material-icon-theme
            redhat.vscode-xml
            rust-lang.rust-analyzer
            tamasfe.even-better-toml
            timonwong.shellcheck
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

        signing = {
          behavior = "own";
          backend = "gpg";
          key = config.programs.git.signing.key;
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
  };
}
