# SDE ISO build state

## ISO

```
/home/jmalcolm/Projects/halcyon/halcyon-linux-x86_64-LIVE-20261111-sde-r19.iso
```

- Size: 2116790272 bytes (2.0 GiB)
- SHA-256: 43e038dcbbe018e3ef49c6444593a40b419c7e572f53b720ccbbc480b31addac
- Volume ID: HALCYON_LIVE
- Release tag: 0.1.12

## Kernel and hardware support

- `linux-halcyon` 7.3.1-r1 is the x86_64 kernel (CachyOS patches, Apple T2
  drivers).
- `linux-halcyon-bcachefs-bin` 1.39.7.7.3.1-r0.
- `broadcom-wl` 6.30.223.271-r2 with runtime Wi-Fi driver selection.
- `linux-halcyon-broadcom-wl-bin` 6.30.223.271.7.3.1-r0.
- `firmware-apple` 20221231-r0 (includes the BCM4377b T2 firmware).
- `t2fanrd` 0.1.0 and `tiny-dfr` 0.3.8 are installed and enabled by default.
- No ZFS packages.
- No static `brcmfmac` blacklist. `/usr/lib/halcyon/wifi-select` detects T2 via
  PCI `106b:1801` with a DMI fallback, and the initramfs `000-halcyon-wifi`
  writes the selection before udev. The `halcyon-wifi` dinit service applies it
  after the real root is mounted.

## Setup wizard

- `halcyon-setup` 0.1.0-r14.
- Options page offers `t2fanrd` and `tiny-dfr` checkboxes, both default on.
- The finished page has an **Eject and restart** button that ejects optical
  media and reboots into the installed system.

## Verified

- The ISO boots through limine on a BIOS/QEMU virtual machine.
- Live boot completes without dinit service errors (the `halcyon-wifi` and
  `zram` services are valid `scripted` services).
- SDDM starts and presents the session selector with the SDE session.
- Rootfs contains `linux-halcyon`, both out-of-tree module packages,
  `firmware-apple`, `t2fanrd`, `tiny-dfr`, `halcyon-setup`.
- `/usr/lib/halcyon/wifi-select`,
  `/usr/share/initramfs-tools/scripts/init-top/000-halcyon-wifi`,
  `/usr/lib/dinit.d/halcyon-wifi` and its `boot.d` link are present.
- The initrd contains `wl.ko`, `brcmfmac.ko`, `brcmutil.ko`,
  `000-halcyon-wifi` and `wifi-select`.
- The SDE `.md` manuals are decompressed in the image so Help can read them.
- NVIDIA GPU firmware is kept out of the initrd (it stays in the rootfs), which
  keeps the ISO under GitHub's 2 GiB release asset limit.

## Not exercised in this build

- Automated SDDM login: the greeter prompts for the live user password, so the
  desktop was not entered during the headless boot test.
- Real T2 hardware. Wi-Fi selection was unit-tested with a fake sysfs tree:
  T2 blacklists `wl` and loads `brcmfmac`; non-T2 blacklists `brcmfmac` and
  loads `wl`.
