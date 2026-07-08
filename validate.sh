#!/usr/bin/env bash
# Spice Road — health check.
#
# Every check always prints ✓ or ✗, even on failure (the earlier version
# was gated behind && and printed nothing for missing files — fixed).

PASS=0
FAIL=0

report() {
  local description="$1"
  local status="$2"
  if [ "$status" -eq 0 ]; then
    echo "✓ $description"
    PASS=$((PASS + 1))
  else
    echo "✗ $description"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== Spice Road health check ==="
echo

echo "-- files --"
[ -f ~/.config/starship.toml ]; report "starship.toml present" $?
[ -f ~/.config/spice-road/ls_colors.zsh ]; report "ls_colors.zsh present" $?
[ -f ~/.config/spice-road/welcome-banner.zsh ]; report "welcome-banner.zsh present" $?
[ -f ~/.config/spice-road/banner-art.zsh ]; report "banner-art.zsh present" $?
[ -f ~/.config/spice-road/weather-check.sh ]; report "weather-check.sh present" $?
[ -x ~/.config/starship-helpers/battery.sh ]; report "battery.sh present and executable" $?
[ -x ~/.config/starship-helpers/battery-refresh.sh ]; report "battery-refresh.sh present and executable" $?
[ -f ~/.config/fastfetch/config.jsonc ]; report "fastfetch config present" $?

echo
echo "-- commands on PATH --"
command -v starship >/dev/null 2>&1; report "starship installed" $?
command -v fastfetch >/dev/null 2>&1; report "fastfetch installed" $?
command -v fzf >/dev/null 2>&1; report "fzf installed" $?
command -v zoxide >/dev/null 2>&1; report "zoxide installed" $?
command -v eza >/dev/null 2>&1; report "eza installed" $?
{ command -v batcat >/dev/null 2>&1 || command -v bat >/dev/null 2>&1; }; report "bat/batcat installed" $?

echo
echo "-- config validity --"
zsh -n ~/.zshrc >/dev/null 2>&1; report ".zshrc syntax valid" $?

python3 -c "
import json5, sys
json5.load(open('$HOME/.config/fastfetch/config.jsonc'))
" >/dev/null 2>&1; report "fastfetch config parses (JSONC-tolerant)" $?

python3 -c "
import sys
if sys.version_info >= (3, 11):
    import tomllib
else:
    import tomli as tomllib
tomllib.load(open('$HOME/.config/starship.toml', 'rb'))
" >/dev/null 2>&1; report "starship.toml parses" $?

echo
echo "-- live checks --"
if command -v starship >/dev/null 2>&1; then
  starship prompt >/dev/null 2>&1; report "starship renders a prompt" $?
else
  echo "- starship renders a prompt: skipped (starship not installed)"
fi

echo
echo "=== $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]