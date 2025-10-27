#!/usr/bin/env bash
# Baseline snapshot for Linux (quick triage)
# Usage: sudo ./baseline_linux.sh [/path/to/output_dir]
set -euo pipefail
TS=$(date +"%Y%m%d_%H%M%S")
OUTDIR="${1:-/var/tmp/baseline}_${TS}"
mkdir -p "$OUTDIR"

# System identity & time
{ echo "===== uname -a ====="; uname -a; 
  echo "===== date ====="; date; } > "$OUTDIR/system_info.txt"

# Users & logins
{ echo "===== who ====="; who; 
  echo "===== last -n 20 ====="; last -n 20 || true; } > "$OUTDIR/users_logins.txt"

# Processes
ps aux --sort=-%mem > "$OUTDIR/ps_aux.txt"

# Services
if command -v systemctl >/dev/null 2>&1; then
  systemctl list-units --type=service --all > "$OUTDIR/services.txt"
else
  service --status-all 2>&1 | sort > "$OUTDIR/services.txt"
fi

# Scheduled tasks
crontab -l 2>/dev/null > "$OUTDIR/crontab_root.txt" || true
for u in $(awk -F: '{print $1}' /etc/passwd); do
  crontab -u "$u" -l 2>/dev/null > "$OUTDIR/crontab_${u}.txt" || true
done
ls -l /etc/cron* > "$OUTDIR/cron_dirs.txt" 2>/dev/null || true

# Network
ss -tulpen > "$OUTDIR/ss_listening.txt" 2>/dev/null || netstat -tulpen > "$OUTDIR/ss_listening.txt" 2>/dev/null || true
ip addr show > "$OUTDIR/ip_addr.txt"
ip route show > "$OUTDIR/ip_route.txt"

# Firewall (best effort)
(iptables-save || true) > "$OUTDIR/iptables_save.txt" 2>/dev/null
(nft list ruleset || true) > "$OUTDIR/nft_ruleset.txt" 2>/dev/null

# Key configs (quick hash)
find /etc -type f -maxdepth 1 -exec sha256sum {} + 2>/dev/null > "$OUTDIR/etc_hashes_sha256.txt"
echo "Baseline saved to: $OUTDIR"
