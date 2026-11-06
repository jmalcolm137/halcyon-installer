# SDE ISO build state

Completed, including `uutils-coreutils`.

## ISO

```
/home/jmalcolm/Projects/halcyon/halcyon-linux-x86_64-LIVE-20261103-sde.iso
```

- Size: 1722195968 bytes (1.7 GiB)
- SHA-256: c2dda882baee40f7d15a0ab0ce19ae2b89b25031492bfedd37dfd179e4b6a90b
- Volume ID: HALCYON_LIVE

## Verified

- ISO boots through limine.
- SDDM autologins with `User=anon`, `Session=sde`.
- SDE `WindowServer` starts on seat0/VT7 with DRM + libinput.
- Taskbar, FileManager, LaunchServer, ImageDecoder, portal backend and the
  standard SDE applets run.
- The session log reports:
  `WindowServer: seeded wallpaper from '/usr/lib/sde/share/res/wallpapers/blue-grid.png'`
- A VNC screenshot confirms the SDE desktop with the blue-grid wallpaper.
- `ladybird-sde` and its `ladybird.desktop` entry are installed.
- `plasma-desktop` is not installed; no Plasma/KDE packages were selected.
- `uutils-coreutils` is installed:
  - `/usr/bin/gnu/coreutils` multicall binary
  - 115 utility symlinks under `/usr/bin/gnu`
  - `/etc/profile.d/00-gnu-path.sh`
- The SDE session environment has:
  `PATH=/usr/bin/gnu:/usr/local/bin:/usr/bin`
- `command -v ls` resolves to `/usr/bin/gnu/ls`, and
  `ls --version` reports `ls (uutils coreutils) 0.12.0`.
- The SDE/ladybird/uutils packages were consumed from:
  `/home/jmalcolm/Projects/cports/packages/halcyon-extra/`

## Notes

The `broadcom-wl` blacklist still applies to this image because it is part of
the x86_64 hardware package set. On a T2 Mac (BCM4377b, `brcmfmac`) this means
Wi-Fi will not work unless the `brcmfmac` blacklist is removed or made
conditional.

The build tree `build-halcyon-sde/` and `apk-cache/` can be removed if the
ISO does not need to be rebuilt.

## GitHub releases

### 0.1.1

https://github.com/jmalcolm137/halcyon-installer/releases/tag/0.1.1

Assets:

- `halcyon-linux-x86_64-LIVE-20261103-sde.iso`
  - size: 1722195968 bytes
  - state: uploaded
  - digest: `sha256:c2dda882baee40f7d15a0ab0ce19ae2b89b25031492bfedd37dfd179e4b6a90b`
- `halcyon-linux-x86_64-LIVE-20261103-sde-uutils.sha256`
  - size: 109 bytes
  - state: uploaded

### 0.1.0

Previous SDE image without uutils:

https://github.com/jmalcolm137/halcyon-installer/releases/tag/0.1.0

## 0.1.4

- ISO: `halcyon-linux-x86_64-LIVE-20261104-sde-r8.iso`
- Size: 1727184896 bytes (1.7 GiB)
- SHA-256: `6f0a87eab87a0e58849c251ddb4a70c512d6454479b107be7861a24fc0698570`
- Release: https://github.com/jmalcolm137/halcyon-installer/releases/tag/0.1.4

Verified in QEMU:

- The SDE desktop boots with a native musl `WindowServer` (the 0.1.3 image
  overlaid a glibc build and failed before the desktop).
- A Terminal window opens and resizes interactively.
- Partition Editor launches and identifies itself as `Partition Editor`.
- Ladybird opens and renders `https://example.com/`.
- The WindowServer config selects Redmond 2000, and the live image installs
  the NetworkManager polkit rule for the active local user.
- SDE applications are linked into `/usr/bin` and the live user's standard
  home directories (including `~/Desktop`) are created.

## 0.1.5

- ISO: `halcyon-linux-x86_64-LIVE-20261105-sde.iso`
- Size: `1849266176` bytes
- SHA-256: `f2a77b05fe9746739b03bc38e432eb51a958be6db5eb299ade41777e09dd36e4`
- Release: https://github.com/jmalcolm137/halcyon-installer/releases/tag/0.1.5

Added to the SDE image:

- `halcyon-setup` 0.1.0, the Windows 95-style LibGUI installation wizard,
  including `/etc/skel/Desktop/HalcyonSetup.desktop`.
- `opencode` 2.2.5, with a desktop application entry and a
  `/usr/local/bin/opencode` launcher that supplies the bundled libstdc++ ABI
  shim path.
- A live-only PolicyKit rule (`/run/live` gate) that allows the active `wheel`
  user to use `pkexec` without the SDE polkit agent. This covers Partition
  Editor and Halcyon Setup; the rule is inactive on installed systems.

Verified from the published ISO filesystem:

- `/usr/bin/halcyon-setup` and `halcyon-setup.real --version` work.
- `/usr/local/bin/opencode --version` reports `opencode v2.2.5`.
- `halcyon-setup`, `opencode`, `libcxxabi` and `libgcc-chimera` are installed.
- The live PolicyKit rule and both desktop entries are present.
- The ISO boots to the SDE desktop; the Halcyon Setup desktop link is visible.

## 0.1.5-r2 (live fixes and USB boot)

- ISO: `halcyon-linux-x86_64-LIVE-20261105-sde-r2.iso`
- Size: `1847805952` bytes
- SHA-256: `2c52fa192e7ae406873acb5188cef594f79d1bcafb35fadcf9c7b811f10c661c`
- Based on the 0.1.5 package set; the root filesystem and initramfs were
  remastered with the tracked live overlay and initramfs changes.

The first remaster (r1) was optical/UEFI-only: its hybrid MBR did not carry
Limine's BIOS stage 1, so a BIOS machine booting the image from a USB stick
failed at `limine-bios.sys build ID mismatch`. r2 replaces the boot files with
the upstream Limine 12.9.0 release files and runs `limine bios-install`.

Fixes:

- The live initramfs creates a dedicated `live` group and adds the autologin
  user to it. The live PolicyKit rule now checks that group and no longer calls
  `polkit.spawn`; polkitd 128 crashed with SIGILL in duktape when the old rule
  ran, which made Partition Editor report that it needed authentication.
- The live overlay replaces `chimera-chroot` with a version that creates the
  target's `/dev`, `/proc`, `/sys` and `/tmp` mountpoints before mounting them,
  so a freshly formatted root no longer fails with `Failed to mount devfs`.
- The live overlay adds a `default` cursor theme that inherits Adwaita. Without
  it the SDE cursor manager loaded only the fallback arrow and never showed the
  resize cursors.

Verified in QEMU and VirtualBox:

- The live user is in `anon` and `live`; a local `pkexec id` returns `uid=0`
  without an authentication prompt.
- `chimera-chroot` on an empty target creates the pseudo-filesystem
  mountpoints and proceeds to the chroot.
- Hovering a window border shows the horizontal, vertical and diagonal resize
  cursors.
- `opencode` starts its TUI from the SDE Terminal.
- Ladybird opens and renders `https://example.com/`.
- The ISO boots to the SDE desktop under both BIOS and UEFI firmware.
- The ISO also boots with the image attached as a hard disk in BIOS mode,
  which is the USB-stick boot path.

## 0.1.5-r3 (Crush)

- ISO: `halcyon-linux-x86_64-LIVE-20261105-sde-r3.iso`
- Size: `1874841600` bytes
- SHA-256: `5bfdbe65fa7abe9406f1206f3f99598f95b0978a0f27d72c80aa25a6521989e1`
- Based on r2, with the `halcyon-extra/crush` package installed.

Added:

- `crush` 0.100.0, the Go terminal AI coding agent. The package uses the
  upstream static Linux x86_64 release binary, installs the shell completions
  and man page, and depends on `ca-certificates`.
- `crush` is included in the SDE package set in `mklive-image.sh`, and
  `build-halcyon-iso.sh` builds `halcyon-extra/crush` before assembling the
  image.

Verified in the live r3 image:

- `/usr/bin/crush` is owned by the `crush` package and reports
  `crush version v0.100.0`.
- The binary is statically linked and was tested under an emulated Penryn
  (Core 2, no SSE4.2) CPU.
- The r3 ISO keeps the r2 USB/BIOS, optical BIOS and UEFI boot layout.

## Post-r3 live-session fixes

The r3 image exposed three live-session problems. They are fixed in the
tracked overlay/initramfs for the next build:

- `halcyon-setup` and the desktop icon did nothing. The live session can carry
  a stale `WAYLAND_DISPLAY=wayland-0`, but the SDE compositor's socket is
  `sde`. The launcher now resolves the socket name and falls back to `sde`
  before calling `pkexec` or the privileged binary.
- `pkexec` failed with `org.freedesktop.DBus.Error.NoReply` because the live
  PolicyKit rule called `subject.isInGroup("live")`; polkitd 128 dies with
  SIGILL in duktape while evaluating it. The rule now matches
  `subject.local`, `subject.active` and a non-root `subject.user`, which
  `pkexec id` verifies as `uid=0` without crashing polkitd.
- The r3 ISO installed the pre-r3 `uutils-coreutils` (only
  `/etc/profile.d/00-gnu-path.sh`), and the live user's passwd shell was
  `/bin/sh` (mksh). The SDE Terminal therefore never applied `/usr/bin/gnu`.
  The live user now keeps `/bin/sh`; the live overlay installs `/etc/mkshrc`
  (which sources the package's generic profile hook), the initramfs sets
  `ENV=/etc/mkshrc` in `/etc/environment` (read by pam_env for the sddm
  session), and a live-only `/usr/local/bin/live-sh` wrapper sets `ENV` and
  execs `/bin/sh` because the SDE Terminal filters `ENV` out of the shell
  environment. `uutils-coreutils` itself is unchanged (r3) and remains usable
  on native Chimera. A new Terminal then reports `command -v ls` ->
  `/usr/bin/gnu/ls` and `ls --version` -> uutils 0.12.0.

## Post-r3 SDE Help fix

The r3 image shipped without the Serenity manual pages, so Help opened its
Error dialog for `/usr/share/man/man7/Help-index.md`. The v0.1.0 split install
skips the manual tree because the framework package was supposed to own it.

- `serenity-desktop` now copies
  `/usr/lib/sde/framework/serenity/Base/usr/share/man` into `/usr/share/man`
  (package `r3`), so the next ISO contains the Help index and application
  pages.
- `mklive.sh` now fails the image build if the SDE prefix is present but
  `/usr/share/man/man7/Help-index.md` is missing.

## Post-r3 installer Desktop and required packages

- The installer has a Desktop page between Accounts and Options. The SDE
  checkbox defaults on; clearing it removes `serenity-desktop`,
  `serenity-lagom`, `sddm`, the SDE greeter/theme packages and `ladybird-sde`
  from the target.
- `mklive-image.sh` now puts `uutils-coreutils` and `ckms` in `REQUIRED_PKGS`
  and includes `bcachefs-tools` plus `linux-stable-bcachefs-bin` on every
  image. The installer also runs `apk add` for all four on the target.
- `resolve_command()` had a use-after-free: `ByteString{path}.split(':')`
  returned views into a destroyed temporary. Command lookups such as
  `mkfs.vfat` could then fail randomly. The string now outlives the views, and
  standard sbin/bin directories are a fallback.
- `format_partition()` built the formatter flags but never put the program
  name at argument 0. `run()` then tried to execute `-F` and every filesystem
  creation failed with exit code 127. r5 inserts the formatter before the
  arguments; preflight checks the formatter and bcachefs tools.

## Post-r3 desktop launcher and chimera-chroot

- The live desktop now uses an executable `/home/anon/Desktop/Install Halcyon
  Linux` launcher that execs `/usr/bin/halcyon-setup`. The SDE file manager
  opens a non-executable `.desktop` file in TextEditor, which is why the old
  desktop link did not run the wizard. The installer also creates the pseudo
  mountpoints `/dev`, `/proc`, `/sys` and `/tmp` before chrooting.
- The live `chimera-chroot` override now verifies the pseudo-filesystem
  directories with `[ -d ]` instead of trusting `mkdir`'s exit status. Some
  userland `mkdir` builds return a nonzero status even when the directory
  already exists, which made the script report "Failed to mount devfs" and
  broke both the installer and the manual handbook sequence.
