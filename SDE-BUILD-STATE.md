# SDE ISO build state (power-loss checkpoint)

Source state is committed and pushed:

- commit `bd93d2a` — “Add Serenity Desktop Environment image type”
- https://github.com/jmalcolm137/halcyon-installer

## What is already done

- Added the `sde` image type to `mklive-image.sh`.
- SDE image installs:
  - `sddm`
  - `sddm-default-cage`
  - `sddm-theme-none`
  - `serenity-desktop`
  - `ladybird-sde`
- SDDM autologin selects `sde` when `sde.desktop` is installed.
- `sddm-default-cage` is forced so the package solver does not pull
  `plasma-desktop`/KDE.
- Package solver was verified in a clean root: 0 Plasma packages selected.
- `ladybird-sde` and `serenity-desktop` are consumed from the local
  `cports/packages/halcyon-extra` repository.
- `blue-grid.png` is provided by the `serenity-lagom` package at
  `/usr/lib/sde/share/res/wallpapers/blue-grid.png`; the SDE session defaults
  to it.

## What was interrupted

The corrected SDE ISO build was still running at roughly 561/727 packages when
power was lost. No `halcyon-linux-*-sde.iso` was produced.

The partial build directory is:

```
/home/jmalcolm/Projects/halcyon/build-halcyon-sde
```

It may contain root-owned files and stale mounts. Remove it before rebuilding:

```sh
docker run --rm --privileged \
  -v /home/jmalcolm/Projects/halcyon:/work \
  alpine:latest rm -rf /work/build-halcyon-sde
```

The APK cache at `/home/jmalcolm/Projects/halcyon/apk-cache` can be kept to
speed up the rebuild.

## Resume

```sh
cd /home/jmalcolm/Projects/halcyon
HALCYON_BLDROOT=/home/jmalcolm/Projects/cports/bldroot-halcyon \
HALCYON_IMAGE=sde \
HALCYON_BUILD_DIR=/home/jmalcolm/Projects/halcyon/build-halcyon-sde \
HALCYON_ISO=/home/jmalcolm/Projects/halcyon/halcyon-linux-x86_64-LIVE-20261103-sde.iso \
./build-halcyon-iso.sh
```

Then verify:

- SDDM autologin starts `sde`
- the SDE wallpaper is `blue-grid.png`
- `ladybird-sde` is installed and its desktop entry is present
- the ISO boots successfully

## Local package state

The SDE/ladybird packages remain in:

```
/home/jmalcolm/Projects/cports/packages/halcyon-extra/x86_64/
```

`serenity-desktop`, `serenity-lagom`, and `ladybird-sde` are present there.
The existing `bldroot-halcyon` cbuild root is also present.
