#!/bin/sh

PACKAGE=rtorrent
PKG_DIR=/usr/local/AppCentral/${PACKAGE}

export USER=admin
export GROUP=administrators
export CONFIG=${PKG_DIR}/config
export TMPDIR=${PKG_DIR}/tmp
export SOCKET=${TMPDIR}/rtorrent.dtach

export PATH=${PKG_DIR}/bin:$PATH
export PATH=${PKG_DIR}/usr/bin:$PATH
export LD_LIBRARY_PATH=${PKG_DIR}/lib:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${PKG_DIR}/usr/lib:${LD_LIBRARY_PATH}
