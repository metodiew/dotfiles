# Ubuntu Setup and Backup
This is a personal step-by-step for installing a new machine or just refrehsing my Ubuntu setup. If you feel it useful or have any feedback, please drop a line :)

For some context, I'm usuing the [laptop-backup-scripts](https://github.com/metodiew/dotfiles/tree/master/Toolbox/Ubuntu/laptop-backup-scripts) set of scripts here where I backup my laptop on a weekly basic and I can easily restore the setup just like it was before.

Once we have the new system/laptop in place, we are going to follow the steps below.

## Install Software, Programs, Tools
We have to start with some of the tools and software we'll be using

* Enable SSH `sudo apt install openssh-server -y`
* Git `sudo apt-get install git`
* Install **Dropbox**
  * Check the Selective Sync settings
  * We'll need this one to start syncing files and folders as we'll need them below

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
* Todost app
* RescueTime
* Grammarly - do not forget to login, otherwise the stats will be lost :)
* [ack](https://metodiew.com/install-ack-on-ubuntu/)
* [DevriX Asana Chrome Extension](https://github.com/DevriX/dx-chrome-asana-task-template) - `git clone git@github.com:DevriX/dx-chrome-asana-task-template.git`
* [Albert](https://superuser.com/questions/1560683/how-to-install-albert-keyboard-launcher)
  * Restore the config file - `.config/albert/albert.conf`
* [Notification Clock with time zones](sudo apt install gnome-clocks)

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
* FileZilla
* Poedit
* Gnome Tweaks Tools
* [Ubuntu Notification Shortcut](https://github.com/metodiew/ubuntu-notification-shortcut)
* [Write](https://www.styluslabs.com/download/)
* [Peek](https://github.com/phw/peek)
* Spotify
* VLC
* [Screen Rotate](https://extensions.gnome.org/extension/5389/screen-rotate/)
* ~~Steam~~
  * ~~CSGO~~
* ~~Rhythmbox~~
* ~~Virtual Box~~
* ~~Gimp~~
* ~~pCloud~~

## Misc and General Items
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
