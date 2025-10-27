#!/usr/bin/env bash
# Simple network change tracker for Linux
# Usage: sudo ./track_net_linux.sh [/var/tmp/nettrack]
set -euo pipefail
BASE="${1:-/var/tmp/nettrack}"
mkdir -p "$BASE"
CUR="$BASE/ss_current.txt"
PREV="$BASE/ss_prev.txt"
LOG="$BASE/changes.log"

(ss -tulpen 2>/dev/null || netstat -tulpen 2>/dev/null || true) > "$CUR"
if [ -f "$PREV" ]; then
  if ! cmp -s "$CUR" "$PREV"; then
    TS=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "\n=== Change at $TS ===" >> "$LOG"
    diff -u "$PREV" "$CUR" >> "$LOG" || true
  fi
fi
mv -f "$CUR" "$PREV"
echo "Checked. Log: $LOG"
