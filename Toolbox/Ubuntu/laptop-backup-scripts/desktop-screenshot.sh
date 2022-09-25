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

# Take the screenshot
import -window root desktop-screenshot-$NOWTIMEDATE.png

# Fix the permissions
sudo chown metodiew:metodiew desktop-screenshot-$NOWTIMEDATE.png

# Move the screenshot to Desktop Screenshots directory
mv desktop-screenshot-$NOWTIMEDATE.png  "$BACKUPFOLDERROOT/Desktop Screenshots/";

echo 'Desktop Screenshot is ready.';
sleep 2;