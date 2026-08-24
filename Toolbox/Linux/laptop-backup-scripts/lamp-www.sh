#!/bin/bash
#
# lamp-www.sh — LAMP stack + on-demand web project restore (phase 2 of restore.sh).
#
# /var/www/html starts FRESH after the reinstall; projects are restored one by one
# from the latest Dropbox snapshot when actually needed — never all 26 at once.
#
# Usage: setup | list | pick | restore <project>...
#   setup            install Apache+MySQL+PHP, conf, hosts merge, nvm/WP-CLI
#   list             show restorable projects + standalone DBs
#   pick             interactive numbered picker
#   restore <p>...   restore specific project(s): files + DB + vhost
# shellcheck disable=SC2010,SC2012  # ls pipelines on our own date-stamped backup zips are fine
set -uo pipefail
BACKUP="$HOME/Dropbox/Backup Files"
WWW="$BACKUP/WWW Backup"
log()     { printf '\n\033[1;35m==> %s\033[0m\n' "$*"; }
confirm() { local a; read -rp "$1 [y/N] " a; [[ ${a,,} == y* ]]; }

latest_dir() { ls -1d "$WWW/Apache/www-directory-backup/"*/ 2>/dev/null | sort | tail -1; }

copy_vhosts() {  # newest apache2-*.zip -> /etc/apache2/sites-available (shared by setup + restore)
  local az t
  az=$(ls -1t "$BACKUP/Config Files/Apache Conf/"apache2-*.zip 2>/dev/null | head -1 || true)
  [ -n "$az" ] || { echo "  NOTE: no apache2-*.zip at Config Files/Apache Conf"; return 1; }
  t=$(mktemp -d)
  unzip -o "$az" -d "$t" >/dev/null
  # skip stock 000-default (already present) and phpmyadmin (wired via a2enconf in setup)
  find "$t" -name '*.conf' ! -name 000-default.conf ! -name phpmyadmin.conf \
    -exec sudo cp {} /etc/apache2/sites-available/ \;
  rm -rf "$t"
  echo "  vhosts copied from $(basename "$az")"
}

ensure_hosts() {  # $1 = vhost conf path: make sure every ServerName/Alias resolves locally
  local dom
  grep -hoP '^\s*Server(Name|Alias)\s+\K\S+' "$1" 2>/dev/null | sort -u | while read -r dom; do
    if ! grep -qw "$dom" /etc/hosts; then
      printf '127.0.0.1\t%s\n' "$dom" | sudo tee -a /etc/hosts >/dev/null
      echo "  hosts entry added: 127.0.0.1 $dom"
    fi
  done
}

# --- setup -------------------------------------------------------------------
setup() {
  log "LAMP packages"
  sudo apt update
  sudo apt install -y apache2 mysql-server php libapache2-mod-php \
    php-mysql php-curl php-gd php-xml php-mbstring php-zip php-intl
  sudo a2enmod rewrite ssl headers >/dev/null

  log "PHP upload limits"
  local ini
  ini=$(ls /etc/php/*/apache2/php.ini 2>/dev/null | head -1 || true)
  [ -n "$ini" ] && sudo sed -i \
    -e 's/^upload_max_filesize.*/upload_max_filesize = 64M/' \
    -e 's/^post_max_size.*/post_max_size = 64M/' "$ini"

  log "MySQL root/root (local dev)"
  sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root'; FLUSH PRIVILEGES;" 2>/dev/null \
    || sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root'; FLUSH PRIVILEGES;" \
    || echo "  NOTE: root auth already password-based? Test: mysql -uroot -proot -e 'select 1'"

  log "phpMyAdmin Apache wiring (pkglist installs it BEFORE Apache — conf never links)"
  if [ -f /etc/phpmyadmin/apache.conf ]; then
    [ -e /etc/apache2/conf-available/phpmyadmin.conf ] || \
      sudo ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
    sudo a2enconf phpmyadmin >/dev/null 2>&1 || true
    echo "  http://localhost/phpmyadmin enabled"
  fi

  log "Apache vhosts from backup (newest apache2-*.zip in Apache Conf)"
  copy_vhosts || true

  log "/etc/hosts merge (review the diff!)"
  local h
  h=$(ls -1t "$BACKUP/Config Files/Hosts/"* 2>/dev/null | head -1 || true)
  if [ -n "$h" ]; then
    diff -u /etc/hosts "$h" || true
    if confirm "Replace /etc/hosts with $(basename "$h")?"; then
      sudo cp /etc/hosts /etc/hosts.pre-restore
      sudo cp "$h" /etc/hosts
    else
      echo "  kept current /etc/hosts (backup at $h)"
    fi
  fi

  log "nvm + node LTS + WP-CLI"
  if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  fi
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && nvm install --lts
  if ! command -v wp >/dev/null 2>&1; then
    curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar && sudo mv wp-cli.phar /usr/local/bin/wp
  fi

  # Global npm tools. A fresh nvm/node install starts empty, so these vanish in a
  # reinstall and only surface when a command is missing (git open, 2026-08).
  # npmlist.txt is written by the weekly backup; the fallback list is the minimum.
  local npmlist="$BACKUP/Config Files/npmlist.txt"
  if [ -f "$npmlist" ]; then
    echo "  restoring global npm packages from $(basename "$npmlist")"
    xargs -r npm install -g < "$npmlist"
  else
    npm install -g git-open >/dev/null 2>&1 && echo "  installed global npm: git-open"
  fi

  sudo systemctl restart apache2 mysql
  log "LAMP setup done. Now: lamp-www.sh pick"
}

# --- listing helpers ---------------------------------------------------------
projects() {  # all restorable project names from the latest snapshot (incl. DB-only ones)
  local d; d=$(latest_dir)
  [ -n "$d" ] || { echo "WWW Backup not synced yet" >&2; return 1; }
  ls "$d" | sed 's/-[0-9]\{8\}\(-db\)\{0,1\}\.zip$//' | sort -u
}

sqls() {  # standalone DBs: "20260801.timetracker.zip" -> "timetracker"
  ls "$WWW/Apache/SQLs/" 2>/dev/null | sed 's/^[0-9]\{8\}\.//; s/\.zip$//' || true
}

list() {
  echo "Projects in $(latest_dir):"
  projects | sed 's/^/  /'
  echo "Standalone DBs:"
  sqls | sed 's/^/  db:/'
}

# --- restore -----------------------------------------------------------------
import_sql() {  # $1=zip $2=dbname
  local t sql
  t=$(mktemp -d)
  unzip -o "$1" -d "$t" >/dev/null
  sql=$(find "$t" -name '*.sql' | head -1)
  [ -n "$sql" ] || { echo "  no .sql inside $(basename "$1")"; rm -rf "$t"; return 1; }
  mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS \`$2\`"
  mysql -uroot -proot "$2" < "$sql" && echo "  DB '$2' imported"
  rm -rf "$t"
}

restore() {
  local d p z dbz wpc dbname v ans force=0
  if [ "${1:-}" = "--force" ] || [ "${1:-}" = "-f" ]; then force=1; shift; fi
  d=$(latest_dir)
  [ -n "$d" ] || { echo "WWW Backup not synced yet"; return 1; }
  # self-heal: if sites-available has no project vhosts yet, pull them from backup
  if ! ls /etc/apache2/sites-available/ 2>/dev/null | grep -vE '^(000-default|default-ssl)\.conf$' | grep -q .; then
    copy_vhosts || true
  fi
  if [ "${1:-}" = "all" ]; then   # expand 'all' to every project + standalone DB
    local -a everything
    mapfile -t everything < <(projects; sqls)
    set -- "${everything[@]}"
  fi

  # UPFRONT SCAN: decide override/skip for every existing item BEFORE any work starts,
  # so the actual restore then runs unattended.
  local -a queue=()
  local exists
  for p in "$@"; do
    exists=0
    if sqls | grep -qx "$p"; then
      [ -n "$(mysql -uroot -proot -N -e "SHOW DATABASES LIKE '$p'" 2>/dev/null)" ] && exists=1
    elif [ -d "/var/www/html/$p" ]; then
      exists=1
    fi
    if [ "$exists" = 1 ] && [ "$force" != 1 ]; then
      read -rp "'$p' already exists — [o]verride (reset files+DB to backup) or [s]kip? [s] " ans
      ans=${ans,,}; ans=${ans//[^a-z]/}   # tolerate '[o]', 'O', ' o ' etc.
      case "$ans" in
        o|override) queue+=("$p") ;;
        *) echo "  will skip $p" ;;
      esac
    else
      queue+=("$p")
    fi
  done
  [ ${#queue[@]} -gt 0 ] || { echo "Nothing to restore."; return 0; }
  echo; echo "Restoring: ${queue[*]}"

  for p in "${queue[@]}"; do
    log "Restoring: $p"
    if sqls | grep -qx "$p"; then   # standalone DB (timetracker, velocity_dashboard)
      import_sql "$(ls "$WWW/Apache/SQLs/"*."$p".zip | head -1)" "$p"
      continue
    fi
    z=$(ls "$d/$p"-[0-9]*.zip 2>/dev/null | grep -v -- '-db\.zip$' | head -1 || true)
    dbz=$(ls "$d/$p"-[0-9]*-db.zip 2>/dev/null | head -1 || true)
    if [ -z "$z" ] && [ -z "$dbz" ]; then
      echo "  unknown project: $p (see: $0 list)"; continue
    fi
    if [ -n "$z" ]; then
      sudo unzip -o "$z" -d /var/www/html >/dev/null && echo "  files -> /var/www/html/$p"
      sudo chown -R "$USER":www-data "/var/www/html/$p"
    fi
    dbname=""
    if [ -n "$dbz" ]; then
      wpc=$(find "/var/www/html/$p" -maxdepth 2 -name wp-config.php 2>/dev/null | head -1 || true)
      # head -1: some configs define extra *_DB_NAME-style constants (e.g. a sync DB) —
      # only the first DB_NAME is the site database
      [ -n "$wpc" ] && dbname=$(grep -oP "DB_NAME'\s*,\s*'\K[^']+" "$wpc" | head -1 || true)
      if [ -z "$dbname" ]; then
        read -rp "  DB name for $p [default: $p]: " dbname
        dbname=${dbname:-$p}
      fi
      import_sql "$dbz" "$dbname"
      # production clones wake up with cache preloaders that crawl the whole site
      # locally (WP Rocket melted 8 cores during the 2026-08 restore) — disable them
      if [ -n "$wpc" ] && command -v wp >/dev/null 2>&1; then
        wp --path="/var/www/html/$p" plugin deactivate wp-rocket >/dev/null 2>&1 \
          && echo "  wp-rocket deactivated (local dev doesn't need cache preloading)"
        # no local SMTP on purpose — also disable 3rd-party SMTP bridges so a prod
        # clone can never send real mail from localhost
        for smtp in wp-mail-smtp easy-wp-smtp post-smtp wp-ses fluent-smtp sendgrid-email-delivery-simplified mailgun; do
          wp --path="/var/www/html/$p" plugin deactivate "$smtp" >/dev/null 2>&1 \
            && echo "  $smtp deactivated (no emails from localhost)"
        done
      fi
    fi
    v=$(ls /etc/apache2/sites-available/*"$p"* 2>/dev/null | head -1 || true)
    if [ -n "$v" ]; then
      sudo a2ensite "$(basename "$v" .conf)" >/dev/null && echo "  vhost enabled: $(basename "$v")"
      ensure_hosts "$v"
    else
      echo "  NOTE: no vhost matched '*$p*' — if this site needs one, enable manually:"
      echo "        available: $(ls /etc/apache2/sites-available/ | grep -v 000-default | tr '\n' ' ')"
    fi
    # WP-core dev sites (wordpress, wpplayground, wpbleeding, ...) share wordpress-core.conf
    case "$p" in
      wordpress|wp*)
        if [ -f /etc/apache2/sites-available/wordpress-core.conf ]; then
          sudo a2ensite wordpress-core >/dev/null 2>&1 && echo "  vhost enabled: wordpress-core.conf"
          ensure_hosts /etc/apache2/sites-available/wordpress-core.conf
        fi ;;
    esac
  done
  sudo systemctl restart apache2 2>/dev/null || true
}

pick() {
  local -a items sel
  local i
  mapfile -t items < <(projects; sqls | sed 's/^/db:/')
  [ ${#items[@]} -gt 0 ] || { echo "Nothing to restore (WWW Backup synced?)"; return 1; }
  echo "Available to restore:"
  for i in "${!items[@]}"; do printf '  %2d) %s\n' $((i + 1)) "${items[$i]}"; done
  read -rp "Numbers to restore (space-separated, 'a' = ALL, empty = none): " -a sel
  for i in "${sel[@]:-}"; do
    [ -n "$i" ] || continue
    if [ "$i" = "a" ] || [ "$i" = "all" ]; then restore all; break; fi
    restore "${items[$((i - 1))]#db:}"
  done
}

# --- dispatch ----------------------------------------------------------------
case "${1:-}" in
  setup)   setup ;;
  list)    list ;;
  pick)    pick ;;
  restore) shift; [ $# -ge 1 ] || { echo "restore needs project name(s)"; exit 1; }
           restore "$@" ;;
  *) echo "Usage: $0 setup | list | pick | restore <project>..."; exit 1 ;;
esac
