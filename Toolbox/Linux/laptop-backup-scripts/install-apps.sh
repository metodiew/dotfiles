#!/bin/bash
#
# install-apps.sh — desktop app layer on top of provision.sh (phase 1 of restore.sh).
# Best-effort by design: a single failed download must not abort the rest (no set -e).
set -uo pipefail
BACKUP="$HOME/Dropbox/Backup Files"
DOTFILES="$HOME/Software/dotfiles"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
log()  { printf '\n\033[1;32m==> %s\033[0m\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }
deb()  { # $1=url $2=name
  log "deb: $2"
  wget -qO "$TMP/$2.deb" "$1" && sudo apt install -y "$TMP/$2.deb" || echo "  FAILED: $2 — install manually"
}

log "apt apps"
sudo apt update
sudo apt install -y copyq flameshot guake flatpak conky-all

log ".deb apps"
have google-chrome || deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" chrome
have code          || deb "https://update.code.visualstudio.com/latest/linux-deb-x64/stable" vscode
if [ -f "$HOME/Dropbox/rescuetime_current_amd64.deb" ] && ! have rescuetime; then
  sudo apt install -y "$HOME/Dropbox/rescuetime_current_amd64.deb"
fi
# Zoom is in pkglist.txt but has never been an apt package — it comes from Zoom's
# own .deb, so provision's package replay correctly reports it as "no candidate".
have zoom || deb "https://zoom.us/client/latest/zoom_amd64.deb" zoom
# Clockify: official deb needs gconf2 (dead since Ubuntu 22) — use a Chrome app-mode
# launcher instead; named clockify.desktop so the restored panel pin resolves.
if [ ! -f "$HOME/.local/share/applications/clockify.desktop" ]; then
  mkdir -p "$HOME/.local/share/applications"
  cat > "$HOME/.local/share/applications/clockify.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Clockify
Comment=Clockify time tracker (web app)
Exec=google-chrome --app=https://app.clockify.me
Icon=google-chrome
Categories=Office;Utility;
StartupWMClass=app.clockify.me
EOF
  update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
  echo "  clockify: Chrome app-mode launcher created"
fi

log "Cursor (.deb, URL from the release API)"
if ! have cursor; then
  CURSOR_DEB=$(curl -s --max-time 30 "https://api2.cursor.sh/updates/api/download/stable/linux-x64/cursor" \
    | grep -oP '"debUrl":"\K[^"]+' || true)
  if [ -n "$CURSOR_DEB" ]; then
    deb "$CURSOR_DEB" cursor
  else
    echo "  FAILED: cursor — release API unreachable; download manually from cursor.com"
  fi
fi

log "flatpak apps (Slack, Spotify, Viber, Todoist)"
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# Discord via flatpak, not its .deb: the .deb never updates through apt and Discord
# hard-blocks launch until you manually download a newer one.
for app in com.slack.Slack com.spotify.Client com.viber.Viber com.todoist.Todoist com.discordapp.Discord; do
  # skip flatpak Spotify if the apt client is already installed (pkglist replay)
  [ "$app" = com.spotify.Client ] && dpkg -s spotify-client >/dev/null 2>&1 && continue
  flatpak info "$app" >/dev/null 2>&1 || sudo flatpak install -y flathub "$app" || echo "  FAILED: $app"
done

log "Flameshot config + save dir"
mkdir -p "$HOME/.config/flameshot" "$HOME/Dropbox/Flameshot"
[ -f "$BACKUP/Config Files/flameshot.ini" ] && cp "$BACKUP/Config Files/flameshot.ini" "$HOME/.config/flameshot/"

log "Local key files (mode 600)"
SECRETS="$BACKUP/Config Files/Secrets"
mkdir -p "$HOME/.config/rescuetime"
[ -f "$SECRETS/env" ] && install -m 600 "$SECRETS/env" "$HOME/.config/env"
[ -f "$SECRETS/rescuetime/env" ] && install -m 600 "$SECRETS/rescuetime/env" "$HOME/.config/rescuetime/env"

log "autorandr display profiles (latest backup)"
AUTORANDR_ZIP=$(ls -1 "$BACKUP/Config Files/Config Folder/"autorandr-*.zip 2>/dev/null | sort | tail -n 1)
# The zip stores home/<user>/.config/autorandr/..., so unpack it at /
[ -n "$AUTORANDR_ZIP" ] && [ ! -d "$HOME/.config/autorandr" ] && unzip -q "$AUTORANDR_ZIP" -d / && echo "  restored from $(basename "$AUTORANDR_ZIP")"

# Chrome disk-cache-in-RAM flag: DELIBERATELY NOT APPLIED.
# It was a workaround for eCryptfs I/O stalls (cache on disk froze the machine).
# LUKS removed that problem — I/O pressure sits at ~0.1% — so the flag became pure
# cost: /dev/shm is RAM, and the cache drifted to 3.5G past its own 2G cap while
# Chrome itself held 23G. Removed 2026-08-12; do not re-add without an I/O reason.

log "Autostart: Todoist, Viber, Slack, Discord at login"
mkdir -p "$HOME/.config/autostart"
# Copy each flatpak's EXPORTED .desktop rather than hand-writing a minimal one:
# entries without Icon/Terminal render badly (or not at all) in Cinnamon's
# Startup Applications list, and the exported Exec survives runtime changes.
for app in com.todoist.Todoist com.viber.Viber com.slack.Slack com.discordapp.Discord; do
  short=$(echo "$app" | cut -d. -f3 | tr '[:upper:]' '[:lower:]')
  src="/var/lib/flatpak/exports/share/applications/$app.desktop"
  if [ -f "$src" ] && [ ! -f "$HOME/.config/autostart/$short.desktop" ]; then
    cp "$src" "$HOME/.config/autostart/$short.desktop"
    grep -q "^X-GNOME-Autostart-enabled" "$HOME/.config/autostart/$short.desktop" || \
      echo "X-GNOME-Autostart-enabled=true" >> "$HOME/.config/autostart/$short.desktop"
    echo "  autostart added: $short"
  fi
done
# RescueTime tracks passively — useless unless it starts with the session
if have rescuetime && [ ! -f "$HOME/.config/autostart/rescuetime.desktop" ]; then
  cat > "$HOME/.config/autostart/rescuetime.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=RescueTime
Comment=Automatic time tracking
Exec=rescuetime
Icon=utilities-system-monitor
Terminal=false
X-GNOME-Autostart-enabled=true
EOF
fi
# apt apps: copy their shipped .desktop into autostart (keeps Exec/Icon correct)
for pair in "copyq:com.github.hluk.copyq" "spotify:spotify"; do
  short=${pair%%:*}; src="/usr/share/applications/${pair##*:}.desktop"
  if [ -f "$src" ] && [ ! -f "$HOME/.config/autostart/$short.desktop" ]; then
    cp "$src" "$HOME/.config/autostart/$short.desktop"
    grep -q X-GNOME-Autostart-enabled "$HOME/.config/autostart/$short.desktop" || \
      echo "X-GNOME-Autostart-enabled=true" >> "$HOME/.config/autostart/$short.desktop"
    # CopyQ's shipped entry ends with 'show' — that pops its window at every login
    sed -i 's|^Exec=copyq --start-server show$|Exec=copyq --start-server|' "$HOME/.config/autostart/$short.desktop"
    echo "  autostart added: $short"
  fi
done

# Dropbox tray icon on Cinnamon. Dropbox string-matches $XDG_CURRENT_DESKTOP against
# Unity/KDE/GNOME/XFCE/MATE and silently declines to draw an indicator on anything else.
# Cinnamon reports "X-Cinnamon", so the icon never appears — even though Cinnamon runs a
# StatusNotifier host (org.x/org.kde.StatusNotifierWatcher) and has libayatana-appindicator3
# installed, i.e. it can render the indicator perfectly well. Claiming Unity for Dropbox's
# process only is enough. Verified working 2026-08-31. If Nemo integration ever misbehaves,
# this prefix is the first thing to drop.
log "Dropbox tray icon fix (Cinnamon reports X-Cinnamon, which Dropbox won't draw on)"
DBAUTO="$HOME/.config/autostart/dropbox.desktop"
if [ -f "$DBAUTO" ]; then
  if grep -q '^Exec=env XDG_CURRENT_DESKTOP=' "$DBAUTO"; then
    echo "  already patched"
  else
    sed -i 's|^Exec=\(dropbox .*\)$|Exec=env XDG_CURRENT_DESKTOP=Unity \1|' "$DBAUTO" \
      && echo "  Exec patched -> env XDG_CURRENT_DESKTOP=Unity"
  fi
else
  mkdir -p "$HOME/.config/autostart"
  cat > "$DBAUTO" <<'EOF'
[Desktop Entry]
Name=Dropbox
GenericName=File Synchronizer
Comment=Sync your files across computers and to the web
Exec=env XDG_CURRENT_DESKTOP=Unity dropbox start -i
Terminal=false
Type=Application
Icon=dropbox
Categories=Network;FileTransfer;
Keywords=file;synchronization;sharing;collaboration;cloud;storage;backup;
StartupNotify=false
X-GNOME-Autostart-enabled=true
EOF
  echo "  created (Dropbox had not written one yet)"
fi

# Conky desktop health strip: CPU load + top processes, memory + top RAM hogs, pinned to
# head 0 bottom-right. The config is SYMLINKED rather than copied so tuning the widget
# updates the repo directly — the copy pattern used for .bashrc et al. is what let
# ~/.gitconfig silently drift away from its tracked version.
log "Conky health widget (config + autostart)"
if [ -f "$DOTFILES/.config/conky/health.conf" ]; then
  mkdir -p "$HOME/.config/conky" "$HOME/.config/autostart"
  ln -sfn "$DOTFILES/.config/conky/health.conf" "$HOME/.config/conky/health.conf"
  cp "$DOTFILES/.config/autostart/conky-health.desktop" "$HOME/.config/autostart/"
  echo "  conky config symlinked + autostart added"
else
  echo "  SKIPPED: $DOTFILES/.config/conky/health.conf not found"
fi

# Claude desktop reports WM_CLASS "com.anthropic.claude", the Android package name, so
# RescueTime files desktop time as "Claude for Android". Rename it at login. See RESCUETIME.md.
log "Claude desktop WM_CLASS rename for RescueTime (script + autostart)"
mkdir -p "$HOME/.local/bin" "$HOME/.config/autostart"
ln -sfn "$DOTFILES/.local/bin/claude-wmclass" "$HOME/.local/bin/claude-wmclass"
cp "$DOTFILES/.config/autostart/claude-wmclass.desktop" "$HOME/.config/autostart/"

log "Panel pin remap (apt->flatpak app IDs changed)"
PINJSON="$HOME/.config/cinnamon/spices/grouped-window-list@cinnamon.org/2.json"
if [ -f "$PINJSON" ] && flatpak info com.slack.Slack >/dev/null 2>&1; then
  sed -i 's/"slack\.desktop"/"com.slack.Slack.desktop"/' "$PINJSON" \
    && echo "  slack pin -> com.slack.Slack.desktop (restart Cinnamon to see it: Ctrl+Alt+Esc)"
fi

log "MANUAL LOGIN CHECKLIST — do these yourself:"
cat <<'EOF'
  [ ] Chrome Sync          [ ] Slack workspaces      [ ] Viber (link to phone)
  [ ] Todoist              [ ] Spotify               [ ] RescueTime
  [ ] Clockify / Toggl     [ ] Grammarly             [ ] Claude Code CLI login (claude)
  [ ] Claude desktop app (install per previous method + login)
  [ ] Fingerprint reader (Mint: Users & Groups)      [ ] Bitwarden
EOF
