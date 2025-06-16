{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [dolphin-emu];

  # udev rules are necessary to use the Dolphin Emulator with a GameCube adapter
  services.udev.packages = with pkgs; [dolphin-emu];

  # Enable GCC to USB adapter overclocking for better polling rates
  boot.extraModulePackages = [config.boot.kernelPackages.gcadapter-oc-kmod];
  boot.kernelModules = ["gcadapter-oc-kmod"];
}
