{
  services.kea = {
    dhcp4 = {
      enable = true;
      settings = {
        valid-lifetime = 4000; # seconds
        renew-timer = 1000; # seconds
        rebind-timer = 2000; # seconds
        lease-database = {
          type = "memfile";
          persist = true;
          name = "/var/lib/kea/kea-leases4.csv";
        };
        subnet4 = [
          {
            id = 1;
            subnet = "192.168.1.0/24";
            pools = [{pool = "192.168.1.100 - 192.168.1.240";}];
            reservations = [
              {
                hw-address = "D0:17:C2:95:09:4C";
                ip-address = "192.168.1.10"; # vide
              }
              {
                hw-address = "94:B8:6D:F7:D5:6E";
                ip-address = "192.168.1.11"; # tweeze
              }
              {
                hw-address = "20:79:18:D2:5E:DD";
                ip-address = "192.168.1.20"; # carbonate
              }
              {
                hw-address = "F0:72:EA:F1:A6:34";
                ip-address = "192.168.1.50";
                hostname = "chromed";
              }
              {
                hw-address = "48:E7:29:6F:04:F9";
                ip-address = "192.168.1.51";
                hostname = "prusamini";
              }
            ];
          }
        ];
        option-data = [
          {
            name = "routers";
            data = "192.168.1.1";
          }
          {
            name = "domain-name-servers";
            data = "192.168.1.2";
          }
          {
            name = "domain-name";
            data = "local";
          }
        ];
        loggers = [
          {
            name = "kea-dhcp4";
            severity = "INFO"; # Log level
            output_options = [
              {
                output = "/var/log/kea/kea-dhcp4.log";
                maxver = 10; # Keep 10 rotated log files
              }
            ];
          }
        ];
      };
    };
    dhcp6 = {
      enable = false;
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/private/kea";
      mode = "0700";
      defaultPerms.mode = "0700";
    }
  ];

  # Create the /var/log/kea directory
  systemd.services.kea-dhcp4-server.serviceConfig.LogsDirectory = "kea";
}
