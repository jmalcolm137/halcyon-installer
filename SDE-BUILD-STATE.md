# SDE ISO build state

## 0.1.19 (uutils overlay corrected to /usr/gnubin)

```
/home/jmalcolm/Projects/halcyon-installer/halcyon-linux-x86_64-LIVE-20261124-sde-r2.iso
```

- Size: 2097977344 bytes (2.0 GiB)
- SHA-256: 89c680d5e5025caf3ac8f12db9871baa11882f0ac0ab46981b705604d35177e7
- Volume ID: HALCYON_LIVE
- Release tag: 0.1.19
- GitHub release asset headroom: 49,506,304 bytes under the 2 GiB limit.

- Corrects the overlay directory from `/usr/gnulib` to `/usr/gnubin`.
  `uutils-coreutils` 0.13.0-r1 and `uutils-findutils` 0.11.0-r1 install the
  Rust utilities there, and `gnu-compat` 0.1.0-r2 adds its GNU links to the
  same directory.
- `base-files` 0.2-r3 puts `/usr/gnubin` on PATH after `/usr/local/bin` and
  before `/usr/bin`.
- No `/usr/bin/gnu` or `/usr/gnulib` remains.
- The online `halcyon-core`/`halcyon-extra` repositories were updated with
  `base-files` 0.2-r3, `uutils-coreutils` 0.13.0-r1, `uutils-findutils`
  0.11.0-r1 and `gnu-compat` 0.1.0-r2 before this release.
- Supersedes 0.1.18, which used `/usr/gnulib`.

- Verified in QEMU/KVM: `PATH=/usr/local/bin:/usr/gnubin:/usr/bin`; `ls`,
  `find`, `awk` and `tar` all resolve to `/usr/gnubin`; `ls --version` is
  `uutils coreutils 0.13.0`, `find --version` is `0.11.0`; `/usr/bin/gnu` and
  `/usr/gnulib` do not exist; the installed packages are `base-files`
  0.2-r3, `uutils-coreutils` 0.13.0-r1, `uutils-findutils` 0.11.0-r1 and
  `gnu-compat` 0.1.0-r2.

## 0.1.18 (uutils overlay in /usr/gnulib)

```
/home/jmalcolm/Projects/halcyon-installer/halcyon-linux-x86_64-LIVE-20261124-sde.iso
```

- Size: 2097977344 bytes (2.0 GiB)
- SHA-256: a5382c43fcd07cfb6b84434cd395d558502bdfdbb2ac03ac1196c921a85a70de
- Volume ID: HALCYON_LIVE
- Release tag: 0.1.18
- GitHub release asset headroom: 49,506,304 bytes under the 2 GiB limit.

- The uutils userland overlay moved from `/usr/bin/gnu` to `/usr/gnulib`.
  `uutils-coreutils` 0.13.0 installs the multicall binary and its symlinks
  there, no longer depends on the GNU packages, and no longer links the GNU
  fallbacks.
- New `uutils-findutils` 0.11.0 installs `find`, `locate`, `updatedb` and
  `xargs` into `/usr/gnulib`.
- New `gnu-compat` 0.1.0-r1 depends on the GNU tools uutils does not provide
  (not GNU `findutils`) and links them into `/usr/gnubin`; it also depends on
  `uutils-coreutils` and `uutils-findutils`.
- `base-files` 0.2-r2 is built from `halcyon-core` (the upstream
  `main/base-files` is unchanged because cbuild reads it for its chroot
  passwd/group). It inserts `/usr/gnulib` into PATH after `/usr/local/bin` and
  before `/usr/bin` in `profile.path`, and installs a bashrc.d snippet so
  interactive bash gets the same fixup.
- The live `/etc/mkshrc` applies the same fixup for the SDE Terminal.
- The online `halcyon-core`/`halcyon-extra` repositories were updated with
  `base-files` 0.2-r2, `uutils-coreutils` 0.13.0-r0, `uutils-findutils`
  0.11.0-r0 and `gnu-compat` 0.1.0-r1 before this release.

- Verified in QEMU/KVM: the live `anon` session has
  `PATH=/usr/local/bin:/usr/gnulib:/usr/bin` in both the SDE Terminal and a
  login shell; `/usr/bin/gnu` does not exist; `ls` and `find` resolve to
  `/usr/gnulib` (`uutils coreutils 0.13.0`, `find 0.11.0`); `/usr/gnubin`
  contains the GNU links; `awk`, `tar` and `m4` resolve from `/usr/bin`.

## 0.1.17 (pre-T2 Broadcom Wi-Fi fix)

```
/home/jmalcolm/Projects/halcyon-installer/halcyon-linux-x86_64-LIVE-20261123-sde-r2.iso
```

- Size: 2095028224 bytes (2.0 GiB)
- SHA-256: b9f64a9c05a58d3da1681bea93235e368f36d219baf44aa3a15fb799b975bfa4
- Volume ID: HALCYON_LIVE
- Release tag: 0.1.17
- GitHub release asset headroom: 52,455,424 bytes under the 2 GiB limit.
- The online repositories were updated before this release: `broadcom-wl`
  6.30.223.271-r3, `halcyon-setup` 0.1.0-r17/r18 and `partition-editor`
  0.1.0-r0 (required by `halcyon-setup` r18) had not been published.

- Fixed Wi-Fi on pre-T2 Broadcom Macs (reported on a 2009 MacBook Pro,
  BCM4322). The initramfs `ORDER` runs `init-top/udev` before
  `init-top/000-halcyon-wifi`, so udev loaded `ssb`/`b43` (or `bcma`) for the
  card before the runtime blacklist existed and `wl` could not bind. This
  regressed in 0.1.12, when the static blacklist was replaced by runtime
  selection.
- `broadcom-wl` 6.30.223.271-r3: its initramfs hook bakes a static blacklist of
  `b43`, `b43legacy`, `bcm43xx`, `bcma`, `brcm80211`, `brcmfmac`, `brcmsmac`
  and `ssb` into the initramfs (valid on T2 too, which defers `brcmfmac` there
  anyway). On non-T2 machines `wifi-select --apply` also unloads any of those
  drivers that claimed the card and reloads `wl`.
- The driver itself is unchanged: the patch series is identical to Arch
  `broadcom-wl-dkms` 6.30.223.271-50, and `wl.ko` matches the 7.3.1 kernel's
  `Module.symvers` (134 symbols, no CRC mismatches).
- Removed `initramfs-tools/hooks/broadcom-wl` from this repository. It shadowed
  the package's hook of the same name during the image build, and
  `cleanup_initramfs` then deleted the package's file from the live root.
- `networkmanager` is now listed explicitly in the SDE image.
- Verified in QEMU/KVM: boots straight to the desktop; the initrd contains
  `/etc/modprobe.d/halcyon-wifi-initramfs.conf`; `wl` is loaded and none of the
  blacklisted drivers are; the `networkmanager` dinit service is STARTED and
  connected. Not yet verified on BCM4322 hardware.

## 0.1.16 (boot directly to the desktop)

```
/home/jmalcolm/Projects/halcyon-installer/halcyon-linux-x86_64-LIVE-20261123-sde.iso
```

- Size: 2095026176 bytes (2.0 GiB)
- SHA-256: 03cd4e8a41e3c5a2cf4f1999fab1c9dfe5bf24798cb6f4181e4f277b8e38edda
- Volume ID: HALCYON_LIVE
- Release tag: 0.1.16
- GitHub release asset headroom: 52,457,472 bytes under the 2 GiB limit.

- SDDM autologin now reaches the SDE desktop without the greeter. The
  `sddm-autologin` PAM stack runs `pam_shells`, and the live user's shell
  (`/usr/local/bin/live-sh`) was not in `/etc/shells`, so autologin failed and
  SDDM showed the greeter. The live initramfs now adds the live user's shell to
  the live root's `/etc/shells`; the installer still regenerates the target's
  copy from the `shells.d` links.
- The live `anon` and `root` passwords are now `action` (previously `chimera`).
- Packages are unchanged from 0.1.15.
- Verified in QEMU/KVM: the ISO boots straight to the SDE desktop as `anon`;
  `su` accepts `action` for `anon` and `root` and rejects `chimera`.

## 0.1.15 (partition-editor rename and fixes, halcyon-setup Win95 UX polish)

```
/home/jmalcolm/Projects/halcyon-installer/halcyon-linux-x86_64-LIVE-20261122-sde.iso
```

- Size: 2095026176 bytes (2.0 GiB)
- SHA-256: e20dfda9c70fbbe2517fea7773aa787c6b1c070e06a54fb0344325ead14b2694
- Volume ID: HALCYON_LIVE
- Release tag: 0.1.15
- GitHub release asset headroom: 52,457,472 bytes under the 2 GiB limit.

- Renamed `sparted` to `partition-editor` (`0.1.0-r0`) with fixes for the Create
  Partition Table use-after-move crash, clipped dialog warnings, File System
  Support table display, 1 MiB partition alignment, newly created partition
  formatting, unsafe start-move resizing, device filtering (`fd*`/`sr*`/`zram*`),
  and launcher environment handling.
- Updated `halcyon-setup` to `0.1.0-r18` (depends on `partition-editor`) with
  Windows 95 wizard UX polish: etched grooves and sidebar gradient, dynamic
  per-step header subtitles, fixed Finish/Cancel/Remove button states, floppy
  and optical device filtering, double-click mount assignment, and immediate
  POSIX username validation.
- Updated `serenity-desktop` to `0.1.0-r5` (`libglvnd` dependency) and
  `serenity-lagom` `0.1.0-r4`.

## 0.1.14 (package-managed repository configuration)

```
/home/jmalcolm/Projects/halcyon-installer/halcyon-linux-x86_64-LIVE-20261112-sde.iso
```

- Size: 2094974976 bytes (2.0 GiB)
- SHA-256: 7b52db9ee616ed6fc55b9046bbd8d1aa5b58ea3afb23736fd542a36c16a2db67
- Volume ID: HALCYON_LIVE
- Release tag: 0.1.14
- GitHub release asset headroom: 52,508,672 bytes under the 2 GiB limit.

- The Halcyon repository configuration is package-managed. The live image
  includes `halcyon-repo-core` and `halcyon-repo-extra`; the installer adds
  both to the target world. They install
  `/etc/apk/repositories.d/20-halcyon-core.list`,
  `/etc/apk/repositories.d/21-halcyon-extra.list`, and the Halcyon key.
- x86_64 uses `linux-halcyon` 7.3.1-r1. `linux-halcyon-devel` is installed on
  the target from the online repo for CKMS.
- The live image includes precompiled bcachefs/Broadcom modules for the live
  session. The target removes them and builds the modules from
  `bcachefs-ckms`/`broadcom-wl-ckms` during initramfs creation.
- `/etc/shells` is regenerated and verified in the target.
- `halcyon-setup` 0.1.0-r16.
- `crush` is not installed in the image.
- The online repositories were updated with the kernel, devel, repository
  packages, and image packages before this release.

## 0.1.13 (online repos, CKMS target modules)

```
/home/jmalcolm/Projects/halcyon-installer/halcyon-linux-x86_64-LIVE-20261111-sde.iso
```

- Size: 2094979072 bytes (2.0 GiB)
- SHA-256: 29967911ef0ebf549dcffd3cca8e317787c91cae0b59a64ebe6f58906688b403
- Volume ID: HALCYON_LIVE
- Release tag: 0.1.13
- GitHub release asset headroom: 52,504,576 bytes under the 2 GiB limit.

- The live session and installed target use the online
  `halcyon-core`/`halcyon-extra` repositories from
  `live-overlay/etc/apk/repositories.d`. The installer writes the same files
  explicitly into the target, so the configuration survives reboot.
- x86_64 uses `linux-halcyon` 7.3.1-r1. `linux-halcyon-devel` is installed on
  the target from the online repo so CKMS can build modules.
- The live image includes the precompiled bcachefs/Broadcom modules for the
  live session. The installer removes them, installs `bcachefs-ckms` and
  `broadcom-wl-ckms`, resets CKMS state, and builds both modules during the
  target's initramfs creation.
- `/etc/shells` is regenerated and verified in the target.
- `halcyon-setup` 0.1.0-r15.
- `crush` is not installed in the SDE image.
- The online repositories were updated with the kernel, devel, ladybird, and
  image packages before this release.

## 0.1.12 (r19)

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
  desktop was not entered during the headless boot test (fixed in 0.1.16).
- Real T2 hardware. Wi-Fi selection was unit-tested with a fake sysfs tree:
  T2 blacklists `wl` and loads `brcmfmac`; non-T2 blacklists `brcmfmac` and
  loads `wl`.
