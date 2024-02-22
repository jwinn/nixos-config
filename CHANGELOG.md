# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

## [0.2.0] - 2024-02-21

### Added

-   Home Manager (HM) module-based NixOS configuration.
-   `modules/home-manager.nix` which fetches the HM tarball and imports it.
-   `users/jwinn/dotfiles` of prior `chezmoi` files,
    not (yet) in the nix config.
-   HM-specific configuration in `users/jwinn`.
-   `default.nix.t` "template" file to change the machine name at install time.
-   auto-detection/selection of available machines in `install.sh`.

### Changed

-   Updated `TODO.md` with current task completion.

### Removed

-   Unused/deprecated functionality from `install.sh`.
-   Somewhat excessive prompting in `install.sh`.

## [0.1.0] - 2024-02-18

### Added

-   `disko-config.nix` for each host.
-   `overlays` and `overrides` (for VM guest tools) directories.
-   `.editorconfig`, `.envrc`, `.gitattributes`, `REFERENCE.md`, `TODO.md`.
-   `assets` folder with single bg image.
-   `default.nix` which needs updated to import the specified host.
-   `hardware.nix` for parallels VM.

### Changed

-   Started to break config into more composable files.
    -   added more user packages and config.
-   Updated `README.md` to reference the new files.
-   `install.sh`
    -   added basic `disko` support .
    -   order of operations for when the symlink is made.
    -   updated `scmd` command to use `sudo`.

### Removed

-   `install.sh`
    -   non-declarative partition and disk mounting and creation.
    -   custom `scmd` that wrapped `sudo`.
    -   no longer referenced disk-based functionality.

### Fixed

-   `install.sh` remote install

## [0.0.2] - 2024-01-09

### Fixed

-   Fixed `CHANGELOG.md` URL for each version to point to this repo.

## [0.0.1] - 2024-01-09

### Added

-   Initial `README.md` with basic installation instructions.
-   Basic [NixOS] custom configuration with a single user and host (VM).
-   Installation script to run, process outlined in `README.md`.

[unreleased]: https://github.com/jwinn/nixos-config/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/jwinn/nixos-config/releases/tag/v0.2.0
[0.1.0]: https://github.com/jwinn/nixos-config/releases/tag/v0.1.0
[0.0.2]: https://github.com/jwinn/nixos-config/releases/tag/v0.0.2
[0.0.1]: https://github.com/jwinn/nixos-config/releases/tag/v0.0.1

[Keep a Changelog]: https://keepachangelog.com/en/1.0.0/
[NixOS]: https://nixos.org
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html
