#!/usr/bin/env zsh
# Spice Road — zsh plugin stack + .zshrc additions.
#
# This file is NOT meant to be sourced as-is. .zshrc has structural
# requirements oh-my-zsh depends on (the plugins array must be set BEFORE
# `source $ZSH/oh-my-zsh.sh`, not after), so this is split into two parts
# with different destinations in your existing .zshrc. See SETUP-GUIDE.md
# for the exact merge steps.

# ════════════════════════════════════════════════════════════════════
# PART A — merge into your EXISTING .zshrc, near the top
# ════════════════════════════════════════════════════════════════════
#
# 1. Find your existing line (likely near the top of .zshrc):
#      ZSH_THEME="robbyrussell"     <- (or whatever yours says)
#    Change it to:
#      ZSH_THEME=""
#    Starship replaces the oh-my-zsh theme system entirely — leaving an
#    oh-my-zsh theme active alongside Starship means two things fight over
#    the prompt.
#
# 2. Find your existing plugins array:
#      plugins=(git)
#    Replace it with (zsh-syntax-highlighting MUST be last — this is an
#    oh-my-zsh requirement, not a style choice):
#      plugins=(git zsh-autosuggestions zsh-completions fzf-tab zsh-syntax-highlighting)
#
#    Three of these don't ship with oh-my-zsh and need a one-time clone
#    into $ZSH_CUSTOM/plugins first — exact commands are in SETUP-GUIDE.md:
#      zsh-autosuggestions, zsh-completions, fzf-tab, zsh-syntax-highlighting
#    (fzf itself is handled directly in Part B below, not through
#    oh-my-zsh's bundled "fzf" plugin — testing found its path-detection
#    logic fragile across install methods/versions, so we source fzf's
#    integration ourselves with proper fallbacks instead.)

# ════════════════════════════════════════════════════════════════════
# PART C — optional, near the very TOP of .zshrc (a different spot than
# Part B) — only if you want spice-prefetch.sh's early cache warm-up
# ════════════════════════════════════════════════════════════════════
#
# This is optional. It buys the first prompt of a session a better chance
# of already showing a battery reading, by giving the background fetch
# more head-start time before anything tries to read the cache. Skipping
# this changes nothing about correctness — battery/weather still populate
# themselves within their normal staleness window either way.
#
#   [[ -f "$HOME/.config/spice-road/spice-prefetch.sh" ]] && source "$HOME/.config/spice-road/spice-prefetch.sh"
#
# Place that line as early as possible — before the oh-my-zsh sourcing
# line is fine — since every line of .zshrc that runs before it delays
# the background fetch's head start.

# ════════════════════════════════════════════════════════════════════
# PART B — append everything below this line to the END of .zshrc
# ════════════════════════════════════════════════════════════════════

# ---------- Starship prompt ----------
# Must come after oh-my-zsh.sh is sourced (further up the file) so nothing
# overwrites it afterward — this is deliberately the near-last thing in the
# file for that reason.
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# ---------- fzf integration ----------
# Handled directly rather than via oh-my-zsh's bundled "fzf" plugin — real
# testing found that plugin's path-detection logic broke on a standard
# apt install (it assumed a Debian doc path that wasn't populated). This
# tries fzf's modern built-in method first (fzf >= 0.48), then falls back
# to sourcing whichever of the known integration file locations exists.
if command -v fzf >/dev/null 2>&1; then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  else
    for f in \
      /usr/share/doc/fzf/examples/key-bindings.zsh \
      /usr/share/fzf/key-bindings.zsh \
      /usr/share/doc/fzf/examples/completion.zsh \
      /usr/share/fzf/completion.zsh
    do
      [[ -f "$f" ]] && source "$f"
    done
  fi
fi

# ---------- zoxide (smarter cd) ----------
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# ---------- eza / bat aliases (only if installed — never breaks a machine that doesn't have them) ----------
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -l --icons --group-directories-first'
  alias la='eza -la --icons --group-directories-first'
  alias lt='eza --tree --icons --level=2'
fi

if command -v batcat >/dev/null 2>&1; then
  # Debian/Ubuntu ship bat's binary as "batcat" (name clash with an
  # unrelated existing package called "bat") — alias it back to the name
  # everyone actually expects.
  alias bat='batcat'
  alias cat='batcat --paging=never'
elif command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
fi

# ---------- Spice Road: LS_COLORS, welcome banner ----------
[[ -f "$HOME/.config/spice-road/ls_colors.zsh" ]] && source "$HOME/.config/spice-road/ls_colors.zsh"
[[ -f "$HOME/.config/spice-road/welcome-banner.zsh" ]] && source "$HOME/.config/spice-road/welcome-banner.zsh"

# ---------- fzf theme (Spice Road palette) ----------
export FZF_DEFAULT_OPTS="\
--color=fg:#C9B79C,bg:#14100D,hl:#E8A33D \
--color=fg+:#F2E6D8,bg+:#4A3423,hl+:#F2C14E \
--color=info:#B0609E,prompt:#B5502D,pointer:#E8623A \
--color=marker:#7C8B3D,spinner:#2E8C82,header:#8C6239 \
--color=border:#8C6239 \
--prompt='◈ ' --pointer='▶' --marker='✓' \
--height=60% --layout=reverse --border=rounded"

# ---------- zsh-syntax-highlighting theme (Spice Road palette) ----------
# Must be set after the plugin loads (oh-my-zsh sources plugins earlier in
# the file); the plugin reads this associative array live on every
# highlight pass, so setting it here at the end works correctly.
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]='fg=#F2E6D8'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#E8623A,bold'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#7B3F61'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#7C8B3D'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#2E8C82'
ZSH_HIGHLIGHT_STYLES[function]='fg=#E8A33D'
ZSH_HIGHLIGHT_STYLES[command]='fg=#A8BB5C'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#A8BB5C,italic'
ZSH_HIGHLIGHT_STYLES[path]='fg=#D9C7A3,underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#D4AF37'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#B87333'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#B87333'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#4FB8AC'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#F2C14E'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#F2C14E'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#6B5D4F,italic'
