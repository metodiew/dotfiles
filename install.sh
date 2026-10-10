#!/usr/bin/env bash
#
# Symlink everything under .local and .config into $HOME, same structure.
#
# Usage:
#   ./install.sh             # link what is missing, leave real files alone
#   ./install.sh --dry-run   # print what would happen, change nothing
#   ./install.sh --force     # replace real files too, old one kept as <name>.bak
#
# *.example files are templates to copy and fill in, so they are never linked.
# .config/rescuetime/env is the filled-in copy and stays out of the repo.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORCE=0
DRY=0

for arg in "$@"; do
  case "$arg" in
    --force)      FORCE=1 ;;
    -n|--dry-run) DRY=1 ;;
    -h|--help)    sed -n '3,11s/^# \{0,1\}//p' "$0"; exit 0 ;;
    *)            printf 'Unknown option: %s\n' "$arg" >&2; exit 2 ;;
  esac
done

run() { (( DRY )) || "$@"; }

linked=0 skipped=0

while IFS= read -r -d '' src; do
  rel="${src#"$REPO"/}"
  dest="$HOME/$rel"

  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    printf 'OK     %s\n' "$rel"
    continue
  fi

  if [[ -d "$dest" && ! -L "$dest" ]]; then
    printf 'SKIP   %s (a directory is in the way)\n' "$rel" >&2
    skipped=$(( skipped + 1 ))
    continue
  fi

  if [[ -e "$dest" && ! -L "$dest" ]]; then
    if (( ! FORCE )); then
      printf 'SKIP   %s (real file exists, use --force)\n' "$rel"
      skipped=$(( skipped + 1 ))
      continue
    fi
    printf 'BACKUP %s -> %s.bak\n' "$rel" "$rel"
    run mv "$dest" "$dest.bak"
  fi

  run mkdir -p "$(dirname "$dest")"
  run ln -sfn "$src" "$dest"
  printf 'LINK   %s\n' "$rel"
  linked=$(( linked + 1 ))
done < <(find "$REPO/.local" "$REPO/.config" -type f ! -name '*.example' -print0 | sort -z)

printf '\n%s linked, %s skipped%s\n' "$linked" "$skipped" "$( (( DRY )) && echo ' (dry run)' || true )"
