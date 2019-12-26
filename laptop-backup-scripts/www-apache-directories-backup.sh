#!/bin/bash

#
# Author: Stanko Metodiev
# Author Email: stanko@metodiew.com
# Author URL: https://metodiew.com
# Last Updated: 2019.12.26
# Description: Prepare an archive file for each html Apache directory.

# Get the variables from the separate file
. ./metodiew-laptop-backup-variables.sh;

mkdir "$BACKUPFOLDERROOT/WWW Backup/Apache/www-directory-backup/"$NOW;
cd $APACHEFOLDER;
for dir in `find . -maxdepth 1 -type d  | grep -v "^\.$" `;
	do
		# Create the archive
		echo 'Starting with' ${dir//.\/}'-'$NOW'.zip archive ...';
		sleep 2;
		zip -r ${dir}-$NOW.zip ${dir};

		# Move the created archive to a specific directory
		echo 'Moving' ${dir//.\/}'-'$NOW'.zip archive ...';
		mv ${dir}-$NOW.zip "$BACKUPFOLDERROOT/WWW Backup/Apache/www-directory-backup/"$NOW;

		echo 'Ready with' ${dir//.\/}'-'$NOW'.zip archive ...';
		sleep 2;
done

# It's important to return to the backup folder, so we can continue with the rest of the backup
cd "$BACKUPFOLDERROOT/";
