#!/bin/bash

# @Author Stanko Metodiev <stanko@metodiew.com>

# Creating a separate zip archive for each directory from VVV Localhost server, in my case /home/metodiew/vagrant-local/www/ :)
# I'm storing the backups to my HDD, from where I'm copying them to an external drive, but you can skip
# the `mv` part

# Do we need to explain this one?
NOW="`date +%Y%m%d`";

for dir in `find . -maxdepth 1 -type d  | grep -v "^\.$" `;
	do
		# Create the archive
		echo 'Starting with' ${dir//.\/}'-'$NOW'.zip archive ...';
		sleep 5;
		zip -r ${dir}-$NOW.zip ${dir};

		# Move the created archive to a specific directory
		# Most likely in your case this will be different
		echo 'Moving' ${dir//.\/}'-'$NOW'.zip archive ...';
		mv ${dir}-$NOW.zip '/mnt/5DB56B841BB28CF1/Backup Files/WWW Backup/VVV/www-directory-backup-latest/';

		echo 'Ready with' ${dir//.\/}'-'$NOW'.zip archive ...';
		sleep 5;
done
