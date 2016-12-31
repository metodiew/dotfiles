#!/bin/bash

# The script is using for creating separate files for each database files, using mysqldump
# This version is inspired from http://stackoverflow.com/questions/9497869/export-and-import-all-mysql-databases-at-one-time and slighly modified to meet my need

USER="root"
PASSWORD=" " # Enter your MySQL password here

databases=`mysql -u $USER -p$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
        echo "Dumping database: $db"
        mysqldump -u $USER  --databases $db > $db-`date +%Y%m%d`.sql
    fi
done
