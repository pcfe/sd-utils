#!/bin/bash

# adjusted by pcfe, 2014-01-03 to enable fuse-exfat use
#set -x

SDCARD=/dev/sdcard
DEF_UID=$(grep "^UID_MIN" /etc/login.defs | tr -s " " | cut -d " " -f2)
DEF_GID=$(grep "^GID_MIN" /etc/login.defs | tr -s " " | cut -d " " -f2)
DEVICEUSER=$(getent passwd $DEF_UID | sed 's/:.*//')
MNT=/run/user/$DEF_UID/media/sdcard
TYPE=$(blkid -o value -s TYPE /dev/mmcblk1p1)

if [ "$ACTION" = "add" ]; then
	if [ -b /dev/mmcblk1p1 ]; then
		ln -sf /dev/mmcblk1p1 $SDCARD
	elif [ -b /dev/mmcblk1 ]; then
		ln -sf /dev/mmcblk1 $SDCARD
	else
		exit $?
	fi        
	su $DEVICEUSER -c "mkdir -p $MNT"
	case "${TYPE}" in
		vfat|ntfs)
			mount $SDCARD $MNT -o uid=$DEF_UID,gid=$DEF_GID
			;;
		exfat)
			mount.exfat-fuse $SDCARD $MNT -o uid=$DEF_UID,gid=$DEF_GID
			;;
		*)
			mount $SDCARD $MNT
			chown $DEVICEUSER: $MNT
			;;
	esac
else
	umount $SDCARD

	if [ $? = 0 ]; then
		rm -f $SDCARD
	else
		umount -l $MNT
		rm -f $SDCARD
	fi
fi

