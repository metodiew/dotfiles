#!/bin/bash

# Author: Stanko Metodiev
# Author Email: stanko@metodiew.com
# Author URL: https://metodiew.com
# Description: This is a script for taking a screenshot of my Desktop and move it to the backup files

# Make sure you have this one instaled:
# sudo apt install graphicsmagick-imagemagick-compat

# Get the variables from the separate file
. ./metodiew-laptop-backup-variables.sh;

echo "Taking a Desktop screenshot";
sleep 2;

if ! command -v gnome-screenshot >/dev/null 2>&1; then
	echo "gnome-screenshot is not installed, skipping desktop screenshot.";
	exit 0;
fi

mkdir -p "$BACKUPFOLDERROOT/Desktop Screenshots/"

SCREENSHOT_FILE="desktop-screenshot-$NOWTIMEDATE.png"
SCREENSHOT_TMP_PATH="/tmp/$SCREENSHOT_FILE"
SCREENSHOT_FINAL_PATH="$BACKUPFOLDERROOT/Desktop Screenshots/$SCREENSHOT_FILE"

if [ -n "$SUDO_USER" ]; then
	USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
	sudo -E -u "$SUDO_USER" HOME="$USER_HOME" gnome-screenshot -f "$SCREENSHOT_TMP_PATH"
else
	gnome-screenshot -f "$SCREENSHOT_TMP_PATH"
fi

if [ ! -f "$SCREENSHOT_TMP_PATH" ]; then
	echo "Desktop screenshot failed, skipping.";
	exit 0;
fi

mv "$SCREENSHOT_TMP_PATH" "$SCREENSHOT_FINAL_PATH"

echo 'Desktop Screenshot is ready.';
notify-send 'Desktop Screenshot is ready.' >/dev/null 2>&1 || true;

sleep 2;