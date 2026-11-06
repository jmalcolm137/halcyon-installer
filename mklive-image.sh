#!/bin/sh
#
# Convenience script for generating different kinds of live images

# all extra arguments are passed to mklive.sh as is
#
# Copyright 2022 q66 <q66@chimera-linux.org>
#
# License: BSD-2-Clause
#

IMAGE=
EXTRA_PKGS=
KERNEL_PKGS=

while getopts "b:k:p:" opt; do
    case "$opt" in
        b) IMAGE="$OPTARG";;
        k) KERNEL_PKGS="$OPTARG";;
        p) EXTRA_PKGS="$OPTARG";;
        *) ;;
    esac
done

shift $((OPTIND - 1))

# Broadcom-wl is x86_64-only (the vendor blob only supports x86). Pick up an
# explicit -a from the arguments passed through to mklive.sh, if any.
IMAGE_ARCH=$(uname -m)
_prev_arg=
for _arg in "$@"; do
    if [ "$_prev_arg" = "-a" ]; then
        IMAGE_ARCH="$_arg"
    fi
    _prev_arg="$_arg"
done

HARDWARE_PKGS=
case "$IMAGE_ARCH" in
    x86_64) HARDWARE_PKGS="broadcom-wl linux-stable-broadcom-wl-bin" ;;
esac

if [ -z "$KERNEL_PKGS" ]; then
    KERNEL_PKGS="linux-stable"
    if [ "$IMAGE" != "minimal" ]; then
        KERNEL_PKGS="$KERNEL_PKGS linux-stable-zfs-bin"
    fi
fi

# Halcyon ships bcachefs support in the regular installation media. The
# prebuilt kernel modules come from the halcyon-core repository and are
# built against the same linux-stable release as the rest of the image.
readonly FILESYSTEM_PKGS="bcachefs-tools linux-stable-bcachefs-bin"

readonly BASE_PKGS="base-full base-live ${KERNEL_PKGS} ${FILESYSTEM_PKGS} ${HARDWARE_PKGS} ${EXTRA_PKGS}"

case "$IMAGE" in
    minimal)
        PKGS="base-minimal base-full-kernel ${KERNEL_PKGS} ${EXTRA_PKGS}"
        ;;
    base)
        PKGS="${BASE_PKGS}"
        ;;
    gnome)
        PKGS="${BASE_PKGS} gnome"
        ;;
    plasma)
        PKGS="${BASE_PKGS} plasma-desktop"
        ;;
    sde)
        # Force the lightweight cage SDDM greeter provider; otherwise apk can
        # pick sddm-default-kwin, which pulls in Plasma/KDE even though the
        # image does not ask for plasma-desktop.
        #
        # uutils-coreutils installs the GNU userland in /usr/bin/gnu and a
        # generic profile hook. The live overlay adds /etc/mkshrc and live-sh,
        # which set ENV and exec /bin/sh, so the SDE Terminal sources the
        # hook. Keep the package installer-agnostic.
        PKGS="${BASE_PKGS} sddm sddm-default-cage sddm-theme-none serenity-desktop ladybird-sde uutils-coreutils sparted halcyon-setup crush"
        if [ "$IMAGE_ARCH" = "x86_64" ]; then
            PKGS="$PKGS opencode"
        fi
        # Partition/filesystem tools SParted drives. They are runtime
        # dependencies of sparted as well, but list them explicitly so the
        # live image keeps them if that package metadata ever changes.
        PKGS="$PKGS parted e2fsprogs dosfstools exfatprogs ntfs-3g btrfs-progs"
        PKGS="$PKGS xfsprogs f2fs-tools jfsutils lvm2 hfsutils"
        ;;
    *)
        echo "unknown image type: $IMAGE"
        echo
        echo "supported image types: base gnome plasma sde"
        exit 1
        ;;
esac

./mklive.sh -p "$PKGS" -f "$IMAGE" "$@"
