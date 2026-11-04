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
