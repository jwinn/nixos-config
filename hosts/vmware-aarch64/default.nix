# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../users/jwinn
  ];

  boot = {
    # Use QEMU to run x86_64 binaries
    binfmt.emulatedSystems = [ "x86_64-linux" ];

    # fsck may fail at startup, so disable
    #initrd.checkJournalingFS = false;

    # Use the systemd-boot EFI boot loader
    loader = {
      systemd-boot = {
        # VMware and Parallels will raise
        # "error switching console mode" on boot,
        # if not set to UEFI 80x25, i.e. 0
        # Note: testing if "auto" esolve as well
        consoleMode = "auto";
        enable = true;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  # System-wide programs
  environment.systemPackages = with pkgs; [
    cachix
    gnumake
    killall
    lynx
    niv
    rxvt_unicode
    vim
    wget
    xclip

    # Script to attempt VM auto-resizing support
    # Taken from: https://github.com/mitchellh/nixos-config
    #(writeShellScriptBin "xrandr-auto" ''
    #  xrandr --output Virtual-1 --auto
    #'')
  #] ++ lib.optionals true [
  #  # TODO: verify if this is required to get clipboard working with open-vm-tools
  #  gtkmm3
  ];
  # System-wide (default) env variables
  environment.variables = {
    BROWSER = "lynx";
    EDITOR = "vim";
    #TERMINAL = "urxvt";
    VISUAL = "vim";
  };

  # System-wide fonts
  fonts = {
    # Allow for linking from $XDG_DATA_HOME/fonts to share/X11/fonts dir
    fontDir.enable = true;

    # Only retrieve some of the nerdfonts
    packages = with pkgs; [
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "JetBrainsMono"
          "OpenDyslexic"
          "SourceCodePro"
        ];
      })
    ];
  };

  i18n.defaultLocale = "en_US.UTF-8";

  networking.hostName = "vmware-aarch64";
  # The global flag is deprecated, so disable here to ensure
  # each interface is configured separately
  networking.useDHCP = false;
  # The interface created for apple silicon NIC
  networking.interfaces.ens160.useDHCP = true;

  # Nix command
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes repl-flake
      keep-outputs = true
      keep-derivations = true
    '';

    gc = {
      automatic = true;
      dates = "weekly";
      # Every week, delete any generation older than 3 days
      options = "--delete-older-than 3d";
    };

    # Whilst not using flakes (yet?), still allow flake access
    package = pkgs.nixUnstable;

    settings = {
      # Cachix public binary cache to use
      substituters = [ "https://jwinn-nixos-config.cachix.org" ];
      trusted-public-keys = [
        "jwinn-nixos-config.cachix.org-1:+lzcoOcvOgUXoriRmJPdjW63cFu6bMYBU4//r7Q9zmc="
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    git.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    mosh.enable = true;
    mtr.enable = true;
    tmux.enable = true;
    vim.defaultEditor = lib.mkDefault true;
  };

  # Don't require passwd for sudo
  security.sudo.wheelNeedsPassword = false;

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

  services.xserver = {
    autorun = lib.mkDefault false;
    dpi = lib.mkDefault 220;
    enable = lib.mkDefault true;
    layout = lib.mkDefault "us";

    desktopManager = {
      xterm.enable = lib.mkDefault false;
      wallpaper.mode = lib.mkDefault "fill";
    };

    displayManager = {
      defaultSession = lib.mkDefault "none+i3";
      lightdm.enable = lib.mkDefault true;

      # VMware Fusion aarch64:
      # slow down key repeat to prevent infinite repeat bug
      # TODO: verify if still needed
      #sessionCommands = ''
      #  ${pkgs.xorg.xset}/bin/xset r rate 200 40
      #'';
    };

    windowManager = {
      i3 = {
        enable = lib.mkDefault true;
        #extraPackages = with pkgs; [
        #  dmenu # application launcher most people use
        #  i3status # gives you the default i3 status bar
        #  #i3lock # default i3 screen locker
        #  #i3blocks # if you are planning on using i3blocks over i3status
        #];
      };
    };
  };

  #time.timeZone = "Etc/UTC";
  time.timeZone = "America/Los_Angeles";

  # Only allow users to be created through configuration
  users.mutableUsers = false;

  # Enable docker
  virtualisation.docker.enable = true;

  # VMware guest tools
  virtualisation.vmware.guest = {
    enable = true;
    # https://github.com/NixOS/nixpkgs/issues/258983#issuecomment-1747620207
    headless = true;
  };

  # provide ZRAM as swap
  zramSwap.enable = true;
  
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

