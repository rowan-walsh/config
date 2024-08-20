{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

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
    hideMounts = true;
    files = [
      "/etc/wpa_supplicant.conf"
    ];
  };
}