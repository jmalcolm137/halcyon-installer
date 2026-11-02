# halcyon-live

This repository contains tooling to manage creation of Halcyon Linux images.
It is a fork of the Chimera Linux `chimera-live` tooling. The image creation
code is kept as close to upstream as possible.

Halcyon installation media are built from the regular Chimera package
repositories plus the `halcyon-core` repository from the sibling `cports`
checkout. Installation images (`base`, `gnome` and `plasma`) include
`bcachefs-tools` and the prebuilt `linux-stable-bcachefs-bin` kernel module,
so the live environment can create, mount, fsck and repair bcachefs
filesystems.

The prebuilt module is built with `BCACHEFS_RUST=0`: Chimera's `linux-stable`
is built without `CONFIG_RUST`, and the vendored Rust support in bcachefs
1.39.7 generates a target specification that the current rustc rejects when
the kernel's `CONFIG_RUSTC_VERSION` is 0. The C-only module is an upstream
supported configuration and works with the current bcachefs on-disk format;
newer bcachefs releases are expected to require `CONFIG_RUST`.

On x86_64, the installation images also include the halcyon-core
`broadcom-wl` driver and its prebuilt kernel module. This is the proprietary
Broadcom STA driver for older Broadcom PCIe Wi-Fi chips. Its package installs
a modprobe blacklist for the in-tree `b43`, `bcma`, `brcmsmac`, and `brcmfmac`
drivers so the `wl` driver binds instead, and the live initramfs includes the
`wl` module so Wi-Fi works when booting from the ISO.

Note that this blacklist also disables `brcmfmac`, which is the correct driver
for newer Broadcom chips such as the BCM4377/4387 used in T2 Macs. The
proprietary `wl` driver only handles the older BCM43xx/47xx devices. If the
image is meant for a T2 Mac, the `brcmfmac` blacklist must be removed or made
conditional.

They are mainly intended for handling of distro releases, but can be
used by advanced users to create their own images. They are also useful
for creating images for specific devices that are supported but not
shipped with pre-generated releases.

The following low level scripts are provided:

* `mklive.sh` - the live ISO image creator for BIOS, EFI and POWER/PowerPC systems
* `mkrootfs.sh` - root filesystem tarball creator
* `mkpart.sh` - device partitioning tool
* `unrootfs.sh` - rootfs tarball extractor
* `mkimage.sh` - device image creator

Low level scripts are mostly not intended for direct usage (except for device
images), and anyone using them is expected to be familiar with the details.

The following high level scripts are available:

* `mklive-image.sh` - wrapper around `mklive.sh` to create standardized images
* `mkrootfs-platform.sh` - wrapper around `mkrootfs.sh` to create standardized
  rootfs tarballs

More tools may be added over time.

## Building the Halcyon installation ISO

`build-halcyon-iso.sh` builds the bcachefs packages (and, on x86_64, the
Broadcom-wl packages) from the sibling `cports` checkout and then creates the
installation ISO. It must be run as a regular user; it uses docker or podman
for the root-only parts of `mklive.sh`.

The following prerequisites must be available:

* a `cports` checkout containing `halcyon-core`, by default `../cports`
  (override with `HALCYON_CPORTS`)
* a cbuild container for that checkout, by default `bldroot-halcyon`
  (override with `HALCYON_BLDROOT`); the script bootstraps it if necessary
* docker or podman

Then run:

```
$ ./build-halcyon-iso.sh
```

The resulting image is
`halcyon-linux-x86_64-LIVE-YYYYMMDD-plasma.iso` by default. Use
`HALCYON_ARCH`, `HALCYON_IMAGE` (`base`, `gnome` or `plasma`) and
`HALCYON_ISO` to change the architecture, image type or output path.

`cbuild` is incremental, so re-running the script reuses already built
packages. To assemble an ISO manually, run the following as root (the
`halcyon-core` repository must already contain the bcachefs packages, and
`keys` must contain the matching public key):

```
# ./mklive-image.sh -b plasma -- \
    -r /path/to/cports/packages/halcyon-core \
    -r https://repo.chimera-linux.org/current/main \
    -r https://repo.chimera-linux.org/current/user \
    -k keys -o halcyon-linux-x86_64-LIVE-$(date '+%Y%m%d')-plasma.iso
```

## Bootstrapping the system with apk

In order to bootstrap the system into a directory (e.g. a partitioned and
mounted root file system), you can use just plain `apk`. The tooling here
is generally written around similar methods.

You can get prebuilt `apk` [here](https://repo.chimera-linux.org/apk).

First, bootstrap your root with a package that is safe to install without
pseudo-filesystems mounted in the target. That means `chimerautils`,
as every base metapackage installs stuff that needs scripts.

It is important to use `--initdb`, and it is also very important to have
**at least apk-tools 3aa99faa83d08e45eff8a5cc95c4df16fb5bd257**, as older
versions will mess up permissions on the initial files.

```
# apk add --root /my/root --keys-dir /my/cports/etc/keys --repository /my/cports/packages/main --initdb chimerautils
```

More advanced base metapackages may require pseudo-filesystems in their hooks.
If you want to install them, proceed like this:

```
# mount -t proc none /my/root/proc
# mount -t sysfs none /my/root/sys
# mount -t devtmpfs none /my/root/dev
# mount --bind /tmp /my/root/tmp
```

Now is a good time to copy your public key in for `apk` so you do not have to pass it.

```
# mkdir -p /my/root/etc/apk/keys
# cp /my/cports/etc/keys/*.pub /my/root/etc/apk/keys
```

Then you can install e.g. `base-full` if you wish.

```
# apk --root /my/root --repository /my/cports/packages/main add base-full
```

Once you are done, don't forget to clean up.

```
# umount /my/root/tmp
# umount /my/root/dev
# umount /my/root/sys
# umount /my/root/proc
# rm -rf /my/root/run /my/root/var/tmp /my/root/var/cache
# mkdir -p /my/root/run /my/root/var/tmp /my/root/var/cache
# chmod 777 /my/root/var/tmp
```

That's basically all. You can install whatever else you want, of course.

## Creating live images with mklive-image.sh and mklive.sh

The `mklive-image.sh` script is a high level wrapper around `mklive.sh`.

Its basic usage is like this (as root):

```
# ./mklive-image.sh -b base
```

It only takes two optional arguments, `-b IMAGE` and `-p EXTRA_PACKAGES`.
The `IMAGE` is the supported image type (currently `base` for base console-only
images and `gnome` for graphical GNOME images). The other argument lets you
install packages in addition to the set provided by `IMAGE`.

You can also pass-through additional arguments to `mklive.sh` by specifying
them after `--`, e.g. `./mklive-image.sh -b base -- -f myflavor ...`.

It is also possible to use `mklive.sh` raw. You can get the full listing of
supported arguments like this:

```
# ./mklive.sh -h
```

Invoking `mklive.sh` with no arguments will generate a basic ISO for the
current architecture, using remote repositories. The `base-full` metapackage
serves as the base package. Note that this is not equivalent to the `base` image
of `mklive-image.sh`, as that contains some additional packages.

You can specify arguments to do things such as using your own repos with your own
signing key, additional packages and so on.

## Creating rootfs tarballs with mkrootfs-platform.sh and mkrootfs.sh

The `mkrootfs-platform.sh` script is a high level wrapper around `mkrootfs.sh`.

Its basic usage is like this (as root):

```
# ./mkrootfs-platform.sh -P rpi
```

It only takes two optional arguments, `-P PLATFORM` and `-p EXTRA_PACKAGES`.
The `PLATFORM` is the supported platform type (represented by `full` which is
the `mkrootfs.sh` default of using `base-full` and then device-specific platform
images such as `rpi` and `pbp`).

The `mkrootfs.sh` script takes largely identical arguments to `mklive.sh` (see `-h`)
but instead of ISO images, it creates root file system tarballs. Running it without
arguments will create a basic root file system tarball using remote repositories.
The `base-full` metapackage is the default, but you can override it.

The `mkrootfs.sh` is also capable of creating delta tarballs. The invocation
only differs in that you pass a base tarball (previously created with the same
tool) via `-B some-base.tar.gz`. The new tarball will then only contain newly
added or changed files, creating a tarball that can be extracted over the
base tarball to get the whole thing.

## Setting up specific devices

The `mkpart.sh` and `unrootfs.sh` scripts allow you to prepare e.g. SD cards
of various devices from their rootfs tarballs.

For example, if you have an SD card at `/dev/mmcblk0` and want to install
Chimera for Pinebook Pro on it, you would do something like this:

```
# mkdir -p rootmnt
# ./mkpart.sh -j /dev/mmcblk0 pbp rootmnt
```

This will partition the SD card for the device. Generally for a device to
be supported here, it needs to have a disk layout file, in the `sfdisk`
directory. You can tweak various parameters via options (see `-h`). You
can of course also partition and mount the card manually.

Once that is done, you can perform the installation from the tarball:

```
# ./unrootfs.sh chimera-linux-aarch64-ROOTFS-...-pbp.tar.gz rootmnt /dev/mmcblk0
```

Multiple tarballs can be specified as a single argument, separated by
semicolons. They are extracted in that order. That means if you are using
delta tarballs, you should specify the base first and the overlay second,
like `base-tarball.tar.gz;delta-tarball.tar.gz`.

This will both install the system onto the card and install U-Boot onto the
card (as it's given as the last argument). If you omit the last argument,
no bootloader installation will be done.

After that, you can just unmount the directory and eject the card:

```
# umount -R rootmnt
# sync
```

If you want to create an image instead of setting up a physical storage device,
you can do so thanks to loop devices. First, create storage for the image,
in this example 8G:

```
# truncate -s 8G chimera.img
```

Then attach it with `losetup` and let it show which loop device is used:

```
# losetup --show -fP chimera.img
```

That will print for example `/dev/loop0`. Now all you have to do is pass that
path in place of the device path, e.g. `/dev/loop0` instead of `/dev/mmcblk0`.

Once you are done and have unmounted everything, detach it:

```
# losetup -d /dev/loop0
```

And that's about it.

## Creating device images with mkimage.sh

The `mkimage.sh` script simplifies creation of device images so that you do
not have to manipulate loop devices manually. However, it comes at the cost
of being far less flexible.

It accepts a prepared device rootfs tarball as its file name, or multiple
tarballs when using deltas. Optional arguments can be used to set the output
file name and the image size (by default 2G). It will also automatically
compress the image with `gzip`.

```
# ./mkimage.sh chimera-linux-aarch64-ROOTFS-20220906-rpi.tar.gz -- -j
```

The platform name, architecture and everything else is detected from the
input filename. Additional arguments passed after `--` will be passed as
optional arguments to `mkpart.sh`. In the example above, `-j` is passed
to disable journal for root filesystem.
