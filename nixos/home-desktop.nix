{ config, lib, pkgs, ... }:
let
  uiFont = "Atkinson Hyperlegible Next";
  swayCfg = config.wayland.windowManager.sway.config;

  # The cheat sheet behind Super+/: every Sway binding, generated from the
  # binding table itself so it cannot go stale. fuzzel shows it; typing
  # filters, Enter runs the chosen command. The columns are padded with
  # spaces, so this one fuzzel stays monospace. The binding names the script by
  # its ~/.config path: a store path there would make the table depend on
  # itself.
  keyColumn = 24;
  sheetLines =
    prefix: bindings:
    lib.mapAttrsToList (
      key: command:
      let
        name = prefix + builtins.replaceStrings [ "Mod4" "Mod1" ] [ "Super" "Alt" ] key;
        pad = lib.strings.replicate (lib.max 1 (keyColumn - builtins.stringLength name)) " ";
      in
      "${name}${pad}${command}"
    ) (lib.filterAttrs (_: command: command != null) bindings);
  cheatSheet = pkgs.writeText "sway-keys.txt" (
    lib.concatLines (
      sheetLines "" swayCfg.keybindings
      ++ lib.concatLists (lib.mapAttrsToList (mode: sheetLines "[${mode}] ") swayCfg.modes)
    )
  );
  swayKeys = pkgs.writeShellScript "sway-keys" ''
    choice=$(fuzzel --dmenu --font monospace:size=11 --prompt 'keys> ' --width 80 --lines 24 < ${cheatSheet}) || exit 0
    swaymsg -- "''${choice:${toString keyColumn}}"
  '';

  powerMenu = pkgs.writeText "waybar-power-menu.xml" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <interface>
      <object class="GtkMenu" id="menu">
        <child>
          <object class="GtkMenuItem" id="logout">
            <property name="label">Log out</property>
          </object>
        </child>
        <child>
          <object class="GtkSeparatorMenuItem" id="delimiter1"/>
        </child>
        <child>
          <object class="GtkMenuItem" id="reboot">
            <property name="label">Reboot</property>
          </object>
        </child>
        <child>
          <object class="GtkMenuItem" id="shutdown">
            <property name="label">Shut down</property>
          </object>
        </child>
      </object>
    </interface>
  '';
in
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
      # Titlebars; Sway's own default is "monospace 8".
      fonts = { names = [ uiFont ]; size = 10.0; };
      input."type:keyboard".xkb_options = "caps:escape";
      # The host's touchpad scrolls in small steps and QEMU makes a whole
      # wheel click of each one, hence the factor.
      input."type:pointer" = {
        natural_scroll = "enabled";
        scroll_factor = "0.25";
      };
      keybindings = lib.mkOptionDefault {
        "${swayCfg.modifier}+slash" = "exec ~/.config/sway/sway-keys";
      };
      bars = [ { command = "waybar"; } ];
      startup = [
        { command = "mako"; }
        { command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; }
      ];
    };
  };

  xdg.configFile."sway/sway-keys".source = swayKeys;

  # fuzzel and mako both default to "monospace". Plain config files rather
  # than programs.fuzzel and services.mako: desktop.nix already installs
  # both, and Sway starts mako itself.
  xdg.configFile."fuzzel/fuzzel.ini".text = ''
    [main]
    font=${uiFont}:size=12
  '';
  xdg.configFile."mako/config".text = ''
    font=${uiFont} 10
  '';

  # GTK apps outside GNOME read this from dconf; the default, Cantarell, is
  # not installed.
  gtk = {
    enable = true;
    font = { name = uiFont; size = 10; };
  };

  # Waybar's stock config has a power button whose menu file
  # (~/.config/waybar/power_menu.xml) ships nowhere, so clicking it kills the
  # bar. This config carries its own menu, and drops the laptop modules
  # (battery, backlight, ...) that mean nothing in a VM. The stock style.css
  # still applies, with the font swapped for one that is installed. Sway
  # starts the bar (bars above), not systemd.
  programs.waybar = {
    enable = true;
    style = ''
      @import url("${pkgs.waybar}/etc/xdg/waybar/style.css");
      * {
        font-family: "${uiFont}", sans-serif;
      }
    '';
    settings.mainBar = {
      height = 30;
      spacing = 4;
      modules-left = [ "sway/workspaces" "sway/mode" "sway/scratchpad" ];
      modules-center = [ "sway/window" ];
      modules-right = [ "network" "cpu" "memory" "clock" "tray" "custom/power" ];
      network = {
        format-ethernet = "{ipaddr}";
        format-disconnected = "offline";
        tooltip-format = "{ifname} via {gwaddr}";
      };
      cpu.format = "cpu {usage}%";
      memory.format = "mem {}%";
      clock = {
        format = "{:%a %b %d  %H:%M}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
      };
      tray.spacing = 10;
      "custom/power" = {
        format = "⏻ ";
        tooltip = false;
        menu = "on-click";
        menu-file = "${powerMenu}";
        # Shut down ends QEMU; Log out and Reboot keep it. No Suspend or
        # Hibernate: a resumed guest finds its virgl GPU state gone and
        # wedges. To pause the VM, suspend the host.
        menu-actions = {
          logout = "swaymsg exit";
          reboot = "systemctl reboot";
          shutdown = "systemctl poweroff";
        };
      };
    };
  };
}
