{
  config,
  ...
}: {
  sops.secrets."wireless.env" = {};

  networking.networkmanager.enable = true;

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
