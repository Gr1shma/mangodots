#!/bin/sh
# install.sh — deploy the linuwu-sense state-restore module from dotfiles
# onto a live Void Linux system. Idempotent: safe to re-run after edits.
#
# Usage: sudo ./install.sh

set -eu

if [ "$(id -u)" -ne 0 ]; then
	echo "This script must be run as root (use sudo)." >&2
	exit 1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

echo "==> Installing restore-sense / save-sense to /usr/local/bin"
install -Dm755 "$SCRIPT_DIR/bin/restore-sense" /usr/local/bin/restore-sense
install -Dm755 "$SCRIPT_DIR/bin/save-sense"    /usr/local/bin/save-sense

echo "==> Installing runit service: linuwu-sense-restore"
mkdir -p /etc/sv/linuwu-sense-restore
install -m755 "$SCRIPT_DIR/sv/linuwu-sense-restore/run" /etc/sv/linuwu-sense-restore/run
ln -sfn /etc/sv/linuwu-sense-restore /etc/runit/runsvdir/default/linuwu-sense-restore

echo "==> Installing shutdown hook: save-sense.sh"
mkdir -p /etc/runit/shutdown.d
install -m755 "$SCRIPT_DIR/shutdown.d/save-sense.sh" /etc/runit/shutdown.d/save-sense.sh

echo "==> Creating state directory"
mkdir -p /var/lib/linuwu-sense

echo "==> Done."
echo "    Check service status with: sv status linuwu-sense-restore"
echo "    Run restore manually with: sudo restore-sense"
echo "    Run save manually with:    sudo save-sense"
