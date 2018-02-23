#!/bin/sh
# TODO: Implement a list of devices mounted by mt using stack (maybe?)

# Program Name
PROGNAME="$(basename $0)"
FG='tput setaf'
GR="$($FG 2)"
RD="$($FG 1)"
RS="$(tput sgr0)"

usage() {
	printf "%s\n" "
${GR}${PROGNAME}${RS} - A tiny wrapper around udisks2/udisksctl to mount/unmount block devices

Usage: ${GR}${PROGNAME}${RS} <device>

${GR}${PROGNAME}${RS} accepts multiple block devices as arguments for mounting/unmounting
If the device is already mounted then it will be unmounted immediately

Examples:
    Single block device
        ${GR}${PROGNAME}${RS} /dev/sda1
    Multiple block device
        ${GR}${PROGNAME}${RS} /dev/sd{a,b,c}1
        ${GR}${PROGNAME}${RS} /dev/sdb[1-5]
"
}

[ $# -lt 1 ] && {
	printf "${RD}Error${RS}: %s\n" 'No arguments provided'
	usage && exit 1
}

_mount() {
	udisksctl mount -b $1
}

_umount() {
	udisksctl unmount -b $1
}

_runcmd() {
	ARG="$1"

	[ ! -b "$ARG" ] && {
	printf "${RD}Error:${RS} %s\n" "${ARG}: is an invalid device"
	exit 1
	}

	if mount | grep -q "$ARG"; then
		_umount "$ARG"
	else
		_mount  "$ARG"
	fi
}

for DEVICE in $@; do
	_runcmd $DEVICE
done

exit $?
# vim: set ft=sh noet:
