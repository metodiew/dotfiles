#!/bin/bash
#
# Script Name: mysql-databases-backup.sh
#
# Author: Stanko Metodiev
# Author Email: stanko@metodiew.com
# Author URL: https://metodiew.com
# Lst Updated : 2019.12.26
# Description: This is a script for backup of all Apache MySQL database from my localhost machine.

# Set the Backup directory
BACKUPFOLDERROOT='/media/metodiew/metodiew HDD/Backup Files';

# Get the today's date
NOW="`date +%Y%m%d`";

# MySQL detailes here
USER="root"
PASSWORD="root" # Enter your MySQL password here

###########################################
#### Let's start with the MySQL backup ####
###########################################

# Create a new folder
mkdir $NOW;

databases=`mysql -u $USER -p$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
        echo "Dumping database: $db"
	# Backup each database to the new created folder
        mysqldump -u $USER -p$PASSWORD $db > $NOW/$NOW.$db.sql
    fi
done

# Archive the new created folder with all dumped databases. Then create an archive and delete the folder.
zip -r $NOW.zip $NOW;
mv $NOW.zip "$BACKUPFOLDERROOT/WWW Backup/Apache/SQLs";
rm -r $NOW;
