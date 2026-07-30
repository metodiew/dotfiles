#!/bin/bash
#
# provision.sh — first-pass, idempotent laptop setup after a fresh Mint install.
# Companion to linux-setup-and-backup.md. Safe to re-run: each step checks before acting.
#
# PREREQ (manual, not scripted): Dropbox installed, logged in, and fully synced.
#   After login, set Dropbox > Preferences > Sync > Selective Sync to match the reference
#   screenshot in the backup: ~/Dropbox/Backup Files/dropbox-selective-sync-*.png
#   (use the most recent dated one). This decides which folders sync down before you rely on them.
# Everything below assumes ~/Dropbox is present and up to date.
#
# Author: Stanko Metodiev
# NOTE: first-pass scaffold — review every TODO before trusting it end to end.

set -euo pipefail

DOTFILES="$HOME/Software/dotfiles"
BACKUP="$HOME/Dropbox/Backup Files"

log() { printf '\n\033[1;32m==>\033[0m %s\n' "$*"; }

# --- 0. Sanity ---------------------------------------------------------------
[ -d "$HOME/Dropbox" ] || { echo "Dropbox not synced yet. Install + login first."; exit 1; }

# --- 1. Base packages --------------------------------------------------------
log "Base packages"
sudo apt update
sudo apt install -y openssh-server git curl zip unzip build-essential

# Replay the manually-installed package list (add this capture to the backup script:
#   apt-mark showmanual > "$BACKUP/Config Files/pkglist.txt")
PKGLIST="$BACKUP/Config Files/pkglist.txt"
if [ -f "$PKGLIST" ]; then
  log "Restoring apt packages from pkglist.txt"
  sudo apt install -y $(cat "$PKGLIST") || true   # TODO: prune one-off / GUI-only entries
fi

# --- 2. Dotfiles -------------------------------------------------------------
log "Dotfiles"
[ -d "$DOTFILES" ] || git clone git@github.com:metodiew/dotfiles.git "$DOTFILES"
for f in .bash_logout .bash_profile .bashrc .gitconfig .profile .vimrc; do
  [ -f "$DOTFILES/$f" ] && cp "$DOTFILES/$f" "$HOME/"
done
[ -d "$DOTFILES/.scripts" ] && cp -r "$DOTFILES/.scripts" "$HOME/"

# --- 3. Home -> Dropbox symlinks --------------------------------------------
log "Home symlinks into Dropbox"
for d in Documents Downloads Pictures Music Videos WORK; do
  [ -e "$HOME/$d" ] && [ ! -L "$HOME/$d" ] && mv "$HOME/$d" "$HOME/$d-preexisting"
  ln -sfn "$HOME/Dropbox/$d" "$HOME/$d"
done

# --- 4. Personal repos -------------------------------------------------------
log "Personal repos"
[ -d "$HOME/me" ] || git clone git@github.com:metodiew/me.git "$HOME/me"
[ -d "$HOME/Software/control-room" ] || \
  git clone git@github.com:metodiew/Control-Room.git "$HOME/Software/control-room"

# --- 5. Autostart entries ----------------------------------------------------
log "Autostart (Guake, etc.)"
mkdir -p "$HOME/.config/autostart"
cat > "$HOME/.config/autostart/guake.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Guake Terminal
Exec=guake
Icon=guake
Terminal=false
X-GNOME-Autostart-enabled=true
EOF
[ -f "$BACKUP/Config Files/guake-preferences" ] && \
  guake --restore-preferences "$BACKUP/Config Files/guake-preferences" || true

# --- 6. System tunables ------------------------------------------------------
log "System tunables"
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf >/dev/null
sudo sysctl --system >/dev/null

# --- 7. Editors --------------------------------------------------------------
log "VS Code / Cursor extensions"
VSEXT="$BACKUP/Config Files/vscode-extensions.txt"
[ -f "$VSEXT" ] && command -v code >/dev/null && xargs -L1 code --install-extension < "$VSEXT" || true
# TODO: same for Cursor from "Config Files/Cursor/cursor-extensions.txt"

# --- 8. NetworkManager (WiFi/VPN) -------------------------------------------
log "NetworkManager connections"
NMZIP=$(ls -1t "$BACKUP/Config Files/NetworkManager/"system-connections-*.zip 2>/dev/null | head -1 || true)
if [ -n "${NMZIP:-}" ]; then
  sudo unzip -o "$NMZIP" -d / >/dev/null   # TODO: confirm the zip's internal path layout first
  sudo chmod 600 /etc/NetworkManager/system-connections/* || true
  sudo systemctl restart NetworkManager || true
fi

# --- TODO: still manual / to script later ------------------------------------
# - Chrome disk-cache flag in ~/.local/share/applications/google-chrome.desktop
# - LAMP: Apache + PHP + MySQL, a2enmod rewrite, PHP upload limits
# - Restore Apache sites-available + /etc/hosts from backup; import MySQL dumps from Dropbox
# - node/nvm, WP-CLI, global npm tools
# - Manual only: Dropbox login, Chrome/Slack/Grammarly/Toggl logins, fingerprint, LUKS passphrase

log "Done. Review the TODOs above for the parts still manual."
