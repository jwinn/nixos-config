{ config, lib, pkgs, ... }:

let
  isAarch64 = pkgs.stdenv.hostPlatform.isAarch64;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
  # fsck may fail at startup, so disable
  #boot.initrd.checkJournalingFS = false;

  # reduce swappiness to 10 from default of 60
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
  };

  environment.systemPackages = with pkgs; [
    # Script to attempt VM auto-resizing support
    # Taken from: https://github.com/mitchellh/nixos-config
    (writeShellScriptBin "xrandr-auto" ''
      xrandr --output Virtual-1 --auto
    '')
  ];

  # The global flag is deprecated, so disable here to ensure
  # each interface is configured separately
  networking.useDHCP = lib.mkDefault false;

  # Don't require passwd for sudo
  security.sudo.wheelNeedsPassword = lib.mkDefault false;
}
