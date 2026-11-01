#!/bin/bash
#
# Copies the newest Samsung Health export into the Control Room Dropbox app folder, where the server
# imports daily totals. The server cannot see "Backup Files", only its own app folder, hence the copy.
# Copy, never move. A state file remembers the last name sent, so the same export goes over once.
set -uo pipefail
USER_NAME="${SUDO_USER:-$USER}"
USER_HOME=$(getent passwd "$USER_NAME" | cut -d: -f6)
SRC_DIR="$USER_HOME/Dropbox/Backup Files/Samsung Health Backup"
DEST="$USER_HOME/Dropbox/Apps/Control Room"
STATE="$USER_HOME/.local/state/cr-shealth-last"

# Only samsunghealth_*.zip: the folder also holds derived files like sh-min.zip that are newer.
latest=$(ls -1t "$SRC_DIR"/samsunghealth_*.zip 2>/dev/null | head -n 1)
[ -n "$latest" ] || { echo "Samsung Health handover: no export found, skipping."; exit 0; }
[ -d "$DEST" ] || { echo "Samsung Health handover: $DEST missing, skipping."; exit 0; }
name=$(basename "$latest")
if [ -f "$STATE" ] && [ "$(cat "$STATE")" = "$name" ]; then
	echo "Samsung Health handover: $name already sent, skipping."
	exit 0
fi

cp -p "$latest" "$DEST/" || { echo "Samsung Health handover: copy failed."; exit 1; }
mkdir -p "$(dirname "$STATE")"
echo "$name" > "$STATE"
[ -n "${SUDO_USER:-}" ] && chown "$SUDO_USER": "$DEST/$name" "$STATE" "$(dirname "$STATE")"
echo "Samsung Health handover: copied $name ($(date -r "$latest" '+%F %H:%M'))."
