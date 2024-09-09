{
  config,
  interface ? "wlan0",
}: {
  sops.secrets."networkmanager-profiles-env" = {};

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [
      config.sops.secrets."networkmanager-profiles-env".path
    ];

    profiles."home-wifi" = {
      connection.id = "Home Wifi";
      connection.uuid = "c8437409-9c82-459c-85bf-efa1233aaecb";
      connection.type = "wifi";
      connection.interface-name = interface;
      ipv4.method = "auto";
      ipv6.method = "auto";
      ipv6.addr-gen-mode = "default";
      wifi.mode = "infrastructure";
      wifi.ssid = "$HOME_WIFI_SSID";
      wifi-security.auth-alg = "open";
      wifi-security.key-mgmt = "wpa-psk";
      wifi-security.psk = "$HOME_WIFI_PSK";
    };

    profiles."home-wifi-5g" = {
      connection.id = "Home Wifi 5G";
      connection.uuid = "00ff980e-6c7d-425b-babc-6e4830c949f4";
      connection.type = "wifi";
      connection.interface-name = interface;
      connection.autoconnect = true;
      ipv4.method = "auto";
      ipv6.method = "auto";
      ipv6.addr-gen-mode = "default";
      wifi.mode = "infrastructure";
      wifi.ssid = "$HOME_WIFI_5G_SSID";
      wifi-security.auth-alg = "open";
      wifi-security.key-mgmt = "wpa-psk";
      wifi-security.psk = "$HOME_WIFI_5G_PSK";
    };
  };
}
