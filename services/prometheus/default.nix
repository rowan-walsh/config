{config, ...}: {
  services.prometheus = {
    enable = true;
    port = 9001;

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            labels.alias = "misen";
            targets = ["misen:${toString config.services.prometheus.exporters.node.port}"];
          }
          {
            labels.alias = "tweeze";
            targets = ["tweeze:${toString config.services.prometheus.exporters.node.port}"];
          }
          {
            labels.alias = "vide";
            targets = ["vide:${toString config.services.prometheus.exporters.node.port}"];
          }
        ];
      }
    ];
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/prometheus2/data"; # v2.x
      mode = "0750";
      user = "prometheus";
      group = "prometheus";
      defaultPerms = {
        mode = "0700";
        user = "prometheus";
        group = "prometheus";
      };
    }
  ];
}
