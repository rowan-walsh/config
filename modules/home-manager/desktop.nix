{
  lib,
  pkgs,
  ...
}: {
  programs.brave.enable = true;
  programs.vscode = {
    enable = true;
    enableExtensionUpdateCheck = false;
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      charliermarsh.ruff
      elixir-lsp.vscode-elixir-ls
      equinusocio.vsc-material-theme
      equinusocio.vsc-material-theme-icons
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
      vadimcn.vscode-lldb
      ziglang.vscode-zig
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "alignment";
        publisher = "annsk";
        version = "0.3.0";
        sha256 = "da29a516efb6dcdff716eb8150a664a5102f6be4ee95cc463f65d5f41d5933b0";
      }
    ];
    userSettings = lib.importJSON ./vscode/settings.json;
  };

  dconf = {
    enable = true;
    settings = {
      #   "org/gnome/shell" = {
      #       favorite-apps = [
      #           "org.gnome.Nautilus.desktop"
      #           "brave.desktop"
      #           "code.desktop"
      #       ];
      #   };
      "org/gnome/desktop/interface" = {
        # Gnome dark mode
        color-scheme = "prefer-dark";
      };
      # inspo: https://github.com/NixOS/nixpkgs/issues/114514
      # "org/gnome/mutter" = {
      #   # Fractional scaling
      #   experimental-features = ["scale-monitor-framebuffer"];
      # };
      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
        night-light-temperature = 3700;
      };
      "org/gnome/desktop/background" = {
        picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/morphogenesis-l.svg";
        picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/morphogenesis-d.svg";
      };
      "org/gnome/desktop/screensaver" = {
        picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/morphogenesis-d.svg";
        primary-color = "#e18477";
        secondary-color = "#000000";
      };
      "org/gnome/shell" = {
        disable-user-extensions = false;

        # `gnome-extensions list` for a list
        enabled-extensions = [
          "AlphabeticalAppGrid@stuarthayhurst"
          "appindicatorsupport@rgcjonas.gmail.com"
          "clipboard-indicator@tudmotu.com"
        ];
      };
    };
  };

  home.packages = with pkgs; [
    gnomeExtensions.alphabetical-app-grid
    gnomeExtensions.appindicator
    gnomeExtensions.clipboard-indicator
  ];
}
