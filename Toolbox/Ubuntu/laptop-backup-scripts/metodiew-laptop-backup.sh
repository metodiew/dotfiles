#!/bin/bash

# Author: Stanko Metodiev
# Author Email: stanko@metodiew.com
# Author URL: https://metodiew.com
# Description: This is a script for a backup of all important files of my computer. A note, the script is designed to work with my Linux machine. However, most of the important files. Feel free to re-use and adjust the script for your own use :)

# Ask to run the script with sudo
if ! [ $(id -u) = 0 ]; then
   echo "The script require sudo, let's try again :)";
   exit 1;
fi

# Get the variables from the separate file
. ./metodiew-laptop-backup-variables.sh;

# Let's start with the backup procedure
echo 'Starting with backup important files ...';
sleep 2;

# Desktop screenshot
. ./desktop-screenshot.sh;

dconf dump /apps/guake/ > "$BACKUPFOLDERROOT/Config Files/guake-preferences";
echo "Guake preferences are ready.";

# Backup of the dotfiles
echo 'Starting with dotfiles ...';
sleep 2;

cp /home/metodiew/.bash_logout "$BACKUPFOLDERROOT/Config Files/";
cp /home/metodiew/.bash_profile "$BACKUPFOLDERROOT/Config Files/";
cp /home/metodiew/.bashrc "$BACKUPFOLDERROOT/Config Files/";
cp /home/metodiew/.dmrc "$BACKUPFOLDERROOT/Config Files/";
cp /home/metodiew/.git-commit-template.txt "$BACKUPFOLDERROOT/Config Files/";
cp /home/metodiew/.gitconfig "$BACKUPFOLDERROOT/Config Files/";
cp /home/metodiew/.profile "$BACKUPFOLDERROOT/Config Files/";
cp /home/metodiew/.vimrc "$BACKUPFOLDERROOT/Config Files/";
cp -r /home/metodiew/.scripts "$BACKUPFOLDERROOT/Config Files/";
cp -r /home/metodiew/.vim "$BACKUPFOLDERROOT/Config Files/";
cp -r /home/metodiew/.vscode "$BACKUPFOLDERROOT/Config Files/";

# SSH/FileZilla backup
zip -r "$BACKUPFOLDERROOT/Config Files/ssh folder/$NOW.zip" /home/metodiew/.ssh;
cp -r /home/metodiew/.config/filezilla/sitemanager.xml "$BACKUPFOLDERROOT/FileZilla/"

echo 'dotfiles backup is ready.';
sleep 2;

# Config Files Backup
echo 'Starting with Config directories ...';
sleep 1;

# Archive the hosts file
cp /etc/hosts "$BACKUPFOLDERROOT/Config Files/Hosts/hosts.$NOW";

# Archive and Backup the Apache Conf directory
sudo zip -r "$BACKUPFOLDERROOT/Config Files/Apache Conf/apache2-$NOW.zip" /etc/apache2;
sudo zip -r "$BACKUPFOLDERROOT/Config Files/Apache Conf/apache2-sites-enabled-$NOW.zip" /etc/apache2/sites-enabled;
sudo zip -r "$BACKUPFOLDERROOT/Config Files/Apache Conf/apache2-sites-available-$NOW.zip" /etc/apache2/sites-available;

# Fix the permissions
sudo chown metodiew:metodiew "$BACKUPFOLDERROOT/Config Files/Apache Conf/apache2-$NOW.zip"

# Archive and Backup Config directory
sudo zip -r "$BACKUPFOLDERROOT/Config Files/Config Folder/autostart-$NOW.zip" /home/metodiew/.config/autostart;

# Fix the permissions
sudo chown metodiew:metodiew -R "$BACKUPFOLDERROOT/Config Files/"

# Archive and Backup System Connection directory

echo 'Config directories backup is ready.';
sleep 1;

# Run the MySQL backup script
./mysql-databases-backup.sh;

# Run the Archive and Backup WWW Backup directory script
./www-apache-directories-backup.sh;

# That's it :)
echo "That's all folks, we are ready :)";