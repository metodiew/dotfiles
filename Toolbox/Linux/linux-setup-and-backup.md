# Linux Setup and Backup
This is a personal step-by-step for installing a new machine or just refreshing my Ubuntu setup. If you feel it useful or have any feedback, please drop a line :)

For some context, I'm using the [laptop-backup-scripts](https://github.com/metodiew/dotfiles/tree/master/Toolbox/Linux/laptop-backup-scripts) set of scripts here where I backup my laptop on a weekly basis and I can easily restore the setup just like it was before.

Once we have the new system/laptop in place, we are going to follow the steps below.

---

## 🚀 START HERE — restore from a fresh OS (you have NOTHING: no git, no Dropbox, no scripts)

You're reading this on GitHub with a blank machine. The dotfiles repo is **public**, so you can clone it
over **HTTPS with no SSH key** — that's the unlock that bootstraps everything. Do these in order, by hand:

1. **Install Mint with LUKS.** In the installer tick *"Encrypt the new installation for security"*. Set +
   write down the LUKS passphrase (no recovery if lost).
2. **Base tools** (no scripts yet):
   ```
   sudo apt update && sudo apt install -y git openssh-server curl zip unzip build-essential
   ```
3. **Get the scripts** — clone dotfiles over HTTPS (public repo, no SSH needed):
   ```
   mkdir -p ~/Software && git clone https://github.com/metodiew/dotfiles.git ~/Software/dotfiles
   ```
   Everything referenced below now lives at `~/Software/dotfiles/Toolbox/Linux/`.
4. **Install Dropbox** (.deb from dropbox.com), log in. Slow wifi? In the first-run **Selective Sync**
   dialog UNCHECK `WWW Backup`, `Pictures`, `Downloads`, `Videos`, `Music`, `Books`. Let
   `Backup Files/Config Files` sync first.
5. **Restore SSH keys** (needed for private repos): unzip the latest
   `~/Dropbox/Backup Files/Config Files/ssh folder/*.zip` into `~/.ssh`, then
   `chmod 700 ~/.ssh && chmod 600 ~/.ssh/*`.
6. **Re-apply the no-sync folders:**
   `bash ~/Software/dotfiles/Toolbox/Linux/laptop-backup-scripts/dropbox-exclude-restore.sh`
7. **Run the automated setup** (packages at current versions, dotfiles, symlinks, repos, editors,
   NetworkManager, certs, service key, desktop settings):
   `bash ~/Software/dotfiles/Toolbox/Linux/provision.sh`
8. **LAMP finish** (manual — see the LAMP section below) + pull the big folders:
   `bash ~/Software/dotfiles/Toolbox/Linux/laptop-backup-scripts/dropbox-restore-tiered.sh phase2`

**If a script fails:** every step has a manual command in **`RESTORE-MASTER-REFERENCE.md`** (in this repo,
and in `~/Dropbox/Backup Files/` once synced). The sections below are the classic checklist — pick
"run the script" for the fast path, or the manual notes as fallback.

---

## Install Software, Programs, Tools
We have to start with some of the tools and software we'll be using

* Enable SSH `sudo apt install openssh-server -y`
* Git `sudo apt-get install git`
* Install **Dropbox**
  * We'll need this one to start syncing files and folders as we'll need them below
  * **Re-apply the no-sync folders (Selective Sync exclusions):** once `Backup Files/Config Files`
    has synced, and ideally BEFORE the full sync runs, execute this file:
    ```
    bash ~/Software/dotfiles/Toolbox/Linux/laptop-backup-scripts/dropbox-exclude-restore.sh
    ```
    It replays `Backup Files/Config Files/dropbox-exclude-list.txt` (saved by the weekly backup),
    so the no-sync folders are never downloaded. This replaces the old manual selective-sync screenshot.
  * **Two-phase sync (for slow connections):** get a usable machine fast, then pull the heavy stuff later:
    ```
    bash ~/Software/dotfiles/Toolbox/Linux/laptop-backup-scripts/dropbox-restore-tiered.sh phase1   # essentials only
    # ...set up the machine (provision.sh)...
    bash ~/Software/dotfiles/Toolbox/Linux/laptop-backup-scripts/dropbox-restore-tiered.sh phase2   # pull www + media later
    ```
    Easiest phase1 is the Dropbox first-run Selective Sync dialog (uncheck WWW Backup, Pictures, Downloads, Videos, Music, Books).

### Dotfiles
Clone the dotfies folder

```
cd ~/Software
```
and run
```
git clone git@github.com:metodiew/dotfiles.git
```

Apply the dotfiles to my machine
Go to the ~ folder and delete the existing files
```
cd ~/
```
and run
```
rm .bash_logout .bash_profile .bashrc .profile
```

Let's link the proper files
```
cp ~/Software/dotfiles/.bash_logout .
cp ~/Software/dotfiles/.bash_profile .
cp ~/Software/dotfiles/.bashrc .
cp ~/Software/dotfiles/.gitconfig .
cp ~/Software/dotfiles/.profile .
cp ~/Software/dotfiles/.vimrc .
cp -r ~/Software/dotfiles/.scripts .
```

### Personal repos
Clone the personal repos from GitHub (also zipped to Dropbox weekly as a fallback):
```
git clone git@github.com:metodiew/me.git ~/me
git clone git@github.com:metodiew/Control-Room.git ~/Software/control-room
```
* `~/me` — personal identity/context repo
* `~/Software/control-room` — self-hosted ops hub. No secrets stored locally: secrets live in
  Infisical (cloud) and the machine identity lives in `/opt/control-room/.env` on the server.
  Recovery here is just the `git clone` above.

### Browsers
* Chrome
* Opera, *not required*
* Vivaldi, *not required*

----

## Dropbox Folders Sync and Structure
Adjust the folders and directories

```
cd ~/
rm -r Documents Music Pictures Videos
mv Downloads Downloads-No-Dropbox
ln -s ~/Dropbox/Documents/ .
ln -s ~/Dropbox/Downloads/ .
ln -s ~/Dropbox/Music/ .
ln -s ~/Dropbox/Pictures/ .
ln -s ~/Dropbox/Videos/ .
ln -s ~/Dropbox/WORK/ .


```

### Productivity
* Toggl
* Todoist app
* RescueTime
* Grammarly - do not forget to login, otherwise the stats will be lost :)
* [ack](https://metodiew.com/install-ack-on-ubuntu/)
* [DevriX Asana Chrome Extension](https://github.com/DevriX/dx-chrome-asana-task-template) - `git clone git@github.com:DevriX/dx-chrome-asana-task-template.git`
* [Albert](https://superuser.com/questions/1560683/how-to-install-albert-keyboard-launcher)
  * Restore the config file - `.config/albert/albert.conf`
* [Notification Clock with time zones](sudo apt install gnome-clocks)
* Flameshot
 * Set the [custom shortcuts](https://flameshot.org/docs/guide/key-bindings/) and replace print button
 * set the location of the screenshots
 * Enable [Fingerprint](https://forums.linuxmint.com/viewtopic.php?t=408129) setup

### Communication
* Slack
* Viber
  * Potential fix for Viber not starting [here](https://forums.linuxmint.com/viewtopic.php?p=2224326&sid=09ab85b16b16d0aa3020617a7b6b5db3#p2224326)
* Zoom
  * Verify the Zoom screenshare is working with Wayland
* Skype, *not required*
* ~~[Skype 2](http://blog.metodiew.com/vtora-skype-instantsiya-secondary-skype-pod-ubuntu-12-04/)~~

### Development
All needed dev tools, programs and helpful gadgets

* Install [Visual Studio Code](https://linuxiac.com/install-visual-studio-code-on-ubuntu-22-04/)
  * VS Code + Cursor restore is automated by `provision.sh`: user settings/keybindings/snippets from
    `Config Files/VSCode/` and `Config Files/Cursor/`, and extensions reinstalled from
    `vscode-extensions.txt` / `cursor-extensions.txt` via `code`/`cursor --install-extension`.
  * The heavy `~/.vscode/extensions` folder is NOT backed up — it's rebuilt from the list.
* Node and NPM install
  ```
  sudo apt install npm
  sudo apt install nodejs
  ```
  * run this in order to make sure node is working properly `sudo ln -s /usr/bin/nodejs /usr/bin/node`
* [nvm](https://github.com/nvm-sh/nvm/blob/master/README.md#install--update-script)
* LAMP stack
  * [Ubuntu LAMP Stack](https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mysql-php-lamp-stack-on-ubuntu-22-04) or a newer version
    * [Linux Mint instlals older PHP version](https://php.watch/articles/php-8.3-install-upgrade-on-debian-ubuntu)
  * Fix the [MySQL Pssword](https://stackoverflow.com/questions/50691977/how-to-reset-the-root-password-in-mysql-8-0-11) or an alternative version
  * Install [phpMyAdmin](https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-on-ubuntu-22-04) or an alternative version
* [WP-CLI](http://wp-cli.org/#installing)
* Gulp: `sudo npm install gulp -g`

* Xdebug
* Sass/Compass
  * We need to install Ruby first: `sudo apt-get install ruby-full`
  * Then: `sudo gem install sass --no-user-install`
* [Git Open] - `sudo npm install --global git-open`
* ~~SVN~~
* ~~Vagrant~~
* ~~VVV~~
* ~~Grunt `npm install -g grunt-cli`~~


### Tools and Software
Some general tools which is hard to be categorized

* Guake  
  * Restore the Guake Preference with:  
  `guake --restore-preferences ~/Dropbox/Backup\ Files/Config\ Files/guake-preferences`
  * [How To Use Guake Terminal Under Wayland](https://www.linuxuprising.com/2021/12/how-to-use-guake-terminal-under-wayland.html)
* Vim
* Flameshot
* Torguard
* [CopyQ clipboard](https://github.com/hluk/CopyQ)
* Dropbox
  * Also, consider installing `Nemo Dropbox` for `Cinnamon Desktop` environment
* FileZilla
* Poedit
* Gnome Tweaks Tools
* [Ubuntu Notification Shortcut](https://github.com/metodiew/ubuntu-notification-shortcut)
* [Write](https://www.styluslabs.com/download/)
* [Peek](https://github.com/phw/peek)
* Spotify
* VLC
* [Screen Rotate](https://extensions.gnome.org/extension/5389/screen-rotate/)
* Add Power Profiles, if there are no available - [click here](https://forums.linuxmint.com/viewtopic.php?t=387242)
* ~~Steam~~
  * ~~CSGO~~
* ~~Rhythmbox~~
* ~~Virtual Box~~
* ~~Gimp~~
* ~~pCloud~~

## Misc and General Items
* Desktop settings restore via `provision.sh`: `dconf load` from `Config Files/dconf-backup.txt`
  (Cinnamon panel/applets/keybindings + Guake + Nemo), plus `nemo-bookmarks` (file-manager favorites),
  `copyq`, and `cinnamon` configs. Log out/in afterwards for the full desktop to apply.
* [Calendar - first day Monday](https://askubuntu.com/questions/197613/monday-as-first-day-in-gnome-shell-instead-of-sunday)
* Enable Night Light feature
* [Language select / Keyboard indicator on toolbar does not work](https://askubuntu.com/a/1407683/225076)
* Apps and Libraries
  * Laptop backup screenshot requires `sudo apt install imagemagick`
  

## LAMP Stack adjustmnets and local projects setup:
  * Apache conf AllowOverride
  * `sudo a2enmod rewrite`
  * PHP upload limits adjustments
  * Copy the Dropbox backup of SQLs and www folder to laptop
  * Extract all projects and set them one by one
  * Restore local dev SSL certs: unzip the latest `Backup Files/WWW Backup/certs-*.zip` into `~/`
    (creates `~/certs`), then import `~/certs/myCA.pem` into the browser/system trust store. Apache
    references `/home/metodiew/certs/*.crt` by absolute path. New domains: `~/certs/install-certs.sh <domain>`.

## OS Install
* Apache Settings and all the sites-enabled and sites-available items
* /etc/hosts file
* /etc/NetworkManager/system-connections
* .ssh
* Startup Applications
* dotfiles
  * .bashrc
  * .bash_profile
  * .gitconfig
  * .scripts
  * .profile
  * .vimrc

## Old things that I probably do not need anymore
* Vivacom USB - [Huawei E173s and Ubuntu] (http://metodiew.com/huawei-e173s-and-ubuntu/)
* HDMI Sound - fix the issue
* [Eclipse - Add Sass support] (http://stackoverflow.com/a/12322531)
* [No Alt + Tab in 15.04 Gnome Flashback session?] (http://askubuntu.com/a/498317)
* [Fix Calendar Language issue](http://askubuntu.com/a/288365)
* Add Workspaces - `Go to Compiz Settings => General Options => Desktop Size`
* [How to keep apache and mysql from starting automatically] (http://askubuntu.com/a/138495)
* [How to Disable Overlay Scrollbars in Ubuntu] (http://ubuntuhandbook.org/index.php/2013/10/disable-overlay-scrollbars-ubuntu13-10/)
* [Xdebug on Ubuntu for WordPress] (http://devwp.eu/xdebug-on-ubuntu-for-wordpress/) - with a few personal tweaks
