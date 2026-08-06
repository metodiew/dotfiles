# ThinkPad Backup & Restore — MASTER REFERENCE (manual fallback)

Prepared 2026-08-01. Use this if the scripts (`provision.sh`, `dropbox-*.sh`) fail — every automated
step has its **manual command** below. Machine: Lenovo ThinkPad X1 Yoga Gen 6, Linux Mint 22.3 Cinnamon.
Migration: `/home` moves from eCryptfs → **LUKS** full-disk encryption (fixes the I/O-stall freezes).

Recovery model: **no external disk** — everything is in a **git remote (GitHub)** or **Dropbox**.

---

## 1. Where everything lives

| What | Location |
|------|----------|
| dotfiles, scripts | GitHub `metodiew/dotfiles` → `~/Software/dotfiles` |
| `~/me` | GitHub `metodiew/me` → `~/me` |
| Control Room | GitHub `metodiew/Control-Room` → `~/Software/control-room` |
| Display profiles | GitHub `metodiew/display-profiles` |
| Backup root | `~/Dropbox/Backup Files/` |
| SSH keys | `Backup Files/Config Files/ssh folder/*.zip` |
| Dotfiles copies | `Backup Files/Config Files/` (`.bashrc`, `.gitconfig`, `.profile`, `.vimrc`, `.scripts`) |
| Packages | `Config Files/pkglist.txt` (manual), `pkglist-full.txt`, `pkglist-flatpak.txt` |
| No-sync list | `Config Files/dropbox-exclude-list.txt` |
| NetworkManager (WiFi/VPN) | `Config Files/NetworkManager/system-connections-*.zip` |
| VS Code settings | `Config Files/VSCode/` + `vscode-extensions.txt` |
| Cursor settings | `Config Files/Cursor/` + `Cursor/cursor-extensions.txt` |
| Claude CLI | `Config Files/claude-20260801.zip` + `claude.json` |
| Desktop settings | `Config Files/dconf-backup.txt` (Cinnamon/Guake/keybindings) |
| File-manager favorites | `Config Files/nemo-bookmarks` |
| CopyQ / cinnamon config | `Config Files/copyq/`, `Config Files/cinnamon/` |
| Guake prefs | `Config Files/guake-preferences` |
| Apache config | `Config Files/Apache Conf/`, `/etc/hosts` in `Config Files/Hosts/` |
| Autostart entries | `Config Files/Config Folder/autostart-*.zip` |
| Dev SSL certs (+ root CA) | `Backup Files/WWW Backup/certs-*.zip` → `~/certs` |
| Service account key | `Config Files/service-account-keys-*.zip` → `~/Software/service-account-keys` |
| Web projects | `WWW Backup/Apache/www-directory-backup/20260801/` (`<proj>.zip` + `<proj>-db.zip`) |
| Non-WP DBs | `WWW Backup/Apache/SQLs/20260801.{timetracker,velocity_dashboard}.zip` |
| Old snapshots (history) | ZZ no-sync folder (web only) |

**MySQL local dev creds:** user `root`, password `root`.

## 2. No-sync (Selective Sync excluded) folders
`DevriX/DevriX`, `DevriX Marketing`, `DevriX Products`, `DevriX Shared Folder`, `WORK Non Sync Folder`,
`ZZ Dropbox No Sync Folder - Keep just in Web version`, `veda`.

## 3. NOT backed up (by design)
Viber (re-links to phone), Claude desktop app `~/.config/Claude` (23G cache, re-login), cloud apps
(Slack, Spotify, Clockify, RescueTime, Todoist, Bitwarden, Discord — just re-login).

---

# RESTORE

## Automated (happy path)
```
bash ~/Software/dotfiles/Toolbox/Linux/laptop-backup-scripts/dropbox-exclude-restore.sh
bash ~/Software/dotfiles/Toolbox/Linux/laptop-backup-scripts/dropbox-restore-tiered.sh phase1   # slow wifi only
bash ~/Software/dotfiles/Toolbox/Linux/provision.sh
# ...LAMP finish (below)...
bash ~/Software/dotfiles/Toolbox/Linux/laptop-backup-scripts/dropbox-restore-tiered.sh phase2   # pull www/media
```

## MANUAL fallback — do each step by hand if scripts fail

### Step 0 — Install with LUKS
In the Mint installer: "Erase disk and install Linux Mint" + check **"Encrypt the new installation for
security"**. Set a strong LUKS passphrase, write it down offline. Do NOT re-enable "encrypt home folder".

### Step 1 — Base tools + Dropbox
```
sudo apt update
sudo apt install -y openssh-server git curl zip unzip build-essential
```
Install Dropbox (.deb from dropbox.com), log in. **Two-phase for slow wifi:** in the first-run Selective
Sync dialog, UNCHECK `WWW Backup`, `Pictures`, `Downloads`, `Videos`, `Music`, `Books` — re-check later.

### Step 2 — SSH keys (needed before cloning)
```
mkdir -p ~/.ssh
unzip "~/Dropbox/Backup Files/Config Files/ssh folder/"*.zip -d /tmp/ssh-restore
cp -r /tmp/ssh-restore/home/metodiew/.ssh/* ~/.ssh/    # adjust path to the zip's layout
chmod 700 ~/.ssh && chmod 600 ~/.ssh/*
```

### Step 3 — Repos
```
git clone git@github.com:metodiew/dotfiles.git ~/Software/dotfiles
git clone git@github.com:metodiew/me.git ~/me
git clone git@github.com:metodiew/Control-Room.git ~/Software/control-room
```

### Step 4 — dotfiles
```
cd ~
cp ~/Software/dotfiles/.bashrc ~/Software/dotfiles/.bash_profile ~/Software/dotfiles/.profile \
   ~/Software/dotfiles/.gitconfig ~/Software/dotfiles/.vimrc .
cp -r ~/Software/dotfiles/.scripts .
```

### Step 5 — No-sync folders (keep the big/private folders out of local sync)
```
while IFS= read -r p; do dropbox exclude add "$p"; done < "~/Dropbox/Backup Files/Config Files/dropbox-exclude-list.txt"
```

### Step 6 — Home → Dropbox symlinks
```
cd ~; rm -rf Documents Downloads Pictures Music Videos WORK 2>/dev/null
for d in Documents Downloads Pictures Music Videos WORK; do ln -sfn ~/Dropbox/$d ~/$d; done
```

### Step 7 — Packages (installs CURRENT versions from repos)
```
B=~/Dropbox/Backup\ Files/Config\ Files
sudo apt update
while read -r p; do
  dpkg -s "$p" >/dev/null 2>&1 && continue           # already installed
  apt-cache show "$p" >/dev/null 2>&1 && sudo apt install -y "$p" || echo "gone: $p"
done < "$B/pkglist.txt"
```

### Step 8 — Autostart + Guake
```
mkdir -p ~/.config/autostart
unzip "~/Dropbox/Backup Files/Config Files/Config Folder/autostart-"*.zip -d /tmp/as
cp /tmp/as/home/metodiew/.config/autostart/* ~/.config/autostart/    # adjust to zip layout
guake --restore-preferences "~/Dropbox/Backup Files/Config Files/guake-preferences"
```
If Guake still doesn't autostart, ensure `~/.config/autostart/guake.desktop` exists with `Exec=guake`.

### Step 9 — Tunables + Chrome cache
```
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf && sudo sysctl --system
```
In `~/.local/share/applications/google-chrome.desktop`, add to the Exec lines:
`--disk-cache-dir=/dev/shm/chrome-cache --disk-cache-size=2000000000`

### Step 10 — VS Code + Cursor (settings + extensions)
```
B=~/Dropbox/Backup\ Files/Config\ Files
mkdir -p ~/.config/Code/User ~/.config/Cursor/User
cp "$B/VSCode/"*.json ~/.config/Code/User/ 2>/dev/null; cp -r "$B/VSCode/snippets" ~/.config/Code/User/ 2>/dev/null
cp "$B/Cursor/"*.json ~/.config/Cursor/User/ 2>/dev/null; cp -r "$B/Cursor/snippets" ~/.config/Cursor/User/ 2>/dev/null
xargs -L1 code   --install-extension < "$B/vscode-extensions.txt"
xargs -L1 cursor --install-extension < "$B/Cursor/cursor-extensions.txt"
```

### Step 11 — NetworkManager (WiFi/VPN)
```
Z=$(ls -1t "~/Dropbox/Backup Files/Config Files/NetworkManager/"system-connections-*.zip | head -1)
sudo unzip -o "$Z" -d /        # restores /etc/NetworkManager/system-connections/
sudo chmod 600 /etc/NetworkManager/system-connections/* && sudo systemctl restart NetworkManager
```

### Step 12 — Desktop settings + favorites + CopyQ
```
B=~/Dropbox/Backup\ Files/Config\ Files
dconf load / < "$B/dconf-backup.txt"                       # Cinnamon panel/applets/keybindings + Guake
mkdir -p ~/.config/gtk-3.0; cp "$B/nemo-bookmarks" ~/.config/gtk-3.0/bookmarks   # favorites
cp -r "$B/copyq" ~/.config/ ; cp -r "$B/cinnamon" ~/.config/
```
Log out/in (or `cinnamon --replace &`) for the desktop to fully apply.

### Step 13 — Dev SSL certs + service account key
```
Z=$(ls -1t "~/Dropbox/Backup Files/WWW Backup/"certs-*.zip | head -1)
( cd ~ && unzip -o "$Z" )        # -> ~/certs
# Trust the root CA so local HTTPS is green:
sudo cp ~/certs/myCA.pem /usr/local/share/ca-certificates/myCA.crt && sudo update-ca-certificates
# (also import ~/certs/myCA.pem into Chrome: Settings > Privacy > Security > Manage certificates > Authorities)
S=$(ls -1t "~/Dropbox/Backup Files/Config Files/"service-account-keys-*.zip | head -1)
( cd ~/Software && unzip -o "$S" )   # -> ~/Software/service-account-keys
```
New cert for a domain later: `cd ~/certs && ./install-certs.sh local.example.com`

### Step 14 — LAMP + projects + databases
```
# Install LAMP (see setup MD for the DO guide), then:
sudo a2enmod rewrite
# hosts + apache vhosts:
sudo cp "~/Dropbox/Backup Files/Config Files/Hosts/hosts."* /etc/hosts        # review before overwriting
sudo unzip -o "~/Dropbox/Backup Files/Config Files/Apache Conf/"*.zip -d /     # -> /etc/apache2/sites-available
# Projects: extract each into /var/www/html
cd /var/www/html
for z in "~/Dropbox/Backup Files/WWW Backup/Apache/www-directory-backup/20260801/"*.zip; do
  case "$z" in *-db.zip) ;; *) sudo unzip -o "$z" ;; esac      # skip the -db zips here
done
# Databases: create + import each. WP DB name is in each project's wp-config.php (DB_NAME).
#   unzip <proj>-20260801-db.zip  -> a .sql file
#   mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS <db_name>"
#   mysql -u root -proot <db_name> < <the>.sql
# Non-WP DBs (timetracker, velocity_dashboard) live in WWW Backup/Apache/SQLs/20260801.*.zip — same import.
sudo systemctl restart apache2
```

### Step 15 — Logins + Phase 2
- Sign into Chrome Sync, Slack, Grammarly, Toggl, etc.
- Pull deferred big folders: `dropbox-restore-tiered.sh phase2`, or re-check them in Dropbox Selective Sync.

### Step 16 — Verify
```
mount | grep -i ecryptfs        # should be EMPTY (proves LUKS-only, eCryptfs gone)
lsblk                           # root LV sits on a 'crypt' device
cat /proc/pressure/io           # under load, the 'full' line stays near zero = freezes gone
```

---

## Backup (what the weekly script captures)
`sudo bash ~/Software/dotfiles/Toolbox/Linux/laptop-backup-scripts/metodiew-laptop-backup.sh`
Captures: dotfiles, VS Code/Cursor settings + extension lists, Claude CLI, `~/me` + control-room,
SSH, FileZilla, Apache config + hosts, autostart, NetworkManager, pkglists, Dropbox no-sync list,
`~/certs`, service-account key, dconf/desktop settings + Nemo favorites + CopyQ + cinnamon, Guake prefs,
and all `/var/www/html` projects + their MySQL databases. Destination: `~/Dropbox/Backup Files/`.

## Order-critical gotchas
1. **SSH keys before cloning** (Step 2 before Step 3) — clones use SSH.
2. **Trust `myCA.pem`** or local HTTPS sites show cert errors.
3. **`dconf load` then log out/in** for the full desktop.
4. **Confirm Dropbox "Up to date" before ever wiping again.**
5. Apache references certs by absolute path `/home/metodiew/certs/*.crt` — keep certs at `~/certs`.
