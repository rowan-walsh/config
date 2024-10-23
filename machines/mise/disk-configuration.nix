{
  lib,
  pkgs,
  ...
}: let
  uefiFirmware = pkgs.fetchzip {
    url = "https://github.com/pftf/RPi4/releases/download/v1.38/RPi4_UEFI_Firmware_v1.38.zip";
    hash = "sha256-9tOr80jcmguFy2bSz+H3TfmG8BkKyBTFoUZkMy8x+0g=";
    stripRoot = false; # no root dir in the zip
  };
in {
  disko.devices = {
    disk = {
      "main" = {
        type = "disk";
        device = "/dev/mmcblk0";
        content = {
          type = "gpt";
          partitions = {
            "ESP" = {
              priority = 100;
              label = "EFI";
              type = "EF00";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                extraArgs = ["-n EFI"];
                mountOptions = ["umask=077"]; # prevents "security hole" warning
                mountpoint = "/boot";
                postMountHook = ''
                  mkdir -p /boot/firmware
                  rsync -a ${uefiFirmware}/ /boot/firmware
                '';
              };
            };
            "root" = {
              size = "100%";
              content = {
                type = "btrfs";
                subvolumes = {
                  "@nix" = {
                    mountOptions = ["noatime"];
                    mountpoint = "/nix";
                  };
                  "@persist" = {
                    mountOptions = ["noatime"];
                    mountpoint = "/persist";
                  };
                  "@logs" = {
                    mountOptions = ["noatime"];
                    mountpoint = "/var/log";
                  };
                };
              };
            };
          };
        };
      };
    };
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = ["defaults" "size=25%" "mode=755"];
    };
  };

  # Ensure that the persistent filesystems are mounted before boot
  # Currently no way to do this with disko
  fileSystems."/persist".neededForBoot = lib.mkForce true;
}
