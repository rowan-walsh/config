{
  home = {
    username = "nixos";
    homeDirectory = "/home/nixos";
    stateVersion = "24.05";
    file."install.sh" = {
      source = ./../../install.sh;
      executable = true;
    };
  };
}
