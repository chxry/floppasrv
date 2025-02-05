{ config, ... }: {
  services.grafana = {
    enable = true;
    settings = {
      server = {
        root_url = "https://grafana.${config.networking.domain}/";
        http_port = 3001;
      };
    };
  };

  services.prometheus = {
    enable = true;
    port = 9001;

    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
    };

    scrapeConfigs = [
      {
        job_name = config.networking.hostName;
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }
      {
        job_name = "grafana";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.grafana.settings.server.http_port}" ];
        }];
      }
      {
        job_name = "prometheus";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.port}" ];
        }];
      }
    ];
  };

  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server.http_listen_port = 3010;
      
      common = {
        ring = {
          instance_addr = "127.0.0.1";
          kvstore.store = "inmemory";
        };
        replication_factor = 1;
        path_prefix = "/tmp/loki";
      };
      
      schema_config.configs = [{
        from = "2025-02-05";
        store = "tsdb";
        object_store = "filesystem";
        schema = "v13";
        index.prefix = "index_";
        index.period = "24h";
      }];

      storage_config.filesystem.directory = "/tmp/loki/chunks";
    };
  };

  services.alloy = {
    enable = true;
    configPath = ./config.alloy; # inline this here and fill in ports etc
  };
}
