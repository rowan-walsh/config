{config, ...}: {
  sops.secrets."tailscale-client-key" = {};

  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = config.sops.secrets."tailscale-client-key".path;
    authKeyParameters.ephemeral = false;
  };

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/tailscale"
    ];
  };
}
