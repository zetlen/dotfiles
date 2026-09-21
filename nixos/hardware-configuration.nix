# The disk layout of the `image` flake output (nixpkgs' qemu-efi image): an
# ext4 root labelled "nixos" and an ESP labelled "ESP". Keeping this file in
# step with the image is what lets `nixos-rebuild switch` inside the VM boot
# the same disk. `nix run` replaces all of it with its own. For any other
# layout, swap this file for the output of `nixos-generate-config`.
{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Grow into the disk when the qcow2 is resized with `qemu-img resize`.
  boot.growPartition = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    autoResize = true;
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };
}
