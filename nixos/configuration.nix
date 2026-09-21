{ lib, pkgs, dotfiles, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nixvm";

  # Login prompt and kernel messages on the serial port too, so the image
  # works under `qemu-system-x86_64 -nographic`. The last console= is where
  # boot messages go.
  boot.kernelParams = [ "console=tty0" "console=ttyS0,115200n8" ];
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@wheel" ];
  };
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    lib.elem (lib.getName pkg) [
      "claude-code"
      # desktop.nix
      "bluebubbles"
      "objectbox-linux" # a bluebubbles dependency
      "discord"
      "discord-unwrapped"
      "google-chrome"
      "slack"
    ];

  users.users.zetlen = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "docker" ];
    # Change it with `passwd` after first boot; nothing here reapplies it.
    initialPassword = "zetlen";
    openssh.authorizedKeys.keyFiles = [ (dotfiles + "/lib/bootstrap/id_ed25519_z.pub") ];
  };
  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # ~/.zshrc owns completion and the prompt. Left on, NixOS's /etc/zshrc runs
  # its own compinit against a smaller fpath first -- the same double-compinit
  # that skip_global_compinit in .zshenv exists to stop on Ubuntu -- and sets a
  # prompt theme that starship then has to replace.
  programs.zsh = {
    enable = true;
    enableCompletion = false;
    enableGlobalCompInit = false;
    promptInit = "";
  };

  # .zshrc points SSH_AUTH_SOCK at gpg-agent's ssh socket.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  # mise, rustup, uv and `npx -y` all download generic-linux binaries, which
  # expect a dynamic loader at /lib64/ld-linux*. nix-ld puts one there.
  programs.nix-ld.enable = true;

  # lib/common/25-helpers-docker.sh
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    curl
    git
    pciutils # lspci
    usbutils # lsusb
    vim
    wget
  ];

  virtualisation.vmVariant.virtualisation = {
    memorySize = 8192;
    cores = 4;
    diskSize = 32768;
    graphics = false;
    forwardPorts = [
      { from = "host"; host.port = 2222; guest.port = 22; }
    ];
  };

  # The qcow2 is sparse, so this sets the ceiling, not the file size.
  image.modules.qemu-efi.virtualisation.diskSize = 32768;

  system.stateVersion = "26.05";
}
