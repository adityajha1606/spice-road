#!/usr/bin/env zsh
# Spice Road — welcome banner.
# Sourced from .zshrc. Runs once per new interactive top-level shell (a
# fresh tab/window), not on every nested shell within one. The only
# network call (weather) follows the same non-blocking cache pattern as
# battery.sh — this script never waits on curl.

[[ -o interactive ]] || return
[[ -n "$SPICE_ROAD_SHOWN" ]] && return
export SPICE_ROAD_SHOWN=1

SR_DIR="${0:A:h}"
source "$SR_DIR/banner-art.zsh"

# ---------- color helpers (truecolor, matching palette.py) ----------
BRONZE='140;98;57'
COPPER='184;115;51'
GOLD='212;175;55'
HENNA='107;58;31'
PARCHMENT='242;230;216'
MUTED='201;183;156'
RESET=$'\033[0m'

sr_line()      { printf '\033[38;2;%sm%s\033[0m\n' "$1" "$2"; }
sr_line_bold() { printf '\033[1;38;2;%sm%s\033[0m\n' "$1" "$2"; }

sr_type() {
  # one-time typing-effect reveal — used only for the title, a few hundred
  # ms total, never repeated per-prompt, so it costs nothing ongoing
  local text="$1" color="$2" delay="${3:-0.014}"
  printf '\033[1;38;2;%sm' "$color"
  local i
  for (( i = 0; i < ${#text}; i++ )); do
    printf '%s' "${text:$i:1}"
    sleep "$delay"
  done
  printf '\033[0m'
}

# ---------- sunburst (bronze -> gold -> bronze, peaking at the equator) ----------
SR_SUNBURST_COLORS=("$BRONZE" "$COPPER" "$COPPER" "$GOLD" "$COPPER" "$COPPER" "$BRONZE")
echo
for i in {1..${#SR_SUNBURST[@]}}; do
  sr_line "${SR_SUNBURST_COLORS[$i]}" "${SR_SUNBURST[$i]}"
done
echo

# ---------- title, typed once ----------
sr_line "$BRONZE" "$SR_RULE"
printf '%*s' "$SR_TITLE_LPAD" ''
sr_type "$SR_TITLE_RAW" "$GOLD"
printf '%*s\n' "$SR_TITLE_RPAD" ''
sr_line "$BRONZE" "$SR_RULE"
echo

# ---------- dune waves ----------
sr_line "$BRONZE" "$SR_WAVES[1]"
sr_line "$HENNA"  "$SR_WAVES[2]"
echo

# ---------- divider ----------
sr_line "$BRONZE" "$SR_DIVIDER"

# ---------- weather (cached, non-blocking — never calls curl on the critical path) ----------
SR_CACHE_DIR="$HOME/.cache/spice-road"
mkdir -p "$SR_CACHE_DIR"
WEATHER_CACHE="$SR_CACHE_DIR/weather"
WEATHER_LOCK="$SR_CACHE_DIR/weather.lock"
WEATHER_MAX_AGE=1500  # 25 minutes

w_age=999999
[[ -f "$WEATHER_CACHE" ]] && w_age=$(( $(date +%s) - $(stat -c %Y "$WEATHER_CACHE" 2>/dev/null || echo 0) ))

if (( w_age > WEATHER_MAX_AGE )) && [[ ! -e "$WEATHER_LOCK" ]]; then
  touch "$WEATHER_LOCK"
  nohup zsh -c "
    curl -s --max-time 3 'wttr.in/?format=3' > '$WEATHER_CACHE.tmp' 2>/dev/null
    # sanity-check the response before trusting it — a captive portal, proxy
    # error page, or blocked-host message can return HTTP 200 with garbage
    # body, which curl alone won't detect as a failure
    if grep -qE '°[CF]' '$WEATHER_CACHE.tmp' 2>/dev/null \
       && [[ \$(wc -c < '$WEATHER_CACHE.tmp' 2>/dev/null || echo 0) -lt 200 ]]; then
      mv '$WEATHER_CACHE.tmp' '$WEATHER_CACHE'
    else
      rm -f '$WEATHER_CACHE.tmp'
    fi
    rm -f '$WEATHER_LOCK'
  " >/dev/null 2>&1 &!
fi

if [[ -s "$WEATHER_CACHE" ]]; then
  sr_line "$MUTED" "  $(cat "$WEATHER_CACHE")"
fi

# ---------- quote of the moment ----------
# Original aphorisms written for this project, deliberately not quotations
# from Dune or any existing text — see PLAN.md §10 for why.
typeset -a SR_QUOTES
SR_QUOTES=(
  "The dune that resists the wind is buried by morning."
  "A caravan's wealth is not its cargo, but the roads it has learned."
  "Spice remembers what sand forgets."
  "The bazaar sells everything except patience — bring your own."
  "Mirages lie about water, never about direction."
  "A brass lamp unpolished is still a lamp; light it anyway."
  "The oracle who speaks in certainties has stopped listening."
  "Every road through the dunes was once someone's first mistake."
  "Marigolds do not apologize for their color."
  "The wind writes on sand what stone takes a century to say."
  "A merchant's best trade is the one he almost didn't make."
  "Thirst teaches geography faster than any map."
  "The mosaic was never meant to be one piece."
  "Ash from yesterday's fire still warms tonight's tea."
  "The desert does not reward speed. It rewards attention."
  "A single spice can carry the memory of an entire harvest."
  "Those who chart the dunes soon learn the dunes do not hold still."
  "Old roads are not lost — they are waiting to be needed again."
  "Copper darkens with age; it does not weaken."
  "Every oracle was once someone who paid attention longer than most."
)
idx=$(( (RANDOM % ${#SR_QUOTES[@]}) + 1 ))
sr_line "$PARCHMENT" "  “${SR_QUOTES[$idx]}”"

sr_line "$BRONZE" "$SR_DIVIDER"
echo

# ---------- system stats ----------
# fastfetch is a C binary — near-zero overhead, run synchronously and in
# order since it's meant to be part of the immediate visual reveal, unlike
# the weather network call above.
if command -v fastfetch >/dev/null 2>&1; then
  fastfetch
  echo
fi