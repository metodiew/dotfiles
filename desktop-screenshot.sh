#!/bin/bash
#
# Script Name: desktop-screenshot.sh
#
# Author: Stanko Metodiev
# Author Email: stanko@metodiew.com
# Author URL: https://metodiew.com
# Date : 2018.01.20
# Description: This is a script for taking a screenshot of my Desktop and move it to the backup files

# Get the today's date
NOW="`date +%Y%m%d`";

# Set the Backup directory
BACKUPFOLDERROOT='/mnt/5DB56B841BB28CF1/Backup Files';

# Take the screenshot
import -window root desktop-screenshot-$NOW.png

# Move the screenshot to Desktop Screenshots directory
mv desktop-screenshot-$NOW.png  "$BACKUPFOLDERROOT/Desktop Screenshots/";
