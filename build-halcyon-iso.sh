#!/bin/sh
#
# Build the Halcyon Linux installation ISO.
#
# The bcachefs and Broadcom-wl packages are built from the sibling cports
# checkout (the halcyon-core repository) with cbuild. The ISO itself is then
# assembled with mklive-image.sh, which needs root for chroots and mounts;
# when this script is not run as root it uses docker or podman to provide
# that environment.
#
# Copyright 2026 Halcyon Linux developers
#
# License: BSD-2-Clause
#

set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

CPORTS=${HALCYON_CPORTS:-"$ROOT/../cports"}
ARCH=${HALCYON_ARCH:-x86_64}
IMAGE=${HALCYON_IMAGE:-sde}
BLDROOT=${HALCYON_BLDROOT:-"$CPORTS/bldroot-halcyon"}
BUILD_DIR=${HALCYON_BUILD_DIR:-"$ROOT/build-halcyon"}
OUT=${HALCYON_ISO:-"$ROOT/halcyon-linux-$ARCH-LIVE-$(date '+%Y%m%d')-$IMAGE.iso"}
JOBS=${HALCYON_JOBS:-4}
CONTAINER_IMAGE=${HALCYON_CONTAINER_IMAGE:-alpine:latest}

die() {
    echo "ERROR: $*" >&2
    exit 1
}

msg() {
    printf '\033[1m%s\033[m\n' "$*"
}

[ "$(id -u)" != "0" ] || \
    die "run this as a regular user; it uses docker/podman for the root-only ISO steps"

[ -d "$CPORTS/halcyon-core" ] || \
    die "no cports checkout with halcyon-core at $CPORTS (set HALCYON_CPORTS)"

[ -x "$CPORTS/cbuild" ] || die "cbuild not found in $CPORTS"

# bootstrap the private build root if it does not exist yet
if [ ! -f "$BLDROOT/.cbuild_chroot_init" ]; then
    msg "Bootstrapping cbuild root ($BLDROOT)..."
    (cd "$CPORTS" && ./cbuild -b "$BLDROOT" -j "$JOBS" bootstrap)
fi

msg "Building bcachefs userspace tools..."
(cd "$CPORTS" && ./cbuild -b "$BLDROOT" -j "$JOBS" pkg halcyon-core/bcachefs-tools)

msg "Building the prebuilt bcachefs kernel module..."
(cd "$CPORTS" && ./cbuild -b "$BLDROOT" -j "$JOBS" \
    pkg halcyon-core/linux-stable-bcachefs-bin)

if [ "$ARCH" = "x86_64" ]; then
    msg "Building the Broadcom-wl driver..."
    (cd "$CPORTS" && ./cbuild -b "$BLDROOT" -j "$JOBS" \
        pkg halcyon-core/broadcom-wl)

    msg "Building the prebuilt Broadcom-wl kernel module..."
    (cd "$CPORTS" && ./cbuild -b "$BLDROOT" -j "$JOBS" \
        pkg halcyon-core/linux-stable-broadcom-wl-bin)
fi

if [ "$IMAGE" = "sde" ]; then
    msg "Building the Serenity Desktop Environment..."
    (cd "$CPORTS" && ./cbuild -b "$BLDROOT" -j "$JOBS" \
        pkg halcyon-extra/serenity-desktop)

    msg "Building the ladybird-sde browser..."
    (cd "$CPORTS" && ./cbuild -b "$BLDROOT" -j "$JOBS" \
        pkg halcyon-extra/ladybird-sde)

    msg "Building uutils-coreutils..."
    (cd "$CPORTS" && ./cbuild -b "$BLDROOT" -j "$JOBS" \
        pkg halcyon-extra/uutils-coreutils)

    msg "Building SParted..."
    (cd "$CPORTS" && ./cbuild -b "$BLDROOT" -j "$JOBS" \
        pkg halcyon-extra/sparted)
fi

REPO="$CPORTS/packages/halcyon-core"
EXTRA_REPO="$CPORTS/packages/halcyon-extra"
[ -f "$REPO/$ARCH/APKINDEX.tar.gz" ] || \
    die "the halcyon-core package repository was not created at $REPO"
[ -f "$EXTRA_REPO/$ARCH/APKINDEX.tar.gz" ] || \
    die "the halcyon-extra package repository was not created at $EXTRA_REPO"

APK_STATIC=${HALCYON_APK_STATIC:-"$BLDROOT/usr/bin/apk.static"}
[ -x "$APK_STATIC" ] || die "no static apk found at $APK_STATIC"

[ -d "$ROOT/keys" ] || die "missing public key directory $ROOT/keys"
for k in "$ROOT/keys"/*.pub; do
    [ -r "$k" ] || die "no public keys in $ROOT/keys"
    break
done

msg "Building Halcyon Linux $IMAGE ISO for $ARCH..."
msg "Output: $OUT"

if command -v docker > /dev/null 2>&1; then
    RUNTIME=docker
elif command -v podman > /dev/null 2>&1; then
    RUNTIME=podman
else
    die "docker or podman is required (or run mklive-image.sh as root manually)"
fi

exec "$RUNTIME" run --rm --privileged \
    -v "$ROOT:$ROOT" \
    -v "$CPORTS:$CPORTS" \
    -v "$APK_STATIC:/usr/local/bin/halcyon-apk:ro" \
    -w "$ROOT" \
    "$CONTAINER_IMAGE" sh -c '
        exec ./mklive-image.sh -b "$1" -- \
            -A /usr/local/bin/halcyon-apk -a "$2" \
            -r "$3" \
            -r "$4" \
            -r https://repo.chimera-linux.org/current/main \
            -r https://repo.chimera-linux.org/current/user \
            -k "$5/keys" -o "$6" "$7"
    ' sh "$IMAGE" "$ARCH" "$REPO" "$EXTRA_REPO" "$ROOT" "$OUT" "$BUILD_DIR"
