#!/bin/bash

# Author: Stanko Metodiev
# Author Email: stanko@metodiew.com
# Author URL: https://metodiew.com
# Description: Prepare an archive file for each html Apache directory.

# Get the variables from the separate file
. ./metodiew-laptop-backup-variables.sh;

echo "We are starting with the Apache Folder backup script";
sleep 2;

mkdir "$BACKUPFOLDERROOT/WWW Backup/Apache/www-directory-backup/"$NOW;
cd $APACHEFOLDER;

for dir in `find . -maxdepth 1 -mindepth 1 -type d | sort; exec basename {} \;`;
	do
		# Create the archive
		echo 'Starting with ' $dir'-'$NOW '.zip archive.';

		sleep 2;
		#zip -r ${dir}-$NOW.zip ${dir} -x '*/node_modules/*' -x '*.git*'; # leaving for the history
		zip -r ${dir}-$NOW.zip ${dir} -x '*/node_modules/*';

		# Fix the permissions
		sudo chown metodiew:metodiew ${dir}-$NOW.zip

		# Move the created archive to a specific directory
		echo 'Moving' $dir'-'$NOW '.zip archive ...';
		mv ${dir}-$NOW.zip "$BACKUPFOLDERROOT/WWW Backup/Apache/www-directory-backup/"$NOW;

		# Fix the permissions
		sudo chown metodiew:metodiew "$BACKUPFOLDERROOT/WWW Backup/Apache/www-directory-backup/"$NOW

		#echo 'Ready with' ${dir//.\/}'-'$NOW'.zip archive ...';
		echo 'Ready with ' $dir'-'$NOW '.zip archive.';

		sleep 2;
done

# It's important to return to the backup folder, so we can continue with the rest of the backup
cd "$BACKUPFOLDERROOT/";

echo "We are ready with the Apache Folder backup script";
notify-send "We are ready with the Apache Folder backup script";

sleep 2;