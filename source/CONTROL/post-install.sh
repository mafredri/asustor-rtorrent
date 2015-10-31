#!/bin/sh

if [ -z "$APKG_PKG_DIR" ]; then
	PKG_DIR=/usr/local/AppCentral/rtorrent
else
	PKG_DIR=$APKG_PKG_DIR
fi

# shellcheck source=/Users/mafredri/Projects/rtorrent-apkg/source/CONTROL/env.sh
. ${PKG_DIR}/CONTROL/env.sh

# Set the NAS ARCH variable
ARCH=unknown
case "$(uname -m)" in
	x86_64) ARCH=x86-64;;
	arm*) ARCH=arm;;
	i*86) ARCH=i386;;
esac

if [ "$ARCH" = "unknown" ]; then
	exit 1
fi

link_arch() {
	# Link the directories for arch
	cd $PKG_DIR || exit 1
	for i in .arch/${ARCH}/*; do
		ln -sf "$i" .
	done
}

fix_permissions() {
	chown -R $USER:$GROUP $CONFIG
	chown -R $USER:$GROUP $TMPDIR
}

case "${APKG_PKG_STATUS}" in
	install)
		link_arch
		fix_permissions
		;;
	upgrade)
		link_arch
		rsync -a "${APKG_TEMP_DIR}/config/" "${CONFIG}/"
		fix_permissions
		;;
	*)
		;;
esac
