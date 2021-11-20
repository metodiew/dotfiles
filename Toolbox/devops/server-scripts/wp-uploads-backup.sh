#!/bin/bash

# Create an archive file with the whole uploads directory

today="$(date +'%Y.%m.%d')"
directory="/var/www/html/wp-content/uploads/"


if [ -d "$directory" ]; then
  zip -r uploads-$today.zip $directory
  sshpass -p 'server-pass-here' scp uploads-$today.zip server-user-here@XX.XX.XX.XX:/home/user/backup/
fi
