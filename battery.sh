#!/usr/bin/env bash
# Spice Road — instant battery reader for the Starship prompt.
#
# This script is what Starship actually calls on every single prompt render.
# It NEVER calls powershell.exe itself — it only ever reads a small cache
# file. If the cache is missing or stale, it forks a fully detached
# background refresh (battery-refresh.sh) and returns immediately with
# whatever it already has. Worst case cost here is a stat + a cat + a
# non-blocking fork — not a PowerShell round-trip.

SPICE_DIR="$HOME/.cache/spice-road"
CACHE="$SPICE_DIR/battery"
LOCK="$SPICE_DIR/battery.lock"
REFRESHER="$HOME/.config/starship-helpers/battery-refresh.sh"
MAX_AGE=120   # seconds — battery % doesn't change fast, no need to poll often

mkdir -p "$SPICE_DIR"

age=999999
if [ -f "$CACHE" ]; then
  age=$(( $(date +%s) - $(stat -c %Y "$CACHE" 2>/dev/null || echo 0) ))
fi

# Remove lock if it's stale (older than 60 seconds) to prevent a hung
# powershell.exe from freezing the battery reading forever.
if [ -e "$LOCK" ] && [ "$(($(date +%s) - $(stat -c %Y "$LOCK" 2>/dev/null || echo 0)))" -gt 60 ]; then
  rm -f "$LOCK"
fi

if [ "$age" -gt "$MAX_AGE" ] && [ ! -e "$LOCK" ] && [ -x "$REFRESHER" ]; then
  touch "$LOCK"
  nohup "$REFRESHER" "$CACHE" "$LOCK" >/dev/null 2>&1 &
fi

if [ -s "$CACHE" ]; then
  cat "$CACHE"
else
  exit 1   # empty output — Starship hides the module entirely until first success
fi
