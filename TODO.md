## Install

-   [X] Basic disko support
-   [X] Remove chezmoi and custom pieces, when home manager is fully supported
-   [ ] Provide config for install and a description for what will happen
-   [X] Prompt for host name (config entry), with auto-detected as default?
-   [ ] Detect OS and install based upon that, i.e. NixOS, macOS, WSL, etc.
-   [X] Remove unused/stale code for jq, get_disk, etc.

### nix-darwin

-   [ ] Integrate into `install.sh` process

### NixOS-WSL

-   [ ] Integrate into `install.sh` process

## Config

-   [ ] Support passed in arguments as module/config options
-   [ ] TBD: switch from composable modules to configurable features (opt-in)?
-   [ ] Support nix-colors
-   [ ] Support impermanence

### Dev Shell

-   [ ] Developer Shell support
-   [ ] `direnv` coupling with a dev shell

### Home Manager (HM)

-   [X] Basic support
-   [ ] Integrate `dotfiles` into HM, where applicable,
        removing `home.file` references
-   [ ] Determine why compiling from source on aarch64, led to an out of
        memory issue on 4GB RAM VM

### nix-darwin

-   [ ] nix-darwin support
-   [ ] Home Manager integration

### NixOS-WSL

-   [ ] NixOS WSL support
-   [ ] Home Manager integration

### Secrets, keys, etc

-   [ ] Support secrets properly, either through sops, or some other mechanism

### Wayland, Hyprland, Sway, etc

-   [ ] Hyprland
-   [ ] Sway
