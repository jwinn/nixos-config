# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../users/jwinn
  ];

  # Use the systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "vmware-aarch64";
  #time.timeZone = "Etc/UTC";
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  # Nix command
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      # Every week, delete any generation older than 3 days
      options = "--delete-older-than 3d";
    };

    nixPath = if config.nix.channel.enable then config.nix.nixPath // [
      #"nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=/etc/nixos/config/hosts/${config.networking.hostName}/default.nix"
      #"/nix/var/nix/profiles/per-user/root/channels"
    ] else [];
  };

  # SSH server
  services.openssh = {
    enable = true;
    settings = {
      # allow the client to select the address to which the forwarding is bound
      GatewayPorts = "clientspecified";
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      # autmatically remove stale sockets
      StreamLocalBindUnlink = "yes";
    };
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}

