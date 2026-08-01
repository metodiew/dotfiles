#!/bin/bash
#
# dropbox-restore-tiered.sh — two-phase Dropbox restore after a reinstall.
#
# Idea: get a USABLE machine fast by syncing only the small essentials first, and
# defer the big folders (WWW backup, media) until the machine is set up / on good wifi.
#
#   phase1  → exclude the big folders so ONLY essentials sync (configs, keys, repos, dotfiles)
#   phase2  → re-include the big folders to pull them (run later)
#
# The PERMANENT no-sync folders (ZZ, DevriX, veda, ...) are handled separately by
# dropbox-exclude-restore.sh and always stay excluded — this script is only about the
# big-but-eventually-wanted folders.
#
# Note: the very first phase1 is often easiest in the Dropbox first-run Selective Sync
# dialog (just uncheck these folders before it downloads). This script is the scriptable
# equivalent, and the only clean way to do phase2 (re-include) later.
#
# Usage: dropbox-restore-tiered.sh phase1 | phase2

set -uo pipefail
DB="$HOME/Dropbox"

# Big folders to DEFER during the initial restore. Edit to taste.
DEFER=(
  "$DB/Backup Files/WWW Backup"
  "$DB/Pictures"
  "$DB/Downloads"
  "$DB/Videos"
  "$DB/Music"
  "$DB/Books"
)

command -v dropbox >/dev/null 2>&1 || { echo "Dropbox CLI not found — install and log in first."; exit 1; }

case "${1:-}" in
  phase1)
    echo "Phase 1 — deferring big folders (only essentials will sync):"
    for d in "${DEFER[@]}"; do
      echo "  defer: $d"
      dropbox exclude add "$d" >/dev/null 2>&1 || echo "    (not ready yet — retry after Dropbox finishes indexing)"
    done
    echo "Essentials sync now (Config Files, Personal Repos, Documents). Run '$0 phase2' later for the rest."
    ;;
  phase2)
    echo "Phase 2 — pulling the deferred big folders:"
    for d in "${DEFER[@]}"; do
      echo "  sync: $d"
      dropbox exclude remove "$d" >/dev/null 2>&1 || echo "    (skip: $d)"
    done
    ;;
  *)
    echo "Usage: $0 phase1 | phase2"; exit 1 ;;
esac
echo; dropbox status 2>/dev/null | head -3
