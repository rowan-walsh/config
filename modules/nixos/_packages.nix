{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    efibootmgr
    git
    gptfdisk
    parted
    ssh-to-age
    ventoy
    vim
  ];
}
