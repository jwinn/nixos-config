{ config, lib, ... }:

{
  imports = [
    ./hardware.nix

    ../../modules/base.nix
    ../../modules/fonts.nix
    ../../modules/i3.nix
    ../../modules/overlays.nix
    ../../modules/packages.nix
    ../../modules/systemd.nix
    ../../modules/vm.nix

    ../../users/jwinn
  ];

  networking.hostName = "qemu-aarch64";
  networking.interfaces.enp0s1.useDHCP = lib.mkDefault true;

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
}
