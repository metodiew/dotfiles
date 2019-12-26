#!/bin/bash

#
# Author: Stanko Metodiev
# Author Email: stanko@metodiew.com
# Author URL: https://metodiew.com
# Last Updated: 2019.12.26
# Description: This is a script for backup of all Apache MySQL database from my localhost machine.

# Get the variables from the separate file
. ./metodiew-laptop-backup-variables.sh;

###########################################
#### Let's start with the MySQL backup ####
###########################################

# We need to start the Apache server, just in case.
sudo service apache2 start;

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

# We need to stop Apache server after the script. Just in case.
sudo service apache2 stop;