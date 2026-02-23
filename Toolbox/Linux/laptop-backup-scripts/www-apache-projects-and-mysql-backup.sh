#!/bin/bash

# Author: Stanko Metodiev
# Author Email: stanko@metodiew.com
# Author URL: https://metodiew.com
# Description: Backup Apache project folders and co-locate WordPress DB backups per project.

# Get the variables from the separate file
. ./metodiew-laptop-backup-variables.sh;

echo "We are starting with the Apache projects + MySQL backup script";
sleep 2;

PROJECT_BACKUP_DIR="$BACKUPFOLDERROOT/WWW Backup/Apache/www-directory-backup/$NOW"
SEPARATE_SQL_DIR="$BACKUPFOLDERROOT/WWW Backup/Apache/SQLs"

mkdir -p "$PROJECT_BACKUP_DIR"
mkdir -p "$SEPARATE_SQL_DIR"

cd "$APACHEFOLDER" || exit 1

projects_scanned=0
wp_projects_found=0
project_db_backups=0
separate_db_backups=0
failed_project_db_backups=0
failed_separate_db_backups=0

declare -a project_backed_up_dbs=()

for dir in `find . -maxdepth 1 -mindepth 1 -type d | sort`;
	do
		dir="${dir#./}"
		projects_scanned=$((projects_scanned + 1))

		echo 'Starting with ' $dir'-'$NOW '.zip archive.';
		sleep 2;

		zip -r ${dir}-$NOW.zip ${dir} -x '*/node_modules/*';

		# Fix the permissions
		sudo chown metodiew:metodiew ${dir}-$NOW.zip

		echo 'Moving' $dir'-'$NOW '.zip archive ...';
		mv ${dir}-$NOW.zip "$PROJECT_BACKUP_DIR";
		sudo chown metodiew:metodiew "$PROJECT_BACKUP_DIR";

		echo 'Ready with ' $dir'-'$NOW '.zip archive.';

		# If this is a WordPress project, backup the matching database in the same folder.
		if [ -f "${dir}/wp-config.php" ]; then
			wp_projects_found=$((wp_projects_found + 1))
			db_name=$(grep -E "define[[:space:]]*\([[:space:]]*['\"]DB_NAME['\"][[:space:]]*," "${dir}/wp-config.php" | sed -E "s/.*define[[:space:]]*\([[:space:]]*['\"]DB_NAME['\"][[:space:]]*,[[:space:]]*['\"]([^'\"]+)['\"].*/\1/" | head -n 1)

			if [ -n "$db_name" ]; then
				echo "Dumping WordPress database for ${dir}: ${db_name}"
				tmp_sql_file="${NOW}.${dir}.${db_name}.sql"
				tmp_zip_file="${dir}-${NOW}-db.zip"

				if mysqldump --skip-lock-tables -u $USER -p$PASSWORD "$db_name" > "$tmp_sql_file"; then
					zip -j "$tmp_zip_file" "$tmp_sql_file"
					sudo chown metodiew:metodiew "$tmp_zip_file"
					mv "$tmp_zip_file" "$PROJECT_BACKUP_DIR"
					rm "$tmp_sql_file"
					project_db_backups=$((project_db_backups + 1))
					project_backed_up_dbs+=("$db_name")
				else
					echo "Failed to dump WordPress DB: $db_name"
					rm -f "$tmp_sql_file"
					failed_project_db_backups=$((failed_project_db_backups + 1))
				fi
			else
				echo "Could not detect DB_NAME in ${dir}/wp-config.php"
			fi
		fi

		sleep 2;
done

# Backup all remaining non-system DBs separately (those not mapped to WP projects).
databases=`mysql -u $USER -p$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

for db in $databases; do
	if [ "$db" != "information_schema" ] && [ "$db" != "performance_schema" ] && [ "$db" != "mysql" ] && [ "$db" != _* ] && [ "$db" != "sys" ] ; then
		skip_db=0
		for wp_db in "${project_backed_up_dbs[@]}"; do
			if [ "$db" = "$wp_db" ]; then
				skip_db=1
				break
			fi
		done

		if [ "$skip_db" -eq 0 ]; then
			echo "Dumping separate database: $db"
			tmp_sql_file="${NOW}.${db}.sql"
			tmp_zip_file="${NOW}.${db}.zip"

			if mysqldump --skip-lock-tables -u $USER -p$PASSWORD "$db" > "$tmp_sql_file"; then
				zip -j "$tmp_zip_file" "$tmp_sql_file"
				sudo chown metodiew:metodiew "$tmp_zip_file"
				mv "$tmp_zip_file" "$SEPARATE_SQL_DIR"
				rm "$tmp_sql_file"
				separate_db_backups=$((separate_db_backups + 1))
			else
				echo "Failed to dump separate DB: $db"
				rm -f "$tmp_sql_file"
				failed_separate_db_backups=$((failed_separate_db_backups + 1))
			fi
		fi
	fi
done

# It's important to return to the backup folder, so we can continue with the rest of the backup
cd "$BACKUPFOLDERROOT/" || exit 1

echo "We are ready with the Apache projects + MySQL backup script";
echo "Projects scanned: $projects_scanned";
echo "WordPress projects found: $wp_projects_found";
echo "Project DB backups created: $project_db_backups";
echo "Separate DB backups created: $separate_db_backups";
echo "Failed project DB backups: $failed_project_db_backups";
echo "Failed separate DB backups: $failed_separate_db_backups";
notify-send "Apache projects + MySQL backup is ready";

sleep 2;
