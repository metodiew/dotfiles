#!/bin/bash
#
# Script Name: metodiew-laptop-backup.sh
#
# Author: Stanko Metodiev
# Author Email: stanko@metodiew.com
# Author URL: https://metodiew.com
# Date : 2018.02.10
# Description: This is a script for a backup of all important files of my computer. A note, the script is designed to work with my Linux machine. However, most of the important files. Feel free to re-use and adjust the script for your own use :)

# Get the today's date
NOW="`date +%Y%m%d`";

# Set the Backup directory
BACKUPFOLDERROOT='/media/metodiew/metodiew HDD/Backup Files';

# Ask to run the script with sudo
if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

# Let's start with the backup procedure
echo 'Starting with backup important files ...';
sleep 2;

# Desktop screenshot
echo "Taking a Desktop Screenshot."
echo "Show your Desktop."
sleep 3;
./desktop-screenshot.sh;
echo 'Desktop Screenshot is ready.';
sleep 2;

# Backup dotfiles
echo 'Starting with dotfiles ...';
sleep 2;

cp /home/metodiew/.bash_history "$BACKUPFOLDERROOT/Config Files/";
cp /home/metodiew/.bash_logout "$BACKUPFOLDERROOT/Config Files/";
cp /home/metodiew/.bash_profile "$BACKUPFOLDERROOT/Config Files/";
cp /home/metodiew/.bashrc "$BACKUPFOLDERROOT/Config Files/";
cp /home/metodiew/.dmrc "$BACKUPFOLDERROOT/Config Files/";
cp /home/metodiew/.gitconfig "$BACKUPFOLDERROOT/Config Files/";
cp /home/metodiew/.profile "$BACKUPFOLDERROOT/Config Files/";
cp /home/metodiew/.vimrc "$BACKUPFOLDERROOT/Config Files/";

cp -r /home/metodiew/.scripts "$BACKUPFOLDERROOT/Config Files/";
cp -r /home/metodiew/.vim "$BACKUPFOLDERROOT/Config Files/";

echo 'dotfiles backup is ready.';
sleep 2;

# Config Files Backup
echo 'Starting with Config directories ...';
sleep 1;

# Archive and Backup Apache Conf directory
sudo zip -r "$BACKUPFOLDERROOT/Config Files/Apache Conf/apache2-$NOW.zip" /etc/apache2;

# Archive and Backup Config directory
sudo zip -r "$BACKUPFOLDERROOT/Config Files/Config Folder/autostart-$NOW.zip" /home/metodiew/.config/autostart;
sudo zip -r "$BACKUPFOLDERROOT/Config Files/Config Folder/skypeforlinux-$NOW.zip" /home/metodiew/.config/skypeforlinux;

# Archive and Backup Hamster directory
# /home/metodiew/.local/share/hamster.db is backuped on my Dropbox account

# Archive and Backup hosts file
cp /etc/hosts "$BACKUPFOLDERROOT/Config Files/Hosts/hosts.$NOW";

# Archive and Backup .ssh directory
sudo zip -r "$BACKUPFOLDERROOT/Config Files/ssh folder/$NOW.zip" /home/metodiew/.ssh;

# Archive and Backup System Connection directory

echo 'Config directories backup is ready.';
sleep 1;

# We need to start the Apache server, just in case.
sudo service apache2 start;
./mysql-databases-backup.sh; # Run the MySQL script

# We need to stop Apache server after the script. Just in case.
sudo service apache2 stop;

# Archive and Backup WWW Backup directory
./www-apache-directories-backup.sh; # Run the script

# Archive and Backup Skype directories
# @TODO
