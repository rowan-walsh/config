{
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;

      server = {
        http_listen_port = 3100;
        grpc_listen_port = 9096;
        log_level = "warn";
      };

      common = {
        path_prefix = "/var/lib/loki";
        storage.filesystem = {
          chunks_directory = "/var/lib/loki/chunks";
          rules_directory = "/var/lib/loki/rules";
        };
        replication_factor = 1;
        ring = {
          instance_addr = "127.0.0.1";
          kvstore.store = "inmemory";
        };
      };

      query_range.results_cache.cache.embedded_cache.enabled = true;

      schema_config.configs = [
        {
          from = "2024-04-01";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index.prefix = "index_";
          index.period = "24h";
        }
        # Never modify above, only append newer configs
      ];

      storage_config = {
        tsdb_shipper = {
          active_index_directory = "/var/lib/loki/tsdb-shipper-active";
          cache_location = "/var/lib/loki/tsdb-shipper-cache";
        };
        filesystem.directory = "/var/lib/loki/chunks";
      };

      limits_config = {
        reject_old_samples = true;
        reject_old_samples_max_age = "168h"; # 1 week
        ingestion_rate_mb = 4;
        ingestion_burst_size_mb = 6;
        per_stream_rate_limit = "3MB";
        per_stream_rate_limit_burst = "15MB";
        retention_period = "60d";
      };

      compactor = {
        working_directory = "/var/lib/loki/compactor";
        retention_enabled = true;
        delete_request_store = "filesystem";
      };

      analytics.reporting_enabled = false;
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/loki";
      mode = "0700";
      user = "loki";
      group = "loki";
    }
  ];
}
