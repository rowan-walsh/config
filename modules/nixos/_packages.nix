{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    efibootmgr
    jq
    git
    gptfdisk
    parted
    ssh-to-age
    ventoy
    vim
    zfs
  ];
}
