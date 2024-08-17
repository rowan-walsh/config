{pkgs, ...}: {
  programs.brave.enable = true;
  programs.vscode.enable = true;

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
      "org/gnome/mutter" = {
        # Fractional scaling
        experimental-features = ["scale-monitor-framebuffer"];
      };
      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
        night-light-temperature = 3700;
      };
      #   "org/gnome/desktop/background" = {
      #       picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/morphogenesis-l.svg";
      #       picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/morphogenesis-d.svg";
      #   };
      #   "org/gnome/desktop/screensaver" = {
      #       picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/morphogenesis-d.svg";
      #       primary-color = "#e18477";
      #       secondary-color = "#000000";
      #   };
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
