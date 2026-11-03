# SDE ISO build state

Completed.

## ISO

```
/home/jmalcolm/Projects/halcyon/halcyon-linux-x86_64-LIVE-20261103-sde.iso
```

- Size: 1.6 GiB
- SHA-256: f769e25074736b041f7c1c20393411eef15700f37fa5e978071d33a982d609c8
- Volume ID: HALCYON_LIVE

## Verified

- ISO boots through limine.
- SDDM autologins with `User=anon`, `Session=sde`.
- SDE `WindowServer` starts on seat0/VT7 with DRM + libinput.
- Taskbar, FileManager, LaunchServer, ImageDecoder, portal backend and the
  standard SDE applets are running.
- The session log reports:
  `WindowServer: seeded wallpaper from '/usr/lib/sde/share/res/wallpapers/blue-grid.png'`
- A VNC screenshot confirms the SDE desktop with the blue-grid wallpaper.
- `ladybird-sde` and its `ladybird.desktop` entry are installed.
- `plasma-desktop` is not installed; no Plasma/KDE packages were selected.
- The SDE/ladybird packages were consumed from:
  `/home/jmalcolm/Projects/cports/packages/halcyon-extra/`

## Notes

The `broadcom-wl` blacklist still applies to this image because it is part of
the x86_64 hardware package set. On a T2 Mac (BCM4377b, `brcmfmac`) this means
Wi-Fi will not work unless the `brcmfmac` blacklist is removed or made
conditional.

The build tree `build-halcyon-sde/` and `apk-cache/` can be removed if the
ISO does not need to be rebuilt.
