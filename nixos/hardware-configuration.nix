# Used only when this config is installed onto a VM disk. `nix run` and
# `nixos-rebuild build-vm` replace the boot loader and file systems with their
# own. The labels match the partitioning steps in the NixOS manual; for any
# other layout, swap this file for the output of `nixos-generate-config`.
{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };
}
