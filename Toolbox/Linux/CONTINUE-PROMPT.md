# Handoff prompt — paste into a fresh Claude chat to continue the reinstall

I'm Stanko. I'm reinstalling my laptop and lost access to my previous chat (it was in Claude Code on the
machine I'm wiping). Continue helping me from this handoff.

## Context
- Machine: Lenovo ThinkPad X1 Yoga Gen 6, i7-1185G7, Samsung NVMe SSD.
- Reinstalling **Linux Mint 22.3 Cinnamon** with **LUKS full-disk encryption** (migrating off eCryptfs,
  which caused I/O-stall freezes; LUKS is AES-NI accelerated, ~5700 MiB/s, no perf hit on NVMe).
- Recovery model: everything is in **GitHub (public `metodiew/dotfiles` repo)** + **Dropbox**. No external
  disk. Backup is verified complete and Dropbox was "Up to date" before wiping.

## Where I am (edit this)
Making the bootable USB / installing / restoring — I'll tell you.

## Current blocker: USB
The Mint live installer froze at the **language-selection screen**; the medium check reported the USB
**disconnected on its own**. The ISO write was verified byte-for-byte (`cmp` passed) — so it's NOT bad data;
the cheap 8GB stick (wrote at only 9.3 MB/s) is dropping off the bus under load. Fixes to try:
1. Different USB port, ideally **USB 2.0**, no hub/dock; reseat firmly.
2. Do NOT run "Check the integrity of the medium" — just pick **"Start Linux Mint"**.
3. If it still drops, use a **different/better USB stick** and rewrite the ISO
   (`sudo dd if=<mint.iso> of=/dev/sdX bs=4M status=progress conv=fsync` — sdX = the USB, NOT nvme0n1).

## Key resources (work from any browser)
- Setup guide + **START HERE** bootstrap: https://github.com/metodiew/dotfiles/blob/master/Toolbox/Linux/linux-setup-and-backup.md
- Full manual restore fallback: https://github.com/metodiew/dotfiles/blob/master/Toolbox/Linux/RESTORE-MASTER-REFERENCE.md
- Same docs also in `~/Dropbox/Backup Files/` (luks-migration-plan.md, RESTORE-MASTER-REFERENCE.md) once Dropbox syncs.

## Restore order (dotfiles repo is PUBLIC → clones over HTTPS with NO SSH key — that's the bootstrap unlock)
1. Install Mint with LUKS ("Encrypt the new installation"), passphrase written offline (no recovery if lost).
2. `sudo apt update && sudo apt install -y git openssh-server curl zip unzip build-essential`
3. `mkdir -p ~/Software && git clone https://github.com/metodiew/dotfiles.git ~/Software/dotfiles`
4. Install Dropbox, log in. Slow wifi → in Selective Sync UNCHECK `WWW Backup`, `Pictures`, `Downloads`,
   `Videos`, `Music`, `Books` (pull later). Let `Backup Files/Config Files` sync first.
5. Restore SSH keys: unzip `~/Dropbox/Backup Files/Config Files/ssh folder/*.zip` into `~/.ssh`;
   `chmod 700 ~/.ssh && chmod 600 ~/.ssh/*`.
6. `bash ~/Software/dotfiles/Toolbox/Linux/laptop-backup-scripts/dropbox-exclude-restore.sh`
7. `bash ~/Software/dotfiles/Toolbox/Linux/provision.sh`
   (packages at CURRENT versions, dotfiles, ~/→Dropbox symlinks, clone me + control-room, VS Code/Cursor
   settings+extensions, Guake autostart, swappiness=10, NetworkManager, ~/certs, service-account key,
   dconf desktop settings + Nemo favorites + CopyQ + Claude CLI)
8. LAMP finish (manual): install Apache+PHP+MySQL, `a2enmod rewrite`; restore Apache sites-available +
   `/etc/hosts` from Config Files; extract projects from
   `Backup Files/WWW Backup/Apache/www-directory-backup/20260801/*.zip` into `/var/www/html`; import each
   `*-db.zip` (WP DB name = wp-config DB_NAME) + `SQLs/20260801.{timetracker,velocity_dashboard}.zip`;
   unzip `certs-*.zip` to `~/certs` and trust `~/certs/myCA.pem` in the browser/system.
9. `bash ~/Software/dotfiles/Toolbox/Linux/laptop-backup-scripts/dropbox-restore-tiered.sh phase2` (pull www/media).

## Key facts
- MySQL local dev creds: **root / root**.
- Certs at `~/certs`; Apache references `/home/metodiew/certs/*.crt` by absolute path. New domain:
  `~/certs/install-certs.sh local.example.com`.
- Claude Code backup is in `Backup Files/Config Files/Claude/` (latest zip + claude.json).
- If any script fails, `RESTORE-MASTER-REFERENCE.md` has the manual command for every step.

Please continue: first get my USB to boot, then walk me through the restore step by step.
