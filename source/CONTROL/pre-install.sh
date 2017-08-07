#!/bin/sh

if [ -z "$APKG_PKG_DIR" ]; then
	PKG_DIR=/usr/local/AppCentral/rtorrent
else
	PKG_DIR=$APKG_PKG_DIR
fi

case "${APKG_PKG_STATUS}" in
	install)
		;;
	upgrade)
		. ${PKG_DIR}/CONTROL/env.sh

		mkdir -p "${APKG_TEMP_DIR}/config"
		rsync -a "${CONFIG}/" "${APKG_TEMP_DIR}/config/"
		;;
	*)
		;;
esac
