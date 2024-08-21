{config, ...}: {
  sops.secrets."wireless.env" = {};

  networking.networkmanager.unmanaged = [
    "*"
    "except:type:wwan"
    "except:type:gsm"
  ];

  networking.wireless = {
    enable = true;
    environmentFile = config.sops.secrets."wireless.env".path;
    networks = {
      "@home_uuid@" = {
        psk = "@home_psk@";
      };
    };
  };

  environment.persistence."/persist" = {
    files = [
      "/etc/wpa_supplicant.conf"
    ];
  };
}
