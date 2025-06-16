{lib, ...}: {
  disko.devices = {
    disk = {
      "nvme0" = {
        type = "disk";
        device = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_M.2_250GB_S33CNX0H520222H";
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
            "zfs" = {
              end = "-22G";
              content = {
                type = "zfs";
                pool = "rpool";
              };
            };
            "swap" = {
              size = "20G"; # leave some unused space
              content = {
                type = "swap";
                discardPolicy = "both";
              };
            };
          };
        };
      };
      "ssd0" = {
        type = "disk";
        device = "/dev/disk/by-id/ata-M4-CT256M4SSD3_0000000013010923A0D5";
        content = {
          type = "gpt";
          partitions = {
            "zfs" = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rpool";
              };
            };
          };
        };
      };
      "hd0" = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST1000DM003-1SB102_Z9A33AG9";
        content = {
          type = "gpt";
          partitions = {
            "zfs" = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "storage";
              };
            };
          };
        };
      };
      "hd1" = {
        type = "disk";
        device = "/dev/disk/by-id/ata-Hitachi_HTS545050B9A300_100905PBN40017JG208E";
        content = {
          type = "gpt";
          partitions = {
            "zfs" = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "storage";
              };
            };
          };
        };
      };
      "hd2" = {
        type = "disk";
        device = "/dev/disk/by-id/ata-HITACHI_HTS727550A9E364_J37B0084HARYUE";
        content = {
          type = "gpt";
          partitions = {
            "zfs" = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "storage";
              };
            };
          };
        };
      };
    };
    zpool = {
      "rpool" = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                mode = ""; # No mirroring or raidz (single disk)
                members = ["nvme0"];
              }
              {
                mode = ""; # No mirroring or raidz (single disk)
                members = ["ssd0"];
              }
            ];
          };
        };
        options = {
          ashift = "12"; # 4KiB sector size
          autotrim = "on";
        };
        rootFsOptions = {
          acltype = "posixacl";
          canmount = "off";
          dnodesize = "auto";
          normalization = "formD";
          relatime = "on";
          xattr = "sa";
          mountpoint = "none";
        };

        # Take blank snapshot if it doesn't already exist
        postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^rpool/local/root@blank$' || zfs snapshot rpool/local/root@blank";

        datasets = {
          "local/root" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/";
          };

          "safe/home" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/home";
          };

          "local/nix" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/nix";
          };

          "safe/persist" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/persist";
          };
        };
      };
      "storage" = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                mode = "raidz1";
                members = ["hd0" "hd1" "hd2"];
              }
            ];
          };
        };
        options = {
          ashift = "12"; # 4KiB sector size
          autotrim = "on";
        };
        rootFsOptions = {
          acltype = "posixacl";
          canmount = "off";
          dnodesize = "auto";
          normalization = "formD";
          relatime = "on";
          xattr = "sa";
          mountpoint = "none";
        };

        datasets = {
          "safe/storage" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/storage";
          };

          "safe/log" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/var/log";
          };
        };
      };
    };
  };

  # Ensure that the persistent datasets are mounted before boot
  # Currently no way to do this with disko
  fileSystems = {
    "/home".neededForBoot = lib.mkForce true;
    "/persist".neededForBoot = lib.mkForce true;
    "/storage".neededForBoot = lib.mkForce true;
    "/var/log".neededForBoot = lib.mkForce true;
  };
}
