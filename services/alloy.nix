{
  services.alloy = {
    enable = true;
    extraFlags = ["--disable-reporting"];
  };

  # alloy configured though /etc/alloy/*.alloy files
  # TODO: don't hardcode tweeze hostname
  environment.etc."alloy/base.alloy".text = ''
    loki.write "default" {
      endpoint {
        url = "http://tweeze:3100/loki/api/v1/push"
      }
    }
  '';
  environment.etc."alloy/journal.alloy".text = ''
    loki.relabel "journal" {
      forward_to = []

      rule {
        source_labels = ["__journal__hostname"]
        target_label = "host"
      }
      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "systemd_unit"
      }
      rule {
        source_labels = ["__journal__systemd_user_unit"]
        target_label  = "systemd_user_unit"
      }
      rule {
        source_labels = ["__journal__transport"]
        target_label = "transport"
      }
      rule {
        source_labels = ["__journal_priority_keyword"]
        target_label = "level"
      }
    }

    loki.source.journal "read" {
      forward_to    = [loki.write.default.receiver]
      relabel_rules = loki.relabel.journal.rules
      labels        = {component = "loki.source.journal"}
    }
  '';
}
