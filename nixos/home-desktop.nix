{ pkgs, ... }:
{
  # Sway itself comes from programs.sway in desktop.nix; this only writes
  # ~/.config/sway/config.
  wayland.windowManager.sway = {
    enable = true;
    package = null;
    config = {
      # Super. In a VM window the host desktop grabs Super first unless the
      # window has captured the keyboard; "Mod1" (Alt) avoids that fight.
      modifier = "Mod4";
      terminal = "ghostty";
      menu = "fuzzel";
      bars = [ { command = "waybar"; } ];
      startup = [
        { command = "mako"; }
        { command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; }
      ];
    };
  };
}
