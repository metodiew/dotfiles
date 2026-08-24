#!/bin/bash
#
# dropbox-restore-tiered.sh — phased Dropbox restore after a reinstall.
#
# Dropbox is 200+GB: a usable machine must never wait on a full sync. Groups map
# to restore.sh phases:   www → phase2   work → phase3   media → phase4.
# Pictures is GATED (restore.sh phase4 asks first) and Videos is NEVER auto-synced.
# The PERMANENT no-sync folders (ZZ, DevriX, veda, ...) are handled separately by
# dropbox-exclude-restore.sh and always stay excluded.
#
# Usage: defer-all | undefer www|work|media... | status
# Legacy aliases: phase1 → defer-all, phase2 → undefer www work media
set -uo pipefail
DB="$HOME/Dropbox"

GROUP_www=("$DB/Backup Files/WWW Backup")
GROUP_work=("$DB/Documents" "$DB/Downloads" "$DB/WORK")
GROUP_media=("$DB/Music" "$DB/Books")
GATED=("$DB/Pictures")            # un-deferred only by restore.sh phase4 after explicit y/n
NEVER=("$DB/Videos")              # manual pull only

command -v dropbox >/dev/null 2>&1 || { echo "Dropbox CLI not found."; exit 1; }

defer_all() {
  echo "Deferring big folders (essentials only will sync):"
  local d
  for d in "${GROUP_www[@]}" "${GROUP_work[@]}" "${GROUP_media[@]}" "${GATED[@]}" "${NEVER[@]}"; do
    echo "  defer: $d"
    dropbox exclude add "$d" >/dev/null 2>&1 || echo "    (not ready — retry after Dropbox finishes indexing)"
  done
}

undefer_group() {
  local g="$1" d
  local -a items=()
  case "$g" in
    www)   items=("${GROUP_www[@]}") ;;
    work)  items=("${GROUP_work[@]}") ;;
    media) items=("${GROUP_media[@]}") ;;
    *) echo "Unknown group: $g (www|work|media)"; return 1 ;;
  esac
  echo "Un-deferring group '$g':"
  for d in "${items[@]}"; do
    echo "  sync: $d"
    dropbox exclude remove "$d" >/dev/null 2>&1 || echo "    (skip: $d)"
  done
}

case "${1:-}" in
  defer-all|phase1) defer_all ;;
  undefer)
    shift
    [ $# -ge 1 ] || { echo "undefer needs a group: www|work|media"; exit 1; }
    for g in "$@"; do undefer_group "$g"; done ;;
  phase2)
    for g in www work media; do undefer_group "$g"; done
    echo "NOTE: Pictures (gated) and Videos (never) NOT included — use restore.sh phase4." ;;
  status) dropbox exclude list ;;
  *) echo "Usage: $0 defer-all | undefer www|work|media... | status"; exit 1 ;;
esac
echo; dropbox status 2>/dev/null | head -3
