{ config, lib, pkgs, ... }:

{
  # System-wide fonts
  fonts = {
    # Allow for linking from $XDG_DATA_HOME/fonts to share/X11/fonts dir
    fontDir.enable = lib.mkDefault true;

    # Only retrieve some of the nerdfonts
    packages = with pkgs; [
      (nerdfonts.override {
        fonts = [
          # TODO: 0xProto is not found?
          #"0xProto"
          "ComicShannsMono"
          "DejaVuSansMono"
          "FiraCode"
          "JetBrainsMono"
          "Hack"
          "IntelOneMono"
          "OpenDyslexic"
          "SourceCodePro"
        ];
      })
    ];
  };
}
