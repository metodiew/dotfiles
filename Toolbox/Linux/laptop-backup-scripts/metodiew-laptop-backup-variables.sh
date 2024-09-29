#!/bin/bash

#
# Author: Stanko Metodiev
# Author Email: stanko@metodiew.com
# Author URL: https://metodiew.com
# Description: this is a script file with all needed variables I'll use for the backup scripts

### Notes
# We need to use . instead of source for Ubuntu. e.g.:
# . ./metodiew-laptop-backup-variables.sh;
# See more details here https://askubuntu.com/a/1190252/225076

# Get the today's date
NOW="`date +%Y%m%d`";
NOWTIMEDATE="`date +%Y%m%d-%H:%M`";

# Set the Backup directory. Probably the most important variable :)
BACKUPFOLDERROOT='/home/metodiew/Dropbox/Backup Files';

# MySQL detailes here
USER="root";
PASSWORD="root";

# Apache folder
APACHEFOLDER='/var/www/html';