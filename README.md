# Stanko Metodiev dotfiles and my Toolbox
This is my collection of dotfiles, scripts, useful commands and scripts. The repository contains a combination of some bash scripts, automated tools, dotfiles and the like.

Here you can find plenty of different single files, folders, collections and the like and it's something I'm using on a daily basis. If you find some of these useful, feel free to re-use, modify and share them.

There is a folder *Toolbox* where you can find snippets, automated scripts and some tips and tricks.

Feedback is always welcome, so feel free to share your thoughts.

## Install

`install.sh` links every file under `.local` and `.config` into `$HOME` with the same structure, so a script in `.local/bin` lands on the `PATH` and a config in `.config` lands where its program reads it. It creates missing directories and needs nothing beyond bash and coreutils.

```
./install.sh             # link what is missing, leave real files alone
./install.sh --dry-run   # print what would happen, change nothing
./install.sh --force     # replace real files too, old one kept as <name>.bak
```

A real file already sitting at the destination is skipped unless you pass `--force`, and a symlink that points somewhere else is repointed at the repo. Files ending in `.example` are templates and are never linked: copy them by hand and fill them in, as described in [RESCUETIME.md](RESCUETIME.md) for the API key.

The dotfiles in the repo root (`.bashrc`, `.gitconfig` and the rest) are not handled by `install.sh`.
