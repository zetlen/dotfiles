{
  description = "NixOS VM carrying zetlen's dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, home-manager, ... }:
    let
      # The whole repo, not just this directory: the shell rc files source
      # $DOTFILE_PATH/lib/... at runtime, so ~/.dotfiles has to be the real
      # tree. Only git-tracked files make it into a flake source, so new files
      # need a `git add` before a rebuild can see them.
      dotfiles = ../.;

      mkHost =
        system:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit dotfiles; };
          modules = [
            { nixpkgs.hostPlatform = system; }
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit dotfiles; };
                users.zetlen = ./home.nix;
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        nixvm = mkHost "x86_64-linux";
        nixvm-aarch64 = mkHost "aarch64-linux";
      };

      # `nix run ./nixos` boots the config in QEMU with a throwaway disk image
      # (nixvm.qcow2 in the current directory).
      packages.x86_64-linux.default = self.nixosConfigurations.nixvm.config.system.build.vm;
      packages.aarch64-linux.default = self.nixosConfigurations.nixvm-aarch64.config.system.build.vm;

      # A bootable UEFI qcow2 for hosts without Nix: any QEMU with OVMF
      # firmware, virt-manager, or Proxmox can run it.
      packages.x86_64-linux.image = self.nixosConfigurations.nixvm.config.system.build.images.qemu-efi;
      packages.aarch64-linux.image = self.nixosConfigurations.nixvm-aarch64.config.system.build.images.qemu-efi;
    };
}
