{ config, ... }:

{
  # Use the systemd-boot EFI boot loader
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };
}
