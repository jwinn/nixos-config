{ config, lib, pkgs, ... }:

let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isAarch64 = pkgs.stdenv.hostPlatform.isAarch64;
in
{
  # Use QEMU to emulate, and run, x86_64 binaries.
  boot.binfmt.emulatedSystems = lib.mkIf (isLinux && isAarch64) [
    "x86_64-linux"
  ];

  console.keyMap = lib.mkDefault "us";

  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = lib.mkDefault "en_US.UTF-8";
      LC_IDENTIFICATION = lib.mkDefault "en_US.UTF-8";
      LC_MEASUREMENT = lib.mkDefault "en_US.UTF-8";
      LC_MESSAGES = lib.mkDefault "en_US.UTF-8";
      LC_MONETARY = lib.mkDefault "en_US.UTF-8";
      LC_NAME = lib.mkDefault "en_US.UTF-8";
      LC_NUMERIC = lib.mkDefault "en_US.UTF-8";
      LC_PAPER = lib.mkDefault "en_US.UTF-8";
      LC_TELEPHONE = lib.mkDefault "en_US.UTF-8";
      LC_TIME = lib.mkDefault "en_US.UTF-8";
    };
  };

  # Nix command
  nix = {
    gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      # Every week, delete any generation older than 3 days
      options = lib.mkDefault "--delete-older-than 3d";
    };

    # Whilst not using flakes (yet?), still allow flake access
    package = pkgs.nixUnstable;

    settings = {
      experimental-features = "nix-command flakes repl-flake";
      keep-derivations = true; # default, but just in case it changes
      keep-outputs = true;
      show-trace = true;
      # Cachix public binary cache to use
      substituters = [ "https://jwinn-nixos-config.cachix.org" ];
      trusted-public-keys = [
        "jwinn-nixos-config.cachix.org-1:+lzcoOcvOgUXoriRmJPdjW63cFu6bMYBU4//r7Q9zmc="
      ];
    };
  };

  nixpkgs.config.allowUnfree = lib.mkDefault true;

  # SSH server
  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      # allow the client to select the address to which the forwarding is bound
      GatewayPorts = lib.mkDefault "clientspecified";
      PasswordAuthentication = lib.mkDefault false;
      PermitRootLogin = lib.mkDefault "no";
      # autmatically remove stale sockets
      StreamLocalBindUnlink = lib.mkDefault "yes";
    };
  };

  time.timeZone = lib.mkDefault "Etc/UTC";
  #time.timeZone = lib.mkDefault "America/Los_Angeles";

  # Only allow users to be created through configuration
  users.mutableUsers = lib.mkDefault false;

  # Enable docker
  virtualisation.docker.enable = lib.mkDefault true;

  # provide ZRAM as swap
  zramSwap.enable = lib.mkDefault true;
  
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
