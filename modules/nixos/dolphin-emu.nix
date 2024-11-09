{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [dolphinEmu];

  # udev rules are necessary to use the Dolphin Emulator with a GameCube adapter
  services.udev.packages = with pkgs; [dolphinEmu];

  # Enable GCC to USB adapter overclocking for better polling rates
  boot.extraModulePackages = [config.boot.kernelPackages.gcadapter-oc-kmod];
  boot.kernelModules = ["gcadapter-oc-kmod"];
}
