{
  config,
  inputs,
  outputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.nixos-wsl.nixosModules.default

    ./hardware-configuration.nix

    ./../../modules/nixos/base_wsl.nix
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      "rww" = {
        imports = [
          ./../../modules/home-manager/base.nix
        ];
      };
    };
  };

  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  nix.settings.extra-platforms = config.boot.binfmt.emulatedSystems;

  networking.hostName = "nuv6660-wsl";
}
