#!/bin/bash

# @Author Stanko Metodiev <stanko@metodiew.com>

# Creating a separate zip archive for each directory from Localhost server, in my case /var/www/html/ :)
# I'm storing the backups to my HDD, from where I'm copying them to an external drive, but you can skip
# the `mv` part

# I'm not a bash expert, but with a good Googling skills and a lot of back and forth and testing, 
# this is the current result :)

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
		mv ${dir}-$NOW.zip '/mnt/5DB56B841BB28CF1/Backup Files/WWW Backup/www-directory-backup-latest/';

		echo 'Ready with' ${dir//.\/}'-'$NOW'.zip archive ...';
		sleep 5;
done
