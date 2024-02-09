{ config, pkgs, ... }:

{
  environment.variables = rec {
    BROWSER = "lynx";
    EDITOR = "vim";
    #TERMINAL = "urxvt";
    VISUAL = "${EDITOR}";
  };
}
