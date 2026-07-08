#!/usr/bin/env bash
# Spice Road — weather cache check + fetch, extracted from welcome-banner.zsh
# so it has exactly one implementation, callable from anywhere (the banner,
# or an optional early prefetch hook) without duplicating the lock/staleness
# logic in two places that could drift out of sync.
#
# Runs as a plain bash subprocess (not sourced into an interactive shell),
# so backgrounding here never touches the interactive shell's job table —
# no &! needed, unlike the old inline version in welcome-banner.zsh.
#
# Prints the cached weather line (possibly empty, if never successfully
# fetched yet) and returns immediately either way.

SPICE_DIR="$HOME/.cache/spice-road"
CACHE="$SPICE_DIR/weather"
LOCK="$SPICE_DIR/weather.lock"
MAX_AGE=1500  # 25 minutes

mkdir -p "$SPICE_DIR"

age=999999
if [ -f "$CACHE" ]; then
  age=$(( $(date +%s) - $(stat -c %Y "$CACHE" 2>/dev/null || echo 0) ))
fi

if [ "$age" -gt "$MAX_AGE" ] && [ ! -e "$LOCK" ]; then
  touch "$LOCK"
  nohup bash -c "
    curl -s --max-time 3 'wttr.in/?format=3' > '$CACHE.tmp' 2>/dev/null
    # sanity-check the response before trusting it — a captive portal,
    # proxy error page, or blocked-host message can return HTTP 200 with
    # garbage body, which curl alone won't detect as a failure
    if grep -qE '°[CF]' '$CACHE.tmp' 2>/dev/null \
       && [ \$(wc -c < '$CACHE.tmp' 2>/dev/null || echo 0) -lt 200 ]; then
      mv '$CACHE.tmp' '$CACHE'
    else
      rm -f '$CACHE.tmp'
    fi
    rm -f '$LOCK'
  " >/dev/null 2>&1 &
fi

if [ -s "$CACHE" ]; then
  cat "$CACHE"
fi
exit 0
