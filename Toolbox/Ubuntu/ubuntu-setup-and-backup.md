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
git clone git@github.com:metodiew/dotfiles.git
```

Apply the dotfiles to my machine
Go to the ~ folder and delete the existing files
```
cd ~/
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
* ~~Hamster~~

### Communication
* Slack
* Viber
  * Potential fix for Viber not starting [here](https://askubuntu.com/a/1403956/225076)
* Zoom
* Skype, *not required*
* ~~[Skype 2](http://blog.metodiew.com/vtora-skype-instantsiya-secondary-skype-pod-ubuntu-12-04/)~~

### Development
All needed dev tools, programs and helpful gadgets

* Install [Visual Studio Code](https://linuxiac.com/install-visual-studio-code-on-ubuntu-22-04/)
* NPM install
  ```
  sudo apt install npm
  sudo apt install nodejs
  ```
* LAMP stack
  * [Ubuntu LAMP Stack](https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mysql-php-lamp-stack-on-ubuntu-22-04) or a newer version
  * Fix the [MySQL Pssword](https://stackoverflow.com/questions/50691977/how-to-reset-the-root-password-in-mysql-8-0-11) or an alternative version
  * Install [phpMyAdmin](https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-on-ubuntu-22-04) or an alternative version
* [WP-CLI](http://wp-cli.org/#installing)
* Gulp: `npm install gulp -g`
* Node
  * run this in order to make sure node is working properly `sudo ln -s /usr/bin/nodejs /usr/bin/node`
* Xdebug
* Sass/Compass
  * We need to install Ruby first: `sudo apt-get install ruby-full`
  * Then: `sudo gem install sass --no-user-install`
* [Git Open] - `npm install --global git-open`
* [nvm](https://github.com/nvm-sh/nvm/blob/master/README.md#install--update-script)
* ~~SVN~~
* ~~Vagrant~~
* ~~VVV~~
* ~~Grunt `npm install -g grunt-cli`~~


### Tools and Software
Some general tools which is hard to be categorized

* Guake  
  * Restore the Guake Preference with:  
  `guake --restore-preferences ~/Dropbox/Backup\ Files/Config\ Files/guake-preferences`
* Vim
* Torguard
* [CopyQ clipboard](https://github.com/hluk/CopyQ)
* Dropbox
* FileZilla
* Poedit
* Gnome Tweaks Tools
* [Write](https://www.styluslabs.com/download/)
* [Peek](https://github.com/phw/peek)
* Spotify
* VLC
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
