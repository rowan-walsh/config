{config, ...}: {
  imports = [
    ./_nginx.nix
  ];

  services.grafana = {
    enable = true;
    settings.server = {
      domain = "grafana.local";
      http_port = 2342;
      http_addr = "127.0.0.1";
    };
    provision.datasources.settings.datasources = [
      {
        name = "Prometheus";
        type = "prometheus";
        access = "proxy";
        url = "http://127.0.0.1:${toString config.services.prometheus.port}";
      }
      {
        name = "Loki";
        type = "loki";
        access = "proxy";
        url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
      }
    ];
  };

  services.nginx.virtualHosts.${config.services.grafana.settings.server.domain} = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header Origin $http_origin;
      '';
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/grafana/data";
      mode = "0750";
      user = "grafana";
      group = "grafana";
      defaultPerms = {
        mode = "0700";
        user = "grafana";
        group = "grafana";
      };
    }
  ];
}
