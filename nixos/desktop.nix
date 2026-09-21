# Sway on top of the headless config, for the `nixvm-desktop` host. Portals,
# the Sway login session and XWayland come from programs.sway; this adds the
# pieces GNOME and KDE apps (native or Flatpak) expect from their own
# desktops, plus Chrome and Flathub.
{ config, lib, pkgs, ... }:
{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # Choose the session at login. Every package in sessionPackages shows up
  # here, so adding a full desktop later (say services.desktopManager.plasma6)
  # makes it a second choice beside Sway.
  services.greetd = {
    enable = true;
    settings.default_session.command = lib.concatStringsSep " " [
      (lib.getExe pkgs.tuigreet)
      "--time"
      "--remember"
      "--remember-session"
      "--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
    ];
  };

  # A virtio GPU has no hardware cursor plane; without this the cursor is
  # invisible under wlroots.
  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

  services.flatpak.enable = true;
  systemd.services.flathub-remote = {
    description = "Add the Flathub remote for Flatpak";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig.Type = "oneshot";
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # What GNOME and KDE apps assume their desktop provides: a settings store,
  # a secrets store (Chrome keeps passwords there too), virtual filesystems
  # for trash and network locations, and one Qt/GTK look.
  programs.dconf.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  # Caps Lock is Escape: here for the console and the greeter, and in
  # home-desktop.nix for Sway, which does not read the system setting.
  services.xserver.xkb.options = "caps:escape";
  console.useXkbConfig = true;

  # Fonts have to be listed here to reach fontconfig; systemPackages does
  # not. skel/.config/ghostty/config asks for "Iosevka Term Slab", which is
  # the family name of this build and not of the Nerd Font one
  # ("IosevkaTermSlab Nerd Font"). Ghostty draws Nerd Font symbols itself.
  fonts.packages = with pkgs; [
    (iosevka-bin.override { variant = "SGr-IosevkaTermSlab"; })
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono # starship and eza icons
  ];

  environment.systemPackages = with pkgs; [
    fuzzel
    ghostty
    google-chrome
    kdePackages.qtwayland
    mako
    nautilus
    polkit_gnome
    waybar
    wl-clipboard
    xdg-utils

    # Apps
    bluebubbles
    discord
    signal-desktop
    slack
    thunderbird
    vlc
  ];

  home-manager.users.zetlen = ./home-desktop.nix;

  # On its home network the host gives the VM a NIC with this MAC and routes
  # 192.168.1.250 to it (proxy ARP; see desktop-host.nix), making
  # the VM a LAN host of its own. Every other NIC -- the user-mode NAT one
  # the host always attaches, `nix run` -- gets DHCP from networkd's default,
  # whose routes have a higher metric, so the LAN wins when both are there.
  networking.useNetworkd = true;
  systemd.network.networks."10-lan" = {
    matchConfig.MACAddress = "52:54:00:6e:78:01";
    address = [ "192.168.1.250/24" ];
    gateway = [ "192.168.1.1" ];
    dns = [ "192.168.1.1" ];
    # What the router's DHCP hands everyone else on this LAN.
    domains = [ "in.the-z-machine.com" ];
  };
  systemd.network.wait-online.anyInterface = true;

  # The host hands its Bluetooth controller to the VM as a USB device. The
  # controller is an Intel part that wants its firmware from linux-firmware.
  hardware.bluetooth.enable = true;
  hardware.enableRedistributableFirmware = true;
  services.blueman.enable = true;

  # The host also passes any YubiKey through. SSH here goes through gpg-agent
  # (see .zshrc), so what matters is the key's OpenPGP applet: this lets
  # gpg's scdaemon open the CCID interface without root or pcscd. FIDO needs
  # nothing; systemd's own rules cover it.
  hardware.gpgSmartcards.enable = true;

  # `nix run .#desktop` opens a window, using the host GPU through virgl.
  virtualisation.vmVariant.virtualisation = {
    graphics = lib.mkForce true;
    qemu.options = [
      "-device virtio-vga-gl"
      "-display gtk,gl=on"
    ];
  };
}
