# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix

    ../../overrides/vmware-guest.nix

    ../../modules/base.nix
    ../../modules/fonts.nix
    ../../modules/i3.nix
    ../../modules/opengl.nix
    ../../modules/overlays.nix
    ../../modules/packages.nix
    ../../modules/startx.nix
    ../../modules/systemd.nix
    ../../modules/vm.nix

    ../../users/jwinn
  ];

  # VMware and Parallels will raise
  # "error switching console mode" on boot,
  # if not set to UEFI 80x25, i.e. 0
  # Note: testing if "auto" resolves as well
  #boot.loader.systemd-boot.consoleMode = "0";
  boot.loader.systemd-boot.consoleMode = "auto";

  # Disable the default VMware guest module. Import the override to get this
  # working on aarch64
  disabledModules = [ "virtualisation/vmware-guest.nix" ];

  networking.hostName = "vmware-aarch64";
  # The interface created for apple silicon NIC
  networking.interfaces.ens160.useDHCP = true;

  services.xserver = {
    displayManager = {
      # VMware Fusion aarch64:
      # slow down key repeat to prevent infinite repeat bug
      # TODO: verify if still needed
      #sessionCommands = ''
      #  ${pkgs.xorg.xset}/bin/xset r rate 200 40
      #'';
    };
  };

  # VMware guest tools
  virtualisation.vmware.guest = {
    enable = true;
    # https://github.com/NixOS/nixpkgs/issues/258983#issuecomment-1747620207
    # corrected by using custom, for now, module
    #headless = true;
  };
}
