#!/bin/bash

#
# Author: Stanko Metodiev
# Author Email: stanko@metodiew.com
# Author URL: https://metodiew.com
# Last Updated: 2019.12.26
# Description: Creating a separate zip archive for each directory from VVV Localhost server, in my case /home/metodiew/vagrant-local/www/ :)
# I'm storing the backups to my HDD, from where I'm copying them to an external drive, but you can skip
# the `mv` part

# Get the variables from the separate file
. ./metodiew-laptop-backup-variables.sh;

for dir in `find . -maxdepth 1 -type d  | grep -v "^\.$" `;
	do
		# Create the archive
		echo 'Starting with' ${dir//.\/}'-'$NOW'.zip archive ...';
		sleep 5;
		zip -r ${dir}-$NOW.zip ${dir};

		# Move the created archive to a specific directory
		# Most likely in your case this will be different
		echo 'Moving' ${dir//.\/}'-'$NOW'.zip archive ...';
		mv ${dir}-$NOW.zip "$BACKUPFOLDERROOT/WWW Backup/VVV/www-directory-backup-latest/"$NOW;

		echo 'Ready with' ${dir//.\/}'-'$NOW'.zip archive ...';
		sleep 5;
done
