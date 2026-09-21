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

  fonts.packages = with pkgs; [
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
  ];

  home-manager.users.zetlen = ./home-desktop.nix;

  # `nix run .#desktop` opens a window, using the host GPU through virgl.
  virtualisation.vmVariant.virtualisation = {
    graphics = lib.mkForce true;
    qemu.options = [
      "-device virtio-vga-gl"
      "-display gtk,gl=on"
    ];
  };
}
