{
  services.nginx = {
    enable = true;
    #recommendedTlsSettings = true;
    #recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
