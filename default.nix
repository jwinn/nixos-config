# Edit this configuration file to define what should be installed on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    ./hosts/${_module.args.hostname}
  ];
}
