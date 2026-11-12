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

# Halcyon x86_64 images use the linux-halcyon kernel (CachyOS patches plus
# Apple T2 support). Other architectures keep the regular linux-stable kernel.
if [ -z "$KERNEL_PKGS" ]; then
    case "$IMAGE_ARCH" in
        x86_64)
            # linux-halcyon-devel provides the kernel headers used by CKMS
            # when building the installed system's modules.
            KERNEL_PKGS="linux-halcyon linux-halcyon-devel"
            ;;
        *)
            KERNEL_PKGS="linux-stable linux-stable-devel"
            ;;
    esac
fi

case "$IMAGE_ARCH" in
    x86_64)
        # bcachefs and broadcom-wl are out-of-tree modules on linux-halcyon.
        # The precompiled modules are for the live session only; the installer
        # removes them from the target and rebuilds from the CKMS sources.
        FILESYSTEM_PKGS="bcachefs-tools linux-halcyon-bcachefs-bin"
        HARDWARE_PKGS="broadcom-wl broadcom-wl-ckms linux-halcyon-broadcom-wl-bin firmware-apple t2fanrd tiny-dfr"
        ;;
    *)
        FILESYSTEM_PKGS="bcachefs-tools"
        HARDWARE_PKGS=
        ;;
esac

# Keep these on every image: the installer ensures they are present on the
# target regardless of the desktop choice.
readonly REQUIRED_PKGS="uutils-coreutils ckms base-shells bcachefs-ckms"

readonly FILESYSTEM_PKGS
readonly BASE_PKGS="base-full base-live ${KERNEL_PKGS} ${FILESYSTEM_PKGS} ${REQUIRED_PKGS} ${HARDWARE_PKGS} ${EXTRA_PKGS}"

case "$IMAGE" in
    minimal)
        PKGS="base-minimal base-full-kernel ${KERNEL_PKGS} ${FILESYSTEM_PKGS} ${REQUIRED_PKGS} ${EXTRA_PKGS}"
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
        PKGS="${BASE_PKGS} sddm sddm-default-cage sddm-theme-none serenity-desktop ladybird-sde sparted halcyon-setup crush"
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
