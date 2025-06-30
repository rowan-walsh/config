{
  services.prometheus = {
    enable = true;
    port = 9001;
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
