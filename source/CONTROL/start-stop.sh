#!/bin/sh

NAME=rTorrent
PACKAGE=rtorrent

if [ -z "${APKG_PKG_DIR}" ]; then
	PKG_DIR=/usr/local/AppCentral/${PACKAGE}
else
	PKG_DIR=$APKG_PKG_DIR
fi

# shellcheck source=/Users/mafredri/Projects/rtorrent-apkg/source/CONTROL/env.sh
. ${PKG_DIR}/CONTROL/env.sh

PIDFILE=/var/run/${PACKAGE}.pid
CHUID=${USER}:${GROUP}

start_daemon() {
	echo "Starting ${NAME}..."

	# Set umask to create files with world r/w
	umask 0

	env TERM="linux" \
		start-stop-daemon -S \
			--pidfile $PIDFILE \
			--chuid $CHUID \
			--user $USER \
			--exec dtach -- -n $SOCKET -e "^T" env HOME=$CONFIG rtorrent

	# Get the pid of the newest process matching rtorrent
	pgrep -n rtorrent >$PIDFILE
}

stop_daemon_with_signal() {
	start-stop-daemon -K --quiet --user $USER --pidfile $PIDFILE --signal "$1"
}

stop_daemon() {
	echo "Stopping ${NAME}..."

	stop_daemon_with_signal 2

	if ! wait_for_status 1 15; then
		echo "Taking too long, sending second interrupt..."
		stop_daemon_with_signal 2

		if ! wait_for_status 1 5; then
			echo "Took too long, sending kill signal..."
			stop_daemon_with_signal 9
		fi
	fi
}

daemon_status() {
	start-stop-daemon -K --quiet --test --user $USER --pidfile $PIDFILE
}

wait_for_status() {
	status=$1
	counter=$2
	while true; do
		daemon_status
		if [ $? -eq "${status}" ]; then
			return 0
		fi
		counter=$(( counter -= 1 ))
		if [ "${counter}" -gt 0 ]; then
			sleep 1
		else
			break
		fi
	done
	return 1
}

case $1 in
	start)
		if ! daemon_status; then
			start_daemon
		else
			echo "${NAME} is already running"
		fi
		;;
	stop)
		if daemon_status; then
			stop_daemon
		else
			echo "${NAME} is not running"
		fi
		;;
	restart)
		if daemon_status; then
			stop_daemon
		fi
		start_daemon
		;;
	status)
		if daemon_status; then
			echo "${NAME} is running"
			exit 0
		else
			echo "${NAME} is not running"
			exit 1
		fi
		;;
	*)
		echo "usage: $0 {start|stop|restart|status}"
		exit 1
		;;
esac

exit 0
