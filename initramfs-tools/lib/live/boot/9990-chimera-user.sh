# this sets up the user in the live environment
#
# a part of chimera linux, license: BSD-2-Clause

Chimera_Service() {
    if [ -f /root/etc/dinit.d/$1 -o -f /root/usr/lib/dinit.d/$1 ]; then
        ln -sf ../$1 /root/etc/dinit.d/boot.d/$1
    fi
}

Chimera_User() {
    log_begin_msg "Setting up user"

    USERNAME="anon"
    USERPASS="chimera"
    # Keep /bin/sh (mksh) for the live user. The SDE Terminal filters the
    # environment it passes to the shell and drops ENV, so use a tiny live
    # wrapper that sets ENV=/etc/mkshrc and then execs /bin/sh. The mkshrc is
    # installed by uutils-coreutils and sources its PATH overlay.
    if [ -x /root/usr/local/bin/live-sh ]; then
        USERSHELL="/usr/local/bin/live-sh"
    elif [ -x /root/bin/sh ]; then
        USERSHELL="/bin/sh"
    elif [ -x /root/usr/bin/mksh ]; then
        USERSHELL="/usr/bin/mksh"
    else
        USERSHELL="/bin/sh"
    fi

    for _PARAMETER in ${LIVE_BOOT_CMDLINE}; do
        case "${_PARAMETER}" in
            live-user=*)
                USERNAME="${_PARAMETER#live-user=}"
                ;;
            live-password=*)
                USERPASS="${_PARAMETER#live-password=}"
                ;;
            live-shell=*)
                USERSHELL="${_PARAMETER#live-shell=}"
                ;;
        esac
    done

    # hostname; prevent syslog from doing dns lookup
    echo "127.0.0.1 $(cat /root/etc/hostname)" >> /root/etc/hosts
    echo "::1 $(cat /root/etc/hostname)" >> /root/etc/hosts

    # /etc/issue
    if [ -f "/lib/live/data/issue.in" ]; then
        sed \
            -e "s|@USER@|${USERNAME}|g" \
            -e "s|@PASSWORD@|${USERPASS}|g" \
            "/lib/live/data/issue.in" > /root/etc/issue
    fi

    chroot /root useradd -m -c "$USERNAME" -s "$USERSHELL" "$USERNAME"

    # Give the live user a dedicated group for live-only PolicyKit rules. The
    # group exists only in the live root, so a rule keyed on it cannot grant
    # passwordless pkexec on an installed system.
    if ! chroot /root getent group live > /dev/null 2>&1; then
        chroot /root groupadd live
    fi
    chroot /root usermod -aG live "$USERNAME"

    # SerenityOS applications expect the standard home directories. In
    # particular the FileManager's desktop lives in ~/Desktop; without it the
    # "Open in Terminal" action passes a non-existent working directory to
    # posix_spawn and fails with ENOENT.
    for _dir in Desktop Documents Downloads Music Pictures Videos Templates Public; do
        chroot /root mkdir -p "/home/${USERNAME}/${_dir}"
        chroot /root chown "${USERNAME}:${USERNAME}" "/home/${USERNAME}/${_dir}"
    done

    # The SDE file manager treats a non-executable .desktop file as text, so
    # put an executable launcher on the live desktop instead.
    _desktop="/home/${USERNAME}/Desktop"
    chroot /root rm -f "${_desktop}/HalcyonSetup.desktop"
    chroot /root sh -c "printf '%s\n' '#!/bin/sh' 'exec /usr/bin/halcyon-setup' > '${_desktop}/Install Halcyon Linux'"
    chroot /root chmod 755 "${_desktop}/Install Halcyon Linux"
    chroot /root chown "${USERNAME}:${USERNAME}" "${_desktop}/Install Halcyon Linux"

    chroot /root sh -c "echo 'root:${USERPASS}'|chpasswd -c SHA512"
    chroot /root sh -c "echo '$USERNAME:${USERPASS}'|chpasswd -c SHA512"

    # pam_env reads /etc/environment for the sddm session. mksh only reads an
    # rc file named by ENV; the live-sh wrapper sets it for the SDE Terminal,
    # and this keeps it set for login shells and other mksh sessions. The
    # /etc/mkshrc file is installed by uutils-coreutils.
    if [ -d /root/etc ] && ! grep -q '^ENV=' /root/etc/environment 2>/dev/null; then
        echo 'ENV=/etc/mkshrc' >> /root/etc/environment
    fi

    if [ -x /root/usr/bin/doas ]; then
        echo "permit persist $USERNAME" >> /root/etc/doas.conf
        chmod 600 /root/etc/doas.conf
    fi

    if [ -f /root/etc/sudoers ]; then
        echo "$USERNAME ALL=(ALL) ALL" >> /root/etc/sudoers
    fi

    # create boot.d as tmpfiles has not yet run
    chroot /root mkdir -p "/etc/dinit.d/boot.d"

    # enable default services
    Chimera_Service rtkit
    Chimera_Service polkitd
    Chimera_Service syslog-ng

    # use networkmanager if installed, e.g. for gnome integration
    if [ -f "/root/usr/lib/dinit.d/networkmanager" ]; then
        Chimera_Service networkmanager
    else
        Chimera_Service dhcpcd
    fi

    # handle explicitly given serial consoles, prefer this as we
    # don't need to guess stuff like parity information from stty
    #
    # also activate other services the user has explicitly requested
    for _PARAMETER in ${LIVE_BOOT_CMDLINE}; do
        case "${_PARAMETER}" in
            services=*)
                SERVICES="${_PARAMETER#services=}"
                OLDIFS=$IFS
                IFS=,
                for srv in ${SERVICES}; do
                    Chimera_Service "${srv}"
                done
                IFS=$OLDIFS
                unset OLDIFS
                ;;
        esac
    done

    log_end_msg
}
