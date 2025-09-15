{
  services.zrepl = {
    enable = true;
    settings = {
      jobs = [
        {
          name = "snapshots";
          type = "snap";
          filesystems = {
            "rpool/safe/home" = true;
          };
          snapshotting = {
            type = "periodic";
            prefix = "zrepl_";
            interval = "15m";
          };
          pruning.keep = [
            {
              type = "grid";
              grid = "1x1h(keep=all) | 24x1h | 7x1d | 4x1w | 12x30d";
              regex = "^zrepl_.*";
            }
            {
              type = "regex";
              negate = true;
              regex = "^zrepl_.*";
            }
          ];
        }
      ];
    };
  };
}
