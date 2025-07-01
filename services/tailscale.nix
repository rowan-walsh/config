{config, ...}: {
  sops.secrets."tailscale-client-key" = {};

  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = config.sops.secrets."tailscale-client-key".path;
    authKeyParameters.ephemeral = false;
    extraSetFlags = [
      "--webclient" # Metrics available at http://<tailscale-ip>:5252/metrics
    ];
    extraUpFlags = [
      "--advertise-tags=tag:homelab"
    ];
  };

  networking.firewall.allowedTCPPorts = [5252];

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/tailscale"
    ];
  };
}
