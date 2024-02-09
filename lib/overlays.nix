let
  path = ../overlays;
  fnMap = n: import (path + ("/" + n));
  fnFilter = n: builtins.match ".*\\.nix" n != null ||
    builtins.pathExists path + ("/" + n + "/default.nix");
  inodes = builtins.attrNames (builtins.readDir path);
in

builtins.map fnMap (builtins.filter fnFilter inodes)
