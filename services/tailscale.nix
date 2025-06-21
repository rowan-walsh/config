{config, ...}: {
  sops.secrets."tailscale-client-key" = {};

  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = config.sops.secrets."tailscale-client-key".path;
    authKeyParameters.ephemeral = false;
    extraUpFlags = [
      "--advertise-tags=tag:homelab"
    ];
  };

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/tailscale"
    ];
  };
}
