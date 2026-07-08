# The Spice Road — Setup Guide

This is the *how*. For the *why* behind every decision — palette, typography, prompt architecture — see `DESIGN.md`. Everything below was run on a real WSL2 / Windows Terminal machine; a few notes are tagged where the sandbox differed, but all commands are the standard, official methods for each tool.

**Time estimate:** 30–45 minutes, mostly waiting for downloads.

> ⚡ **An automated installer is now available.** Run `./install.sh` from the repository root and it'll do everything for you. If you'd rather understand each step (or the installer doesn't fit your setup), this manual guide is for you.

---

## Before you start

Make sure you have these files from the repository, all in one folder:

```
palette.py                          windows-terminal-profile-settings.json
windows-terminal-scheme.json        ls_colors.zsh
starship.toml                       battery.sh
battery-refresh.sh                  welcome-banner.zsh
weather-check.sh                    spice-prefetch.zsh          (optional)
banner-art.zsh                      generate_banner_art.py
fastfetch-config-full.jsonc         fastfetch-config-safe.jsonc
zshrc-additions.zsh                 .pre-commit-config.yaml
spice-road-background.png           generate_background.py
preview-colors.sh                   validate.sh
tmux-spice-road.conf                (optional)
SETUP-GUIDE.md (this file)
```

---

## Step 1 — Nerd Font (Windows side)

Windows Terminal draws the font, even though the shell lives in WSL — so this goes on the **Windows** side, not inside Ubuntu.

1. Download **Iosevka Term Slab Nerd Font** from the Nerd Fonts releases page:
   `https://github.com/ryanoasis/nerd-fonts/releases`
   (look for an asset like `IosevkaTermSlab.zip` under the latest release)
2. Unzip it, select all the `.ttf` files, right-click → **Install** (or **Install for all users**).
3. After installing, open Windows Settings → Personalization → Fonts and search for "Iosevka TermSlab". You'll see a few variants:
   - **Iosevka TermSlab NF** — standard monospaced, recommended
   - **Iosevka TermSlab NFM** — mono variant, also works
   - **Iosevka TermSlab NFP** — proportional (don't use for terminals)

   The profile JSON already points to `"Iosevka TermSlab NF"`; if you prefer the NFM variant, update the `font.face` field in `windows-terminal-profile-settings.json` before merging.

4. If you'd like more flourish in italics and comments, **Victor Mono Nerd Font** is the alternative mentioned in `DESIGN.md` — same download process, look for `VictorMono.zip`.

---

## Step 2 — Windows Terminal configuration

1. Open Windows Terminal → `Ctrl+,` → click **Open JSON file** at the bottom left. This gets you the real `settings.json` no matter how you installed Terminal.
2. Find the top-level `"schemes"` array and paste the entire contents of `windows-terminal-scheme.json` as another entry in that array.
3. Find your Ubuntu-22.04 profile object (under `"profiles"` → `"list"`) and merge in every key from `windows-terminal-profile-settings.json` — add or overwrite, don't replace the whole profile object.
   **Important:** The profile JSON uses `"Iosevka TermSlab NF"` — if you installed the NFM variant, change `font.face` now.
4. Move `spice-road-background.png` to a permanent spot on the Windows filesystem, e.g. `C:\Users\<you>\Pictures\Terminal\spice-road-background.png`, and update the `"backgroundImage"` path you just pasted to match.
5. Save the file. Windows Terminal picks up changes immediately — open a new tab to see the effect.

---

## Step 3 — WSL package installs

Open your Ubuntu WSL terminal for everything from here on.

```bash
sudo apt update
sudo apt install -y build-essential cmake git curl fzf bat zoxide
```

`fzf`, `bat`, and `zoxide` are all in current Ubuntu repos (confirmed on 24.04; they've been around for years). If `zoxide` isn't found on 22.04, use its official one-liner instead:

```bash
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
```

**eza** — Ubuntu 22.04 predates eza, so you'll need its official repo. These commands are straight from their install docs (and verified):

```bash
sudo apt install -y gpg
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza
```

**Starship** — the official binary installer:

```bash
curl -sS https://starship.rs/install.sh | sh
```

**fastfetch** — building from source on WSL2 can hit missing kernel headers, so the easiest path is the prebuilt `.deb`. Grab the latest release from their GitHub releases. For example, for version 2.65.2:

```bash
wget https://github.com/fastfetch-cli/fastfetch/releases/download/2.65.2/fastfetch-linux-amd64.deb
sudo dpkg -i fastfetch-linux-amd64.deb
rm fastfetch-linux-amd64.deb
```

If that exact URL 404s, just swap in the latest release's download link — the filename pattern is the same.

---

## Step 4 — oh-my-zsh custom plugins

These four aren't bundled with oh-my-zsh, so you'll clone them once. Tested against a fresh oh-my-zsh install; they all load fine.

```bash
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
git clone --depth 1 https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
git clone --depth 1 https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
```

---

## Step 5 — Place the Spice Road files

```bash
mkdir -p ~/.config/spice-road ~/.config/starship-helpers ~/.config/fastfetch

cp starship.toml ~/.config/starship.toml
cp ls_colors.zsh welcome-banner.zsh banner-art.zsh weather-check.sh ~/.config/spice-road/
cp battery.sh battery-refresh.sh ~/.config/starship-helpers/
cp fastfetch-config-full.jsonc ~/.config/fastfetch/config.jsonc
cp fastfetch-config-safe.jsonc ~/.config/fastfetch/   # as a reference, not active

chmod +x ~/.config/starship-helpers/battery.sh ~/.config/starship-helpers/battery-refresh.sh ~/.config/spice-road/weather-check.sh
```

(`palette.py`, `generate_background.py`, and `generate_banner_art.py` are build tools, not runtime files — keep them somewhere safe if you want to tweak things later, but they don't need to be in any specific place.)

> **Two fastfetch configs are included.** The commands above activate the full version (all modules). If you want to hide personal details for screenshots or streaming, switch to the safe version later with:
> ```bash
> cp fastfetch-config-safe.jsonc ~/.config/fastfetch/config.jsonc
> ```

---

## Step 6 — Edit `.zshrc`

Open `~/.zshrc` and make these two small edits near the top. (See the comments at the top of `zshrc-additions.zsh` for more context.)

Find and change:
```bash
ZSH_THEME="robbyrussell"
```
to:
```bash
ZSH_THEME=""
```

And change:
```bash
plugins=(git)
```
to:
```bash
plugins=(git zsh-autosuggestions zsh-completions fzf-tab zsh-syntax-highlighting)
```

Now open `zshrc-additions.zsh`, scroll down to the line that says `# PART B`, and copy everything from there to the very end. Paste that at the **end** of your `~/.zshrc`.

If you want the optional cache pre‑warmer (`spice-prefetch.zsh`), look for the line that says `source $ZSH/oh-my-zsh.sh` and add this **right above** it:

```bash
[[ -f "$HOME/.config/spice-road/spice-prefetch.zsh" ]] && source "$HOME/.config/spice-road/spice-prefetch.zsh"
```

Then copy the prefetch script itself:
```bash
cp spice-prefetch.zsh ~/.config/spice-road/
chmod +x ~/.config/spice-road/spice-prefetch.zsh
```

---

## Step 7 — Reload and verify

Open a fresh Windows Terminal tab (not just `source ~/.zshrc` — the banner is designed to run once per new tab, and a real new shell is the true test).

**What you should see, in order:** sunburst art, the typed-out title, dune waves, a divider, a weather line (it might show up instantly if the background fetch already finished), a quote, another divider, your fastfetch system stats, then the three‑row prompt.

**Quick troubleshooting:**

| Symptom | Likely cause |
|---|---|
| Boxes/tofu instead of icons | Nerd Font not selected — double-check `font.face` in your WT profile matches the installed family (e.g. `Iosevka TermSlab NF`). |
| Colors look like defaults | `colorScheme` name in your profile doesn't match `"name"` in the schemes entry exactly. |
| No weather ever appears | Normal on the first few tabs (25‑min cache); check `~/.cache/spice-road/weather` after a few minutes. |
| No battery segment | Normal on a desktop, or if PowerShell interop is slow — it fails silently by design. |
| `azure` section in starship.toml errors | Your Starship version predates that module — just delete the `[azure]` block. |
| Stray job‑control messages like `[3] 728 done` | Fixed in the shipped `welcome-banner.zsh` via the `weather-check.sh` extraction. If you still see them, make sure you've copied the latest version of the file. |

---

## Optional: tmux status bar

```bash
sudo apt install -y tmux
cp tmux-spice-road.conf ~/.tmux.conf
```

This adds session/window chrome plus a light strip (git branch, load, battery, clock) without duplicating language/runtime info — that stays in Starship inside each pane. Tested with tmux 3.4. If the status bar shows underscores or boxes, check your `locale` first — tmux is pickier about UTF‑8 than zsh.

Prefix stays the tmux default `C-b` on purpose; there's a comment at the top of `tmux-spice-road.conf` if you want to change it.

---

## Optional: health check and color reference

```bash
bash validate.sh          # reports ✓/✗ for every file, command, and config
bash preview-colors.sh    # prints the full palette as swatches
```

Run `validate.sh` anytime something feels off — it's non‑destructive and checks that files are in place, tools are on PATH, configs parse, and Starship renders without error.

---

## Optional: pre-commit lint hook + CI

If you keep these files in a git repo, `.pre-commit-config.yaml` runs ShellCheck on the bash scripts, `zsh -n` on zsh files, and validates all JSON/JSONC and TOML (using `json5` for the JSONC with comments). All hooks were tested with both passing and deliberately broken files.

```bash
pip install pre-commit
cd /path/to/wherever/you/keep/these/files
git init   # if not already a repo
pre-commit install
```

`.github/workflows/lint.yml` runs the same config in CI — no separate CI‑only config, so what you run locally is exactly what runs on push.
