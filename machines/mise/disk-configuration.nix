{
  disko.devices = {
    disk = {
      "main" = {
        type = "disk";
        device = "/dev/mmcblk1"; # typically /dev/mmcblk0 for the SD card
        content = {
          type = "gpt";
          partitions = {
            "ESP" = {
              type = "EF00";
              start = "1M";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountOptions = ["umask=077"]; # prevents "security hole" warning
                mountpoint = "/boot";
              };
            };
            "data" = {
              size = "100%";
              content = {
                type = "btrfs";
                subvolumes = {
                  "/nix" = {
                    mountOptions = ["noatime"];
                    mountpoint = "/nix";
                  };
                  "/persist" = {
                    mountOptions = ["noatime"];
                    mountpoint = "/persist";
                  };
                  "/logs" = {
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
}
