{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    xorg.xauth
  ];

  # Prevent X11 from starting by default
  services.xserver = {
    autorun = lib.mkDefault false;
    displayManager.startx.enable = lib.mkDefault true;
  };
}
