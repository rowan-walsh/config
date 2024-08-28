{config, ...}: {
  sops.secrets."wifi_1.nmconnection.ini" = {
    sopsFile = ./../../secrets/wifi_1.nmconnection.ini;
    format = "ini";
    path = "/etc/NetworkManager/system-connections/wifi_1.nmconnection";
    mode = "0600";
    reloadUnits = ["network-manager.service"];
  };

  sops.secrets."wifi_2.nmconnection.ini" = {
    sopsFile = ./../../secrets/wifi_2.nmconnection.ini;
    format = "ini";
    path = "/etc/NetworkManager/system-connections/wifi_2.nmconnection";
    mode = "0600";
    reloadUnits = ["network-manager.service"];
  };
}
