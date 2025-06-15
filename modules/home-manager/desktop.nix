{
  lib,
  pkgs,
  ...
}: {
  programs.brave.enable = true;

  dconf = {
    enable = true;
    settings = with lib.hm.gvariant; {
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
      "org/gnome/mutter" = {
        experimental-features = ["scale-monitor-framebuffer"]; # Fractional scaling
      };
      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
        night-light-schedule-from = 21.0; # 9PM
        night-light-schedule-to = 6.0; # 6AM
        night-light-temperature = mkUint32 4500;
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        home = ["<Super>e"];
        calculator = ["<Super>c"];
        search = ["<Alt>f"];
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
