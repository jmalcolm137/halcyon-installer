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

## 0.1.5-r1 (live fixes)

- ISO: `halcyon-linux-x86_64-LIVE-20261105-sde-r1.iso`
- Size: `1847805952` bytes
- SHA-256: `591b1cbdc8406f66b99a2e44b635c2ac066e0e56000ee0d405591ce061736a0e`
- Based on the 0.1.5 package set; the root filesystem and initramfs were
  remastered with the tracked live overlay and initramfs changes.

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
