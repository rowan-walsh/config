{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      jujutsu
      just
      alejandra # for nix formatting
      sops # for secrets
      statix # for nix linting
      ventoy # for flashing ISOs
    ];
  };
}
