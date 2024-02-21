{ pkgs }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isWSL = pkgs.stdenv.hostPlatform.isWindows;
in
# generally specific packages, should be in a project's folder,
# using direnv and shell.nix to configure
with pkgs; [
  bat
  fzf
  gcc # used by treesitter
  htop
  jq
  kitty
  mosh
  neofetch
  nodejs # used by copilot.vim
  ranger
  ripgrep
  unzip # used by mason
] ++ lib.optionals (isDarwin) [
  # is setup on linux through systemPackages, but not nixos-darwin
  cachix
] ++ lib.optionals (isLinux && !isWSL) [
  chromium
  firefox
  rofi
  wezterm
]
