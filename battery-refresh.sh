#!/usr/bin/env bash
# Spice Road — detached battery refresher. NEVER called directly by
# Starship — only ever forked in the background by battery.sh. This is
# where the actual slow part lives: asking Windows via powershell.exe,
# since WSL2 has no direct hardware battery access at all.

CACHE="$1"
LOCK="$2"

pct=$(powershell.exe -NoProfile -Command \
  "(Get-CimInstance -ClassName Win32_Battery).EstimatedChargeRemaining" \
  2>/dev/null | tr -d '\r\n ')

if [[ "$pct" =~ ^[0-9]+$ ]]; then
  printf "⚡ %s%%" "$pct" > "${CACHE}.tmp"
  mv "${CACHE}.tmp" "$CACHE"
else
  # no battery on this machine (or PowerShell interop unavailable) —
  # remove any stale cache so the module stays hidden, not wrong
  rm -f "$CACHE"
fi

rm -f "$LOCK"
