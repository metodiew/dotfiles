#!/bin/bash
#
# Script Name: desktop-screenshot.sh
#
# Author: Stanko Metodiev
# Author Email: stanko@metodiew.com
# Author URL: https://metodiew.com
# Date : 2018.02.10
# Description: This is a script for taking a screenshot of my Desktop and move it to the backup files

# Set the Backup directory
BACKUPFOLDERROOT='/media/metodiew/metodiew HDD/Backup Files';

# Get the today's date
NOW="`date +%Y%m%d`";

# Take the screenshot
import -window root desktop-screenshot-$NOW.png

# Move the screenshot to Desktop Screenshots directory
mv desktop-screenshot-$NOW.png  "$BACKUPFOLDERROOT/Desktop Screenshots/";
