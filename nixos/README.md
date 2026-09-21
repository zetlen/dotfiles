# NixOS VM

A NixOS VM carrying these dotfiles. `flake.nix` lists the outputs; this file
covers the one setup that needs more than `nix run`: the **desktop VM as a
login session** on a machine that is not NixOS. You pick "NixOS VM" at the
login screen, get the VM full screen with every key going to it, and shutting
the VM down logs you out. Dual boot without the reboot.

It was built on joe (System76 Lemur Pro, Pop!\_OS 24.04, Wi-Fi only). Things
specific to joe are marked.

## What lives where

In this repo:

| File | Role |
| --- | --- |
| `desktop.nix`, `home-desktop.nix` | The guest: Sway, greeter, fonts, LAN address, Bluetooth, smartcard |
| `desktop-host.nix` | The host: QEMU launcher and the kiosk session, output `desktop-host` |

On the host, outside the repo, all recreated by the steps below:

| Path | Role |
| --- | --- |
| `~/vms/nixvm/base-desktop` | Link to the built image. A GC root: the overlay depends on it |
| `~/vms/nixvm/nixvm-desktop.qcow2` | Overlay on the image. **All of the VM's state** |
| `~/vms/nixvm/vars-desktop.fd` | The VM's UEFI variables |
| `~/vms/nixvm/host` | Link to the built `desktop-host` |
| `/usr/share/wayland-sessions/nixvm.desktop` | The login screen entry |
| `/etc/udev/rules.d/70-nixvm-usb.rules` | Lets QEMU claim the USB devices it passes through |

## Setting up a host

Needs Nix, plus from the distribution: QEMU with GTK and virgl, OVMF, and
Sway (`sudo apt install qemu-system-x86 qemu-system-gui ovmf sway`). QEMU has
to be the host's own, not one from nixpkgs: virgl needs the host's GL drivers.
The user must be in group `kvm` and able to `sudo` without a password (the
launcher sets up networking with it).

```sh
mkdir -p ~/vms/nixvm && cd ~/vms/nixvm

# The image and an overlay on it. The overlay records this path, so go
# through the link.
nix build ~/.dotfiles/nixos#desktop-image --out-link base-desktop
qemu-img create -f qcow2 -F qcow2 \
  -b "$PWD"/base-desktop/*.qcow2 nixvm-desktop.qcow2
cp /usr/share/OVMF/OVMF_VARS_4M.fd vars-desktop.fd

# The launcher and session.
nix build ~/.dotfiles/nixos#desktop-host --out-link host
```

The login screen entry, `/usr/share/wayland-sessions/nixvm.desktop` (the
greeter cannot read your home directory, so this is a real file, not a link):

```ini
[Desktop Entry]
Name=NixOS VM
Comment=The NixOS desktop VM, full screen; shutting it down logs out
Exec=/home/zetlen/vms/nixvm/host/bin/nixvm-session
Type=Application
DesktopNames=sway
```

Installing Sway adds a plain "Sway" entry too. To hide it in a way that
survives upgrades:

```sh
sudo mkdir -p /usr/share/wayland-sessions-disabled
sudo dpkg-divert --rename \
  --divert /usr/share/wayland-sessions-disabled/sway.desktop \
  /usr/share/wayland-sessions/sway.desktop
```

USB passthrough, `/etc/udev/rules.d/70-nixvm-usb.rules`, one rule per
`-device usb-host` line in `desktop-host.nix` (these are joe's):

```udev
# Intel AX201 Bluetooth controller
SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="8087", ATTR{idProduct}=="0026", GROUP="kvm", MODE="0660"
# YubiKeys, in whichever port
SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="1050", GROUP="kvm", MODE="0660"
# Samsung Flash Drive FIT
SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="090c", ATTR{idProduct}=="1000", GROUP="kvm", MODE="0660"
```

Then `sudo udevadm control --reload && sudo udevadm trigger`.

On another machine or network, change in `flake.nix` the `homeConnection`
(the NetworkManager connection that means "at home"), in `desktop.nix` the
`10-lan` network (address, gateway, DNS, search domain), and in
`desktop-host.nix` the `usb-host` devices. Pick a LAN address outside the
router's DHCP pool.

## Day to day

- **In the VM**: user `zetlen`, initial password `zetlen`. Super+/ lists
  Sway's bindings. The power button in the bar has Log out, Reboot and Shut
  down. `halt` stops the CPU without ending QEMU; use `poweroff`.
- **QEMU's own keys** still work: Ctrl-Alt-2 is the monitor (`system_reset`,
  `device_add`, `sendkey ctrl-alt-f2`), Ctrl-Alt-3 the serial console,
  Ctrl-Alt-1 back to the display. Ctrl-Alt-F*n* goes to the *host's* consoles,
  never the guest's.
- **If QEMU hangs**: Ctrl+Alt+Shift+Backspace ends the session.
- **Getting in from outside**: `ssh zetlen@192.168.1.250` at home, or
  `ssh -p 2223 zetlen@localhost` from the host anywhere.
- **A USB device for a running VM**: add its udev rule, then in the monitor
  `device_add usb-host,vendorid=0x…,productid=0x…,id=name`. Add the same line
  to `desktop-host.nix` to make it permanent.

Changing the guest: edit, commit, push, then in the VM

```sh
sudo nixos-rebuild switch --refresh --flake \
  'git+https://got.colonpipe.org/zetlen/dotfiles.git?ref=nixos-vm&dir=nixos#nixvm-desktop'
```

A flake only sees files git tracks; `git add` new ones first. Changing the
launcher: rerun the `nix build …#desktop-host` line on the host.

**Do not rebuild `desktop-image` casually.** An overlay is only valid against
the exact image it was made on; a new image means a new overlay, and the old
one's contents are gone. Everything after first boot goes through
`nixos-rebuild` inside the VM instead.

## Why it is built this way

- **A Sway with no bindings, not a desktop.** Something has to make the QEMU
  window full screen. Under a real desktop (COSMIC, i3) the desktop's own
  shortcuts fight the guest for Super and Alt, and QEMU's input grab is the
  only way through. With nothing bound there is nothing to fight over.
- **Proxy ARP, not a bridge.** A Wi-Fi access point only accepts frames from
  the MAC that associated, so bridging a VM onto Wi-Fi does not work. The host
  answers ARP for the VM's address and routes to a tap device instead. The VM
  is reachable from the LAN at its own address, but shares the host's MAC, and
  broadcasts (mDNS, DHCP) do not reach it; hence the static address.
- **A NAT NIC as well, always.** Away from home it is the only network. At
  home it is the way back in when the LAN side is misconfigured. The guest
  prefers the LAN route by metric.
- **`bootindex` on the root disk.** Without it OVMF tries network boot on
  every NIC first (minutes, fans at full), and adding any device can leave the
  disk's boot entry stranded behind the EFI shell.
- **No hibernate or suspend in the guest.** The guest's 3D state lives in the
  QEMU process. After a resume it is gone, the guest waits forever on GPU work
  that will never complete, and logins hang behind it. To pause the VM,
  suspend the host.
