{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.floppa.grafana;
in
{
  options = {
    services.floppa.grafana = {
      enable = lib.mkEnableOption "enable grafana";
      ports = {
        grafana = lib.mkOption { default = 3001; };
        prometheus = lib.mkOption { default = 9001; };
        node_exporter = lib.mkOption { default = 9002; };
        loki = lib.mkOption { default = 3010; };
        faro = lib.mkOption { default = 3011; };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.grafana = {
      enable = true;
      settings = {
        server = {
          root_url = "https://grafana.${config.networking.domain}/";
          http_port = cfg.ports.grafana;
        };
      };
    };

    services.prometheus = {
      enable = true;
      port = cfg.ports.prometheus;

      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = cfg.ports.node_exporter;
        };
      };

      scrapeConfigs = [
        {
          job_name = config.networking.hostName;
          static_configs = [
            {
              targets = [ "127.0.0.1:${toString cfg.ports.node_exporter}" ];
            }
          ];
        }
        {
          job_name = "grafana";
          static_configs = [
            {
              targets = [ "127.0.0.1:${toString cfg.ports.grafana}" ];
            }
          ];
        }
        {
          job_name = "prometheus";
          static_configs = [
            {
              targets = [ "127.0.0.1:${toString cfg.ports.prometheus}" ];
            }
          ];
        }
      ];
    };

    services.loki = {
      enable = true;
      configuration = {
        auth_enabled = false;
        server.http_listen_port = cfg.ports.loki;

        common = {
          ring = {
            instance_addr = "127.0.0.1";
            kvstore.store = "inmemory";
          };
          replication_factor = 1;
          path_prefix = "/tmp/loki";
        };

        schema_config.configs = [
          {
            from = "2025-02-05";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index.prefix = "index_";
            index.period = "24h";
          }
        ];

        storage_config.filesystem.directory = "/tmp/loki/chunks";
      };
    };

    services.alloy = {
      enable = true;
      configPath = pkgs.writeText "config.alloy" ''
        loki.relabel "journal" {
          forward_to = []
          rule {
            source_labels = ["__journal__systemd_unit"]
            target_label = "unit"
          }
        }

        loki.source.journal "read"  {
          forward_to = [loki.write.local.receiver]
          relabel_rules = loki.relabel.journal.rules
          labels = { component = "journal" }
        }

        faro.receiver "faro" {
          extra_log_labels = { component = "faro collector" }
          server {
            listen_port = ${toString cfg.ports.faro}
            cors_allowed_origins = ["*"]
          }
          output {
            logs = [loki.process.faro.receiver]
          }
        }

        loki.process "faro" {
            forward_to = [loki.write.local.receiver]
            stage.logfmt {
                mapping = { "kind" = "", "service_name" = "", "app" = "" }
            }
            stage.labels {
                values = { "kind" = "kind", "service_name" = "service_name", "app" = "app" }
            }
        }

        loki.write "local" {
          endpoint {
            url = "http://localhost:${toString cfg.ports.loki}/loki/api/v1/push"
          }
        }
      '';
    };
  };
}
