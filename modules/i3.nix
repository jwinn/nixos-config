{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    feh
    rofi # dmenu replacement
    rxvt_unicode
    vanilla-dmz # generic HiDPI cursor(s)
  ];

  # X11 compositor
  services.picom.enable = true;

  services.xserver = {
    dpi = 192;
    enable = true;
    layout = "us";

    desktopManager = {
      xterm.enable = false;
      wallpaper.mode = "fill";
    };

    displayManager = {
      defaultSession = "none+i3";
      lightdm = {
        background = ../assets/bg/technical-dark.png;
        enable = true;
      };
      sessionCommands = ''
        [ -r "$HOME/.xinitrc" ] && sh $HOME/.xinitrc
      '';
    };

    windowManager = {
      i3.enable = true;
    };
  };
}
