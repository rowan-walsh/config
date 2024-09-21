{}: {
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
            pools = [
              {
                pool = "192.168.1.100 - 192.168.1.199";
              }
            ];
            reservations = [
              {
                hw-address = "D0:17:C2:95:09:4C";
                ip-address = "192.168.1.3";
              }
              {
                hw-address = "F0:72:EA:F1:A6:34";
                ip-address = "192.168.1.20";
                hostname = "chromed";
              }
              {
                hw-address = "48:E7:29:6F:04:F9";
                ip-address = "192.168.1.22";
                hostname = "prusamini";
              }
            ];
            option-data = [
              {
                name = "domain-name";
                data = "lan";
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
            data = "192.168.1.254";
          }
        ];
      };
    };
    dhcp6 = {
      enable = false;
    };
  };

  environment.persistence."/persist" = {
    directories = ["/var/lib/kea"];
  };
}
