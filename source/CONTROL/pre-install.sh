#!/bin/sh

if [ -z "$APKG_PKG_DIR" ]; then
	PKG_DIR=/usr/local/AppCentral/rtorrent
else
	PKG_DIR=$APKG_PKG_DIR
fi

# shellcheck source=/Users/mafredri/Projects/rtorrent-apkg/source/CONTROL/env.sh
. ${PKG_DIR}/CONTROL/env.sh

case "${APKG_PKG_STATUS}" in
	install)
		;;
	upgrade)
		mkdir -p "${APKG_TEMP_DIR}/config"
		rsync -a "${CONFIG}/" "${APKG_TEMP_DIR}/config/"
		;;
	*)
		;;
esac
