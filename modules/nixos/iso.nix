{pkgs, ...}: {
  imports = [
    ./_packages.nix
  ];

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOqlX4bm2rUlVeonvpv2hxW0ajQg/UCCOUNJlmPSZ0dS"
    ];
  };

  programs.bash.shellAliases = {
    install = "curl -fsSL https://raw.githubusercontent.com/rowan-walsh/config/main/install.sh | sudo sh";
    install-offline = "sudo sh $HOME/install.sh";
  };

  environment.systemPackages = with pkgs; [
    tmux
  ];

  networking = {
    wireless.enable = false;
    networkmanager.enable = true;
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable = true;

  system.stateVersion = "24.05";
}
