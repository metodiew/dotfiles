#!/bin/bash
#
# restore.sh — phased laptop restore orchestrator after a fresh Mint install.
# Design: "Backup Files/restore-phases-plan.md" (Dropbox). Companion to provision.sh.
#
#   phase1  critical setup  — SSH, git, folders, provision.sh configs, apps
#   phase2  work            — LAMP + SSL certs + web projects on demand
#   phase3  work folders    — un-defer Documents/Downloads/WORK sync
#   phase4  media           — Music now; Pictures gated; Videos manual only
#
# Usage: restore.sh phase1|phase2|phase3|phase4 | all | status | www <project>
# Idempotent: done-markers in ~/.local/state/laptop-restore (rm one to redo a phase).
# shellcheck disable=SC2012  # ls|head on our own date-stamped backup zips is fine
set -euo pipefail

DOTFILES="$HOME/Software/dotfiles"
TOOLS="$DOTFILES/Toolbox/Linux"
SCRIPTS="$TOOLS/laptop-backup-scripts"
BACKUP="$HOME/Dropbox/Backup Files"
STATE="$HOME/.local/state/laptop-restore"
mkdir -p "$STATE"

log()     { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
confirm() { local a; read -rp "$1 [y/N] " a; [[ ${a,,} == y* ]]; }
mark()    { touch "$STATE/$1.done"; }
done_p()  { [ -f "$STATE/$1.done" ]; }

# --- Phase 1: critical setup -------------------------------------------------
phase1() {
  log "PHASE 1 — critical setup"

  log "1/8 Dropbox tiering (permanent excludes + defer big folders)"
  if [ -f "$SCRIPTS/dropbox-exclude-restore.sh" ]; then
    bash "$SCRIPTS/dropbox-exclude-restore.sh" || true
  fi
  bash "$SCRIPTS/dropbox-restore-tiered.sh" defer-all || true

  log "2/8 SSH keys"
  if ! ls "$HOME/.ssh/"id_* >/dev/null 2>&1; then
    local z src
    z=$(ls -1t "$BACKUP/Config Files/ssh folder/"*.zip 2>/dev/null | head -1 || true)
    if [ -n "$z" ]; then
      rm -rf /tmp/ssh-restore && mkdir -p /tmp/ssh-restore
      unzip -o "$z" -d /tmp/ssh-restore >/dev/null
      src=$(find /tmp/ssh-restore -type d -name .ssh | head -1 || true)
      [ -n "$src" ] || src=/tmp/ssh-restore   # zip may store keys at top level
      mkdir -p "$HOME/.ssh" && cp -r "$src/." "$HOME/.ssh/"
      chmod 700 "$HOME/.ssh" && chmod 600 "$HOME/.ssh/"* && rm -rf /tmp/ssh-restore
    else
      echo "  WARN: no ssh zip found in backup"
    fi
  fi
  local sshout
  sshout=$(ssh -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 || true)
  if grep -qi "success" <<<"$sshout"; then echo "  GitHub SSH OK"
  else echo "  WARN: GitHub SSH not verified — check keys ($sshout)"; fi

  log "3/8 Git identity"
  [ -f "$DOTFILES/.gitconfig" ] && cp "$DOTFILES/.gitconfig" "$HOME/"
  [ -f "$BACKUP/Config Files/.git-commit-template.txt" ] && \
    cp "$BACKUP/Config Files/.git-commit-template.txt" "$HOME/"

  log "4/8 Folder structure + repos (bookmark targets)"
  local d
  for d in Software Downloads-No-Dropbox claude Applications; do mkdir -p "$HOME/$d"; done
  # Flameshot save dir — Dropbox ROOT. Un-exclude BEFORE mkdir (first-run selective
  # sync may have it excluded; creating a local dir inside an excluded path = conflicts).
  dropbox exclude remove "$HOME/Dropbox/Flameshot" >/dev/null 2>&1 || true
  mkdir -p "$HOME/Dropbox/Flameshot"
  # NOTE: Pictures sub-dirs (Fun and Memes, Sites Testing Images) are created in
  # phase4 AFTER Pictures is un-deferred — never mkdir inside an excluded folder.
  local -A repos=(
    ["$HOME/me"]="git@github.com:metodiew/me.git"
    ["$HOME/Software/control-room"]="git@github.com:metodiew/Control-Room.git"
    ["$HOME/Software/display-profiles"]="git@github.com:metodiew/display-profiles.git"
    # path must match the command in the restored dconf keybinding (Ctrl+Shift+J)
    ["$HOME/Software/ubuntu-notification-shortcut"]="git@github.com:metodiew/ubuntu-notification-shortcut.git"
    # add future setups here, one line each
  )
  local p
  for p in "${!repos[@]}"; do [ -d "$p" ] || git clone "${repos[$p]}" "$p"; done
  # keybinding targets must be executable or the shortcut silently does nothing
  chmod +x "$HOME/Software/ubuntu-notification-shortcut/ubuntu-notification-shortcut.sh" 2>/dev/null || true

  # display-profiles tool: install (user-level symlinks into ~/.local/bin) and
  # prefer the NEWEST conf from the backup over the repo copy (ports change with docks)
  if [ -d "$HOME/Software/display-profiles" ] && [ ! -x "$HOME/.local/bin/display-profiles" ]; then
    ( cd "$HOME/Software/display-profiles" && bash install.sh )
  fi
  [ -f "$BACKUP/display-profile.conf" ] && \
    cp "$BACKUP/display-profile.conf" "$HOME/.local/bin/display-profiles.conf"

  # Apps BEFORE provision: editors must exist when provision restores their
  # settings and reinstalls extensions (learned the hard way during the 2026-08 run)
  log "5/8 Desktop apps"
  [ -f "$SCRIPTS/install-apps.sh" ] && bash "$SCRIPTS/install-apps.sh" || echo "  install-apps.sh not present yet"

  log "6/8 provision.sh (config restore; certs section self-skips while WWW deferred)"
  bash "$TOOLS/provision.sh"

  # The Mint installer creates a tiny swap LV (1.9G in the 2026-08 install, down
  # from 31G before) — it fills under heavy work (big MySQL imports). Top it up
  # with a swapfile; hibernate is not used, so no resume= / LV resize needed.
  local swapkb
  swapkb=$(awk '/SwapTotal/{print $2}' /proc/meminfo)
  if [ "$swapkb" -lt 8388608 ] && [ ! -f /swapfile ]; then
    log "System: swap is only $((swapkb / 1024 / 1024))G — adding a 16G swapfile"
    sudo fallocate -l 16G /swapfile && sudo chmod 600 /swapfile && sudo mkswap /swapfile >/dev/null
    sudo swapon /swapfile
    grep -q '^/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null
    echo "  swap now: $(free -h | awk '/Swap/{print $2}')"
  fi

  # MUST run after provision.sh — that restores ~/.config/cinnamon wholesale from
  # the backup, which would overwrite these tweaks with whatever the backup held.
  log "7/8 Desktop tweaks (applet preferences)"
  PWRJSON="$HOME/.config/cinnamon/spices/power@cinnamon.org/power@cinnamon.org.json"
  if [ -f "$PWRJSON" ] && command -v python3 >/dev/null 2>&1; then
    python3 - "$PWRJSON" <<'PY' && echo "  battery tray: showing percentage"
import json, sys
p = sys.argv[1]
d = json.load(open(p))
d.setdefault("labelinfo", {})["value"] = "percentage"   # battery % in the tray
d.setdefault("showmulti", {})["value"] = False          # laptop only, not BT mouse/peripherals
json.dump(d, open(p, "w"), indent=4)
PY
  fi

  log "8/8 Claude Code CLI"
  command -v claude >/dev/null 2>&1 || curl -fsSL https://claude.ai/install.sh | bash
  # provision.sh section 10 already restored claude.json + ~/.claude from the backup zip.

  mark phase1
  log "PHASE 1 done. Next: restore.sh phase2 (needs network for WWW sync + LAMP)."
}

# --- Phase 2: work — LAMP + certs + projects ---------------------------------
phase2() {
  log "PHASE 2 — work: LAMP + web projects"

  log "1/4 Un-defer WWW Backup + wait for sync"
  bash "$SCRIPTS/dropbox-restore-tiered.sh" undefer www
  echo "  waiting for Dropbox 'Up to date' (Ctrl-C safe — re-run phase2 to resume)..."
  until dropbox status 2>/dev/null | grep -q "Up to date"; do sleep 15; done

  log "2/4 SSL certs -> ~/certs + trust root CA"
  local z
  z=$(ls -1t "$BACKUP/WWW Backup/"certs-*.zip 2>/dev/null | head -1 || true)
  if [ -n "$z" ]; then
    ( cd "$HOME" && unzip -o "$z" >/dev/null )
    sudo cp "$HOME/certs/myCA.pem" /usr/local/share/ca-certificates/myCA.crt
    sudo update-ca-certificates
  else
    echo "  WARN: no certs zip found — is WWW Backup synced?"
  fi

  log "3/4 LAMP setup"
  bash "$SCRIPTS/lamp-www.sh" setup

  log "4/4 Project picker (re-run any time: restore.sh www <proj> / lamp-www.sh pick)"
  bash "$SCRIPTS/lamp-www.sh" pick

  mark phase2
  log "PHASE 2 done."
  echo
  echo "########################################################################"
  echo "#  DON'T FORGET: import ~/certs/myCA.pem into Chrome:                  #"
  echo "#  Settings > Privacy & Security > Security > Manage certificates >    #"
  echo "#  Authorities > Import > trust for websites.                          #"
  echo "#  Until then, local HTTPS sites (local.*.com) show cert warnings.     #"
  echo "########################################################################"
}

# --- Phase 3: work folders ---------------------------------------------------
phase3() {
  log "PHASE 3 — work folders (background sync)"
  bash "$SCRIPTS/dropbox-restore-tiered.sh" undefer work
  mark phase3
  log "Documents/Downloads/WORK syncing in background. PHASE 3 done."
  echo
  echo "REMINDER — office VPN (needs WORK synced first):"
  echo "  cd ~/Dropbox/WORK/'DevriX Office VPN Files' && bash vpn-setup.sh"
  echo "  Setup script + certs + guide live there (kept out of this PUBLIC repo)."
  echo "  A plain .ovpn import does NOT work — the script applies the required"
  echo "  auth-type and cipher fixes."
}

# --- Phase 4: media (Pictures gated, Videos manual) --------------------------
phase4() {
  log "PHASE 4 — media (shape still evolving; Pictures gated)"
  bash "$SCRIPTS/dropbox-restore-tiered.sh" undefer media
  echo
  echo "Pictures is GATED: decide the no-sync plan first (Todoist task, Thu 2026-08-13):"
  echo "  option A: no-sync subfolder inside Pictures   option B: move archive photos to ZZ"
  if confirm "Plan decided — un-defer Pictures now?"; then
    dropbox exclude remove "$HOME/Dropbox/Pictures" 2>/dev/null || true
    mkdir -p "$HOME/Dropbox/Pictures/Fun and Memes" "$HOME/Dropbox/Pictures/Sites Testing Images"
    echo "  Pictures syncing; bookmark targets created."
  else
    echo "  Pictures stays deferred. Re-run phase4 after deciding (rm $STATE/phase4.done first)."
  fi
  echo "Videos NEVER auto-syncs. Manual pull: dropbox exclude remove '\$HOME/Dropbox/Videos'"
  mark phase4
  log "PHASE 4 done."
}

# --- Dispatch ----------------------------------------------------------------
status() {
  echo "Restore status (markers in $STATE):"
  local p
  for p in phase1 phase2 phase3 phase4; do
    if done_p "$p"; then echo "  [x] $p"; else echo "  [ ] $p"; fi
  done
  command -v dropbox >/dev/null && dropbox status 2>/dev/null | head -2
}

usage() { echo "Usage: $0 phase1|phase2|phase3|phase4 | all | status | www <project>"; exit 1; }

case "${1:-}" in
  phase1|phase2|phase3|phase4) "$1" ;;
  all)
    for p in phase1 phase2 phase3 phase4; do
      if done_p "$p"; then log "$p already done — skipping (rm $STATE/$p.done to redo)"; continue; fi
      if confirm "Run $p now?"; then "$p"
      else log "Stopped before $p. Re-run '$0 all' to continue."; break; fi
    done ;;
  status) status ;;
  www) shift; [ $# -ge 1 ] || usage; bash "$SCRIPTS/lamp-www.sh" restore "$@" ;;
  *) usage ;;
esac
