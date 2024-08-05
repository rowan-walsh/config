{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    vim
    git
    jujutsu
    just

    alejandra # for nix formatting
    sops      # for secrets
    statix    # for nix linting
  ];
}
