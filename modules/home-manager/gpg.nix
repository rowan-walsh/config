{
  config,
  pkgs,
  ...
}: {
  services.gpg-agent = {
    enable = true;
    enableBashIntegration = true;
    defaultCacheTtl = 600; # 10 minutes
    maxCacheTtl = 7200; # 2 hours
    pinentry.package = pkgs.pinentry-gnome3;
  };

  home.packages = with pkgs; [
    pinentry-gnome3
  ];

  programs = {
    gpg = {
      enable = true;
      settings = {
        default-key = "7C222EAA5A246E8F";
        trust-model = "tofu+pgp";
      };
    };

    git.signing = {
      signByDefault = true;
      key = config.programs.gpg.settings.default-key;
    };

    jujutsu.settings.signing = {
      behavior = "own";
      backend = "gpg";
      key = config.programs.gpg.settings.default-key;
    };
  };
}
