{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../vm-shared.nix
    ../../users/jwinn
  ];

  networking.hostName = "qemu-aarch64";
  networking.interfaces.enp0s1.useDHCP = true;
}
