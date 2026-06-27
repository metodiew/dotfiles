#!/bin/bash

# Author: Stanko Metodiev
# Author Email: stanko@metodiew.com
# Author URL: https://metodiew.com
# Description: This is a script for a backup of all important files of my computer. A note, the script is designed to work with my Linux machine. However, most of the important files. Feel free to re-use and adjust the script for your own use :)

# Ask to run the script with sudo
if ! [ $(id -u) = 0 ]; then
   echo "The script require sudo, let's try again :)";
   exit 1;
fi

# Always resolve child scripts from this script's directory.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -n "$SUDO_USER" ]; then
	USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
	USER_HOME="$HOME"
fi

# Get the variables from the separate file
. "$SCRIPT_DIR/metodiew-laptop-backup-variables.sh";

# Let's start with the backup procedure
echo 'Starting with backup important files ...';
sleep 2;

# Desktop screenshot
bash "$SCRIPT_DIR/desktop-screenshot.sh";


GUAKE_PREFS_TMP="/tmp/guake-preferences-$NOW"
GUAKE_PREFS_FINAL="$BACKUPFOLDERROOT/Config Files/guake-preferences"

if command -v guake >/dev/null 2>&1; then
	if [ -n "$SUDO_USER" ]; then
		sudo -E -u "$SUDO_USER" HOME="$USER_HOME" guake --save-preferences "$GUAKE_PREFS_TMP"
	else
		guake --save-preferences "$GUAKE_PREFS_TMP"
	fi

	if [ -s "$GUAKE_PREFS_TMP" ]; then
		mv "$GUAKE_PREFS_TMP" "$GUAKE_PREFS_FINAL"
		echo "Guake preferences are ready.";
	else
		rm -f "$GUAKE_PREFS_TMP"
		echo "Guake preferences export failed or empty, skipping.";
	fi
else
	echo "Guake is not installed, skipping preferences backup.";
fi

# Backup of the dotfiles
echo 'Starting with dotfiles ...';
sleep 2;

cp $USER_HOME/.bash_logout "$BACKUPFOLDERROOT/Config Files/";
cp $USER_HOME/.bash_profile "$BACKUPFOLDERROOT/Config Files/";
cp $USER_HOME/.bashrc "$BACKUPFOLDERROOT/Config Files/";
cp $USER_HOME/.dmrc "$BACKUPFOLDERROOT/Config Files/";
cp $USER_HOME/.git-commit-template.txt "$BACKUPFOLDERROOT/Config Files/";
cp $USER_HOME/.gitconfig "$BACKUPFOLDERROOT/Config Files/";
cp $USER_HOME/.profile "$BACKUPFOLDERROOT/Config Files/";
cp $USER_HOME/.vimrc "$BACKUPFOLDERROOT/Config Files/";
if [ -f $USER_HOME/.config/flameshot/flameshot.ini ]; then
	cp $USER_HOME/.config/flameshot/flameshot.ini "$BACKUPFOLDERROOT/Config Files/";
else
	echo "Flameshot config not found, skipping.";
fi
cp -r $USER_HOME/.scripts "$BACKUPFOLDERROOT/Config Files/";
cp -r $USER_HOME/.vim "$BACKUPFOLDERROOT/Config Files/";
cp -r $USER_HOME/.vscode "$BACKUPFOLDERROOT/Config Files/";

# VS Code extensions list
if command -v code >/dev/null 2>&1; then
	if [ -n "$SUDO_USER" ]; then
		sudo -E -u "$SUDO_USER" HOME="$USER_HOME" code --list-extensions > "$BACKUPFOLDERROOT/Config Files/vscode-extensions.txt" 2>/dev/null
	else
		code --list-extensions > "$BACKUPFOLDERROOT/Config Files/vscode-extensions.txt" 2>/dev/null
	fi
	echo "VS Code extensions list saved."
else
	echo "VS Code not installed, skipping extensions list."
fi

# Cursor backup
mkdir -p "$BACKUPFOLDERROOT/Config Files/Cursor"

if [ -f "$USER_HOME/.config/Cursor/User/settings.json" ]; then
	cp "$USER_HOME/.config/Cursor/User/settings.json" "$BACKUPFOLDERROOT/Config Files/Cursor/";
else
	echo "Cursor settings.json not found, skipping.";
fi

if [ -f "$USER_HOME/.config/Cursor/User/keybindings.json" ]; then
	cp "$USER_HOME/.config/Cursor/User/keybindings.json" "$BACKUPFOLDERROOT/Config Files/Cursor/";
else
	echo "Cursor keybindings.json not found, skipping.";
fi

# Cursor extensions list
if command -v cursor >/dev/null 2>&1; then
	if [ -n "$SUDO_USER" ]; then
		sudo -E -u "$SUDO_USER" HOME="$USER_HOME" cursor --list-extensions > "$BACKUPFOLDERROOT/Config Files/Cursor/cursor-extensions.txt" 2>/dev/null
	else
		cursor --list-extensions > "$BACKUPFOLDERROOT/Config Files/Cursor/cursor-extensions.txt" 2>/dev/null
	fi
	echo "Cursor extensions list saved."
else
	echo "Cursor not installed, skipping extensions list."
fi

if [ -d "$USER_HOME/.config/Cursor/User/snippets" ]; then
	cp -r "$USER_HOME/.config/Cursor/User/snippets" "$BACKUPFOLDERROOT/Config Files/Cursor/";
else
	echo "Cursor snippets not found, skipping.";
fi

if [ -d "$USER_HOME/.config/Cursor/User/History" ]; then
	cp -r "$USER_HOME/.config/Cursor/User/History" "$BACKUPFOLDERROOT/Config Files/Cursor/";
else
	echo "Cursor History not found, skipping.";
fi

# globalStorage: extension subfolders + storage.json; skip state.vscdb and state.vscdb.backup (~1.2GB of regenerable state)
if [ -d "$USER_HOME/.config/Cursor/User/globalStorage" ]; then
	mkdir -p "$BACKUPFOLDERROOT/Config Files/Cursor/globalStorage"
	[ -f "$USER_HOME/.config/Cursor/User/globalStorage/storage.json" ] && \
		cp "$USER_HOME/.config/Cursor/User/globalStorage/storage.json" "$BACKUPFOLDERROOT/Config Files/Cursor/globalStorage/"
	find "$USER_HOME/.config/Cursor/User/globalStorage" -maxdepth 1 -mindepth 1 -type d \
		-exec cp -r {} "$BACKUPFOLDERROOT/Config Files/Cursor/globalStorage/" \;
	echo "Cursor globalStorage backup ready."
else
	echo "Cursor globalStorage not found, skipping.";
fi


# SSH/FileZilla backup
zip -r "$BACKUPFOLDERROOT/Config Files/ssh folder/$NOW.zip" $USER_HOME/.ssh;
if [ -f $USER_HOME/.config/filezilla/sitemanager.xml ]; then
	cp -r $USER_HOME/.config/filezilla/sitemanager.xml "$BACKUPFOLDERROOT/FileZilla/";
elif [ -f $USER_HOME/.local/share/filezilla/sitemanager.xml ]; then
	cp -r $USER_HOME/.local/share/filezilla/sitemanager.xml "$BACKUPFOLDERROOT/FileZilla/";
else
	echo "FileZilla sitemanager.xml not found, skipping.";
fi

echo 'dotfiles backup is ready.';
sleep 2;

# Config Files Backup
echo 'Starting with Config directories ...';
sleep 1;

# Archive the hosts file
cp /etc/hosts "$BACKUPFOLDERROOT/Config Files/Hosts/hosts.$NOW";

# Archive and Backup the Apache Conf directory
sudo zip -r "$BACKUPFOLDERROOT/Config Files/Apache Conf/apache2-sites-available-$NOW.zip" /etc/apache2/sites-available;

# Fix the permissions
sudo chown metodiew:metodiew "$BACKUPFOLDERROOT/Config Files/Apache Conf/apache2-sites-available-$NOW.zip"

# Archive and Backup Config directory
sudo zip -r "$BACKUPFOLDERROOT/Config Files/Config Folder/autostart-$NOW.zip" $USER_HOME/.config/autostart;

# Fix the permissions
sudo chown metodiew:metodiew -R "$BACKUPFOLDERROOT/Config Files/"

# Archive and Backup System Connection directory

echo 'Config directories backup is ready.';
sleep 1;

# Claude settings backup
echo 'Starting with Claude settings backup ...';
if [ -f "$USER_HOME/.claude.json" ]; then
	cp "$USER_HOME/.claude.json" "$BACKUPFOLDERROOT/Config Files/claude.json"
	sudo chown metodiew:metodiew "$BACKUPFOLDERROOT/Config Files/claude.json"
	echo '.claude.json backup ready.'
else
	echo '.claude.json not found, skipping.'
fi
if [ -d "$USER_HOME/.claude" ]; then
	zip -r "$BACKUPFOLDERROOT/Config Files/claude-$NOW.zip" "$USER_HOME/.claude"
	sudo chown metodiew:metodiew "$BACKUPFOLDERROOT/Config Files/claude-$NOW.zip"
	echo 'Claude settings backup ready.'
else
	echo '.claude folder not found, skipping.'
fi

# Personal repos backup
echo 'Starting with personal repos backup ...';
mkdir -p "$BACKUPFOLDERROOT/Personal Repos"

# ~/me repo
if [ -d "$USER_HOME/me" ]; then
	zip -r "$BACKUPFOLDERROOT/Personal Repos/me-$NOW.zip" "$USER_HOME/me" -x '*/node_modules/*'
	sudo chown metodiew:metodiew "$BACKUPFOLDERROOT/Personal Repos/me-$NOW.zip"
	echo 'me backup ready.'
else
	echo 'me folder not found, skipping.'
fi

# Control Room
if [ -d "$USER_HOME/Software/control-room" ]; then
	zip -r "$BACKUPFOLDERROOT/Personal Repos/control-room-$NOW.zip" "$USER_HOME/Software/control-room" -x '*/node_modules/*'
	sudo chown metodiew:metodiew "$BACKUPFOLDERROOT/Personal Repos/control-room-$NOW.zip"
	echo 'control-room backup ready.'
else
	echo 'control-room folder not found, skipping.'
fi

echo 'Personal repos backup ready.';
sleep 1;

# Run the combined Apache projects + MySQL backup script
bash "$SCRIPT_DIR/www-apache-projects-and-mysql-backup.sh";

# That's it :)
echo "That's all folks, we are ready :)";
if command -v notify-send >/dev/null 2>&1; then
	if [ -n "$SUDO_USER" ]; then
		sudo -E -u "$SUDO_USER" HOME="$USER_HOME" notify-send "That's all folks, we are ready :)" >/dev/null 2>&1 || true;
	else
		notify-send "That's all folks, we are ready :)" >/dev/null 2>&1 || true;
	fi
fi
