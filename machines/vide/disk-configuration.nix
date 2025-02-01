{lib, ...}: {
  disko.devices = {
    disk = {
      "nvme0" = {
        type = "disk";
        device = "/dev/nvme0n1"; #TODO confirm
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
            "ZFS" = {
              end = "-22G";
              content = {
                type = "zfs";
                pool = "rpool";
              };
            };
            "Swap" = {
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
        device = "/dev/sda"; #TODO confirm
        content = {
          type = "gpt";
          partitions = {
            "ZFS" = {
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
        device = "/dev/sdb"; #TODO confirm
        content = {
          type = "gpt";
          partitions = {
            "ZFS" = {
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
        device = "/dev/sdc"; #TODO confirm
        content = {
          type = "gpt";
          partitions = {
            "ZFS" = {
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
        device = "/dev/sdd"; #TODO confirm
        content = {
          type = "gpt";
          partitions = {
            "ZFS" = {
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
  fileSystems."/home".neededForBoot = lib.mkForce true;
  fileSystems."/persist".neededForBoot = lib.mkForce true;
  fileSystems."/storage".neededForBoot = lib.mkForce true;
  fileSystems."/var/log".neededForBoot = lib.mkForce true;
}
