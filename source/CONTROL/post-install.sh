#!/bin/sh

if [ -z "$APKG_PKG_DIR" ]; then
	PKG_DIR=/usr/local/AppCentral/rtorrent
else
	PKG_DIR=$APKG_PKG_DIR
fi

. ${PKG_DIR}/CONTROL/env.sh

fix_permissions() {
	chown -R $USER:$GROUP $CONFIG
	chown -R $USER:$GROUP $TMPDIR
}

case "${APKG_PKG_STATUS}" in
	install)
		fix_permissions
		;;
	upgrade)
		rsync -a "${APKG_TEMP_DIR}/config/" "${CONFIG}/"
		fix_permissions
		;;
	*)
		;;
esac
