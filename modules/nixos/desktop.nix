{pkgs, ...}: {
  # X11 windowing and GNOME desktop environment
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
}
