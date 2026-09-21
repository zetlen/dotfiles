# The host's half of the desktop VM, for a host that is not NixOS: a launcher
# for the `desktop-image` qcow2 and a login session that shows nothing else.
#
#   nix build ~/.dotfiles/nixos#desktop-host --out-link ~/vms/nixvm/host
#
# QEMU, OVMF, sudo, ip, nmcli and iptables are the host's own, found on PATH.
# QEMU in particular has to be: virgl needs the host's GL drivers, which a
# QEMU from nixpkgs cannot load on another distribution.
#
# The VM's LAN address and MAC are read out of the guest's configuration
# (desktop.nix), so the two halves cannot drift apart.
{
  pkgs,
  lib,
  guest,
  # NetworkManager connection that means "at home": only there does the host
  # claim the VM's LAN address.
  homeConnection,
  ovmfDir ? "/usr/share/OVMF",
}:
let
  lan = guest.systemd.network.networks."10-lan";
  vmMac = lan.matchConfig.MACAddress;
  vmIp = lib.head (lib.splitString "/" (lib.head lan.address));

  launcher = pkgs.writeShellScriptBin "nixvm-desktop" ''
    # State lives outside the store: the overlay (nixvm-desktop.qcow2) and the
    # UEFI variables (vars-desktop.fd).
    cd "''${NIXVM_DIR:-$HOME/vms/nixvm}" || exit 1

    # At home the VM is a LAN host of its own at $vm_ip. The host is on Wi-Fi,
    # where a bridge cannot work (the access point only takes frames from the
    # host's MAC), so the host answers ARP for $vm_ip and routes it to a tap
    # device. The VM always has a user-mode NAT NIC as well (sshd on
    # localhost:2223): it is the only NIC away from home, and at home it is
    # the way back in if the LAN setup breaks. The VM prefers the LAN route
    # when it has both.
    home_conn=${lib.escapeShellArg homeConnection}
    vm_ip=${vmIp}
    vm_mac=${vmMac}
    tap=tap-nixvm

    at_home() {
      nmcli -t -f NAME connection show --active | grep -qxF "$home_conn" &&
        lan_if=$(nmcli -g GENERAL.DEVICES connection show "$home_conn") &&
        [ -n "$lan_if" ]
    }

    # Docker sets the FORWARD policy to DROP; DOCKER-USER is where exceptions
    # go.
    fwd_chain() {
      if sudo -n iptables -nL DOCKER-USER >/dev/null 2>&1; then
        echo DOCKER-USER
      else
        echo FORWARD
      fi
    }

    net_up() {
      chain=$(fwd_chain)
      sudo -n ip tuntap add dev "$tap" mode tap user "$(id -un)" &&
        sudo -n ip link set "$tap" up &&
        sudo -n sysctl -qw net.ipv4.ip_forward=1 "net.ipv4.conf.$tap.proxy_arp=1" &&
        sudo -n ip route add "$vm_ip/32" dev "$tap" &&
        sudo -n ip neigh add proxy "$vm_ip" dev "$lan_if" &&
        sudo -n iptables -I "$chain" -i "$tap" -j ACCEPT &&
        sudo -n iptables -I "$chain" -o "$tap" -j ACCEPT
    }

    net_down() {
      chain=$(fwd_chain)
      sudo -n iptables -D "$chain" -o "$tap" -j ACCEPT 2>/dev/null
      sudo -n iptables -D "$chain" -i "$tap" -j ACCEPT 2>/dev/null
      [ -z "$lan_if" ] || sudo -n ip neigh del proxy "$vm_ip" dev "$lan_if" 2>/dev/null
      sudo -n ip link del "$tap" 2>/dev/null # takes its route along
    }

    lan_if=
    lan=()
    if at_home; then
      net_down # leftovers from a run that was killed
      if net_up; then
        trap net_down EXIT
        trap 'exit 130' INT TERM
        lan=(-netdev "tap,id=lan,ifname=$tap,script=no,downscript=no"
          -device "virtio-net-pci,netdev=lan,mac=$vm_mac")
      else
        net_down
      fi
    fi

    # bootindex makes the firmware boot the root disk and nothing else.
    # Without it OVMF works through network boot on every NIC first, and any
    # change to the device list strands the disk's boot entry behind the EFI
    # shell.
    #
    # The usb-host devices: the host's Bluetooth controller (Intel AX201), so
    # the host has no Bluetooth while the VM runs; and any YubiKey and the
    # Samsung FIT thumb drive, which the VM takes as soon as they are plugged
    # in, whichever port. /etc/udev/rules.d/70-nixvm-usb.rules on the host
    # lets group kvm claim them.
    qemu-system-x86_64 -enable-kvm -machine q35 -cpu host -smp 4 -m 8G \
      -drive if=pflash,format=raw,readonly=on,file=${ovmfDir}/OVMF_CODE_4M.fd \
      -drive if=pflash,format=raw,file=vars-desktop.fd \
      -drive if=none,id=root,format=qcow2,file=nixvm-desktop.qcow2 \
      -device virtio-blk-pci,drive=root,bootindex=0 \
      -nic user,model=virtio-net-pci,hostfwd=tcp:127.0.0.1:2223-:22 \
      "''${lan[@]}" \
      -device virtio-vga-gl -display gtk,gl=on,show-menubar=off \
      -device qemu-xhci -device usb-tablet \
      -device usb-host,vendorid=0x8087,productid=0x0026 \
      -device usb-host,vendorid=0x1050 \
      -device usb-host,vendorid=0x090c,productid=0x1000
  '';

  # A Sway that is only a frame for the VM: no bar, no workspaces to speak of
  # and no bindings, so every key, Super and Alt included, reaches the guest
  # without QEMU having to grab anything. When QEMU exits, so does the
  # session.
  kioskConfig = pkgs.writeText "nixvm-kiosk-sway.conf" ''
    xwayland disable
    default_border none
    for_window [app_id=".*"] fullscreen enable
    input type:touchpad tap enabled

    # The one binding: a way out if QEMU stops responding.
    bindsym Ctrl+Alt+Shift+BackSpace exit

    exec '${lib.getExe launcher}; swaymsg exit'
  '';

  session = pkgs.writeShellScriptBin "nixvm-session" ''
    exec sway -c ${kioskConfig}
  '';
in
pkgs.symlinkJoin {
  name = "nixvm-desktop-host";
  paths = [
    launcher
    session
  ];
}
