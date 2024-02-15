{ config, ... }:

{
  # Use the systemd-boot EFI boot loader
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };
  boot.initrd.systemd.additionalUpstreamUnits = [ "systemd-vconsole-setup.service" ];
  boot.initrd.systemd.storePaths = [ config.console.font ];
}
