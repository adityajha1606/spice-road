#!/usr/bin/env zsh
# Spice Road — optional early cache warmer.
#
# Source this ONCE, as early as possible in .zshrc (before the oh-my-zsh
# line is fine — the earlier this runs, the more head-start the background
# fetches get before anything tries to read their caches).
#
# This does NOT duplicate battery.sh's or weather-check.sh's staleness/lock
# logic — it just calls them, silently, and lets them decide for themselves
# whether a refresh is actually needed. That's the whole point: one
# implementation of "is the cache stale, and is a refresh already running,"
# reused everywhere, so nothing can stack duplicate PowerShell/curl calls
# no matter how many places trigger a warm-up.
#
# Safe to source multiple times or not at all — every code path here is
# already idempotent by construction in the scripts it calls.

[[ -x "$HOME/.config/starship-helpers/battery.sh" ]] && \
  bash "$HOME/.config/starship-helpers/battery.sh" >/dev/null 2>&1

[[ -x "$HOME/.config/spice-road/weather-check.sh" ]] && \
  bash "$HOME/.config/spice-road/weather-check.sh" >/dev/null 2>&1

true
