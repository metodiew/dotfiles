# modprobe rtl8723be aliases
alias modproberm="sudo modprobe -r rtl8723be"
alias modprobeadd="sudo modprobe rtl8723be"

### Useful commands ###
# an easy way to open D partition
export hdd=/mnt/5DB56B841BB28CF1

# an easy way to use sass --watch
alias sasswatch="sass --watch sass/master.scss:css/master.css --style compressed"
alias sasswatchnorm="sass --watch sass/master.scss:css/master.css"

### WP-Cli Tab completions ###
source /home/metodiew/.scripts/wp-completion.bash

### Git Stuff ###

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

# Add git branch if its present to PS1
parse_git_branch() {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

if [ "$color_prompt" = yes ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(parse_git_branch)\[\033[00m\]\$ '
else
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(parse_git_branch)\$ '
fi
unset color_prompt force_color_prompt

### Git Ignore CHMOD changes ###
git config core.fileMode false

### Git Commands ###
alias gullos="git pull origin staging"
alias gullom="git pull origin master"
alias gullod="git pull origin develop"
alias gushos="git push origin staging"
alias gushom="git push origin master"
alias gushod="git push origin develop"
alias gibra="git branch"
alias gista="gibra && git status"
alias gchs="git checkout staging"
alias gchm="git checkout master"
alias gadd="git add"
alias gommit="sh ~/.scripts/pre-commit && git commit -m"

# Grunt install/setuo
alias dxgruntinstall="npm install grunt-contrib-sass grunt-contrib-watch grunt-contrib-jshint grunt-autoprefixer"

# Android SDK
export PATH=${PATH}:/mnt/5DB56B841BB28CF1/Downloads/Android/android-sdk-linux/tools
export PATH=${PATH}:/mnt/5DB56B841BB28CF1/Downloads/Android/android-sdk-linux/platform-tools

