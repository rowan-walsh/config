{lib, ...}: {
  disko.devices = {
    disk = {
      "main" = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            "ESP" = {
              type = "EF00";
              start = "1M";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat"; # or "fat32"?
                mountOptions = ["umask=077"]; # prevents "security hole" warning
                mountpoint = "/boot";
              };
            };
            "Nix" = {
              end = "-11G";
              content = {
                type = "luks";
                name = "cryptroot";
                askPassword = true;
                initrdUnlock = true;
                content = {
                  type = "zfs";
                  pool = "rpool";
                };
              };
            };
            "Swap" = {
              size = "10G";
              content = {
                type = "swap";
                discardPolicy = "both";
              };
            };
          };
        };
      };
    };
    zpool = {
      "rpool" = {
        type = "zpool";
        mode = ""; # No mirroring or raidz (single disk)
        options = {
          ashift = "12";
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
    "/var/log".neededForBoot = lib.mkForce true;
  };
}
