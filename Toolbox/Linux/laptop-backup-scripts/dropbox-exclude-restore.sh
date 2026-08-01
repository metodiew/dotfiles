#!/bin/bash
#
# dropbox-exclude-restore.sh
# Re-apply Dropbox Selective Sync exclusions (the "no-sync" folders) after a reinstall.
#
# Run this RIGHT AFTER logging into Dropbox and BEFORE it syncs everything down, so the
# excluded folders are never downloaded to the laptop. Reads the list captured by the
# weekly backup (metodiew-laptop-backup.sh) at:
#   ~/Dropbox/Backup Files/Config Files/dropbox-exclude-list.txt
# That file must have synced first (Config Files is small / first in Selective Sync priority).
#
# Usage: dropbox-exclude-restore.sh [path-to-exclude-list]
#
# Author: Stanko Metodiev

set -uo pipefail

LIST="${1:-$HOME/Dropbox/Backup Files/Config Files/dropbox-exclude-list.txt}"

if ! command -v dropbox >/dev/null 2>&1; then
	echo "Dropbox CLI not found. Install and log into Dropbox first."; exit 1
fi
if [ ! -f "$LIST" ]; then
	echo "Exclude list not found: $LIST"
	echo "Wait for Backup Files/Config Files to sync, or pass the list path as an argument."
	exit 1
fi

while IFS= read -r p; do
	[ -z "$p" ] && continue
	echo "excluding: $p"
	dropbox exclude add "$p" || echo "  (could not exclude yet: $p)"
done < "$LIST"

echo
echo "Done. Current exclusions:"
dropbox exclude list
