# nixos-config

My [NixOS] configuration.

This project documents my journey through learning Nix(OS),
and largely using NixOS as my sole development environment,
via a VM, running aarch64 NixOS, on a macOS laptop (MacBook Pro).

## Configuration

**TBD**

## Install

> Expects to be run on a NixOS [Minimal ISO Image].

Use either the [Online Install](#online-install) **or** [Local Install](#local-install) instructions.

### Installation Process

1.  Partitions the disk, then formats and mounts the partitions.
    Uses a similar process to the one outlined in [NixOS Manual Installation].
1.  Uses, or retrieves, from GitHub, this [Custom Configuration].
1.  Generates a basic configuration, which seems to be required for `nixos-install`.
1.  Installs, via `nixos-install`, from this [Custom Configuration]. 
1.  Using the newly created `/etc/passwd` does the following:

    1.  Prompts for user to own `/mnt/etc/nixos/config` directory.
    1.  Asks if users' [chezmoi] dotfiles should be retrieved from [GitHub].

        > This is a Work in Progress and currently pretty rudimentary.

        -  If yes, then loops though each user, asking to retrieve dotfiles for that user.
            -  If yes, then retrieves the dotfiles to `/home/<user>/dotfiles`
                from GitHub using the following URL:
                `https://github.com/<user>/dotfiles.git`.
            -   Asks if chezmoi install should be run at user's first login
                -   If yes, then creates a script file and adds it to all login files for the user,
                    i.e. `/home/<user>/.{bash_profile,login,profile,zprofile}`, to run [chezmoi install] file from `dotfiles` directory, i.e.

                    ```sh
                    sh "${HOME}/init-chezmoi.sh" && exec ${SHELL}
                    ```

                -   The script file `init-chezmoi.sh` does the following:
                    -   Run `${HOME}/dotfiles/install.sh`.
                    -   Removes the calls to `init-chezmoi.sh` from the login files,     i.e. `/home/<user>/.{bash_profile,login,profile,zprofile}`.
                    -   Removes itself, i.e. `${HOME}/init-chezmoi.sh`.

1.  Asks if the system should reboot.

### Online Install

1.  On the live Minimal ISO Image, run the following command:

    ```sh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/jwinn/nixos-config/main/install.sh)"
    ```

### Local Install

1.  On the live Minimal ISO Image, run the following to get the IP address:

    ```sh
    ip route get 1.1.1.1 | grep -oP 'src \K[^ ]+'
    ```

1.  On the live Minimal ISO Image, update the default nixos user to have a password.

    ```sh
    passwd
    ```

1.  Copy the [Custom Configuration] to the above IP, usually done through `scp`, e.g.

    ```sh
    scp -r nixos-config nixos@<ip_address>:~/
    ```

1.  On the live Minimal ISO Image, run the install script.
    ```sh
    cd nixos-config && sh install.sh cd -
    ```

[chezmoi]: https://www.chezmoi.io
[chezmoi install]: https://www.chezmoi.io/reference/commands/generate/
[Custom Configuration]: https://github.com/jwinn/nixos-config
[GitHub]: https://github.com
[Minimal ISO Image]: https://nixos.org/download
[NixOS]: https://nixos.org/
[NixOS Manual Installation]: https://nixos.org/manual/nixos/stable/index.html#sec-installation-manual
