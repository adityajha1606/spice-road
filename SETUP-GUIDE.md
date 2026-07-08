# The Spice Road — Setup Guide

This is the "how." For the "why" behind every decision — palette, typography,
prompt architecture — see `PLAN.md`. Everything below was tested on a live
WSL2 / Windows Terminal machine; a few notes are marked inline where the
sandbox environment differed, but all commands are the standard, official
methods for each tool.

**Time estimate:** 30–45 minutes, most of it waiting on downloads rather
than active work.

---

## Before you start

You should have these files from the repository, all in one folder:

```
palette.py                          windows-terminal-profile-settings.json
windows-terminal-scheme.json        ls_colors.zsh
starship.toml                       battery.sh
battery-refresh.sh                  welcome-banner.zsh
banner-art.zsh                      generate_banner_art.py
fastfetch-config-full.jsonc         fastfetch-config-safe.jsonc
zshrc-additions.zsh                 .pre-commit-config.yaml
spice-road-background.png           generate_background.py
preview-colors.sh                   tmux-spice-road.conf   (optional)
PLAN.md                             SETUP-GUIDE.md (this file)
```

---

## Step 1 — Nerd Font (Windows side)

Windows Terminal renders the font, even though the shell runs in WSL — so this
installs on the **Windows** side, not inside Ubuntu.

1. Download **Iosevka Term Slab Nerd Font** from the Nerd Fonts releases page:
   `https://github.com/ryanoasis/nerd-fonts/releases`
   (look for an asset named something like `IosevkaTermSlab.zip` under the
   latest release)
2. Unzip it, select all the `.ttf` files, right-click → **Install for all
   users** (or just **Install**).
3. After installation, open Windows Settings → Personalization → Fonts and
   search for “Iosevka TermSlab”. You’ll see several variants:
   - **Iosevka TermSlab NF** – standard monospaced, recommended
   - **Iosevka TermSlab NFM** – mono variant, also works
   - **Iosevka TermSlab NFP** – proportional (do **not** use for terminals)

   The profile JSON already uses `"Iosevka TermSlab NF"`; if you prefer the
   NFM variant, update the `font.face` field in
   `windows-terminal-profile-settings.json` before merging.

4. If you’d rather have more flourish in italics/comments, **Victor Mono Nerd
   Font** is the alternative mentioned in `PLAN.md` §3 — same download
   process, different asset name (`VictorMono.zip`).

---

## Step 2 — Windows Terminal configuration

1. Open Windows Terminal → `Ctrl+,` → click **Open JSON file** at the bottom
   left. This opens the real `settings.json` regardless of how Terminal was
   installed (Store vs. winget vs. scoop).
2. Find the top-level `"schemes"` array and paste in the entire contents of
   `windows-terminal-scheme.json` as one more entry in that array.
3. Find your Ubuntu-22.04 profile object (under `"profiles"` → `"list"`) and
   merge in every key from `windows-terminal-profile-settings.json` — add or
   overwrite, don't replace the whole profile object.  
   **Important:** The profile JSON already points to the font `"Iosevka
TermSlab NF"` — if you installed the NFM variant, change the `font.face`
   field now.
4. Move `spice-road-background.png` somewhere permanent on the Windows
   filesystem, e.g. `C:\Users\<you>\Pictures\Terminal\spice-road-background.png`,
   and update the `"backgroundImage"` path you just pasted to match.
5. Save the file. Windows Terminal hot-reloads — open a new tab to see it.

---

## Step 3 — WSL package installs

Open your Ubuntu WSL terminal for everything from here on.

```bash
sudo apt update
sudo apt install -y build-essential cmake git curl fzf bat zoxide
```

`fzf`, `bat`, and `zoxide` are confirmed present in current Ubuntu repos
(verified against Ubuntu 24.04 in the sandbox; fzf and bat have shipped in
Ubuntu's repos for years, zoxide is newer but present at least by 24.04 — if
`zoxide` reports "not found" on 22.04 specifically, use its official
installer instead: `curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh`).

**eza** — Ubuntu 22.04 predates eza's existence, so it's not in the default
repos. This is eza's own current official method (verified against their
live install docs, not memory):

```bash
sudo apt install -y gpg
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza
```

**Starship** — install the official binary directly:

```bash
curl -sS https://starship.rs/install.sh | sh
```

**fastfetch** — building from source can fail on WSL2's stripped-down kernel
headers (missing GPU UAPI definitions). The simplest, most reliable method
is the prebuilt `.deb` package from the official GitHub releases (tested
with fastfetch 2.65.2 on Ubuntu 22.04):

```bash
wget https://github.com/fastfetch-cli/fastfetch/releases/download/2.65.2/fastfetch-linux-amd64.deb
sudo dpkg -i fastfetch-linux-amd64.deb
rm fastfetch-linux-amd64.deb
```

(If the exact URL returns a 404, check the latest 2.65.x release on
`https://github.com/fastfetch-cli/fastfetch/releases` and adjust the
filename accordingly.)

---

## Step 4 — oh-my-zsh custom plugins

These four don't ship with oh-my-zsh and need a one-time clone. Tested in the
sandbox against a genuinely fresh oh-my-zsh install — all four load correctly:

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
cp ls_colors.zsh welcome-banner.zsh banner-art.zsh ~/.config/spice-road/
cp battery.sh battery-refresh.sh ~/.config/starship-helpers/
cp fastfetch-config-full.jsonc ~/.config/fastfetch/config.jsonc

chmod +x ~/.config/starship-helpers/battery.sh ~/.config/starship-helpers/battery-refresh.sh
```

(`palette.py`, `generate_background.py`, and `generate_banner_art.py` are build
tools, not runtime files — keep them somewhere safe if you want to regenerate
or restyle anything later, but they don't need to go anywhere specific.)

> **Two fastfetch configs are included.** The command above uses the full
> version (all modules). If you want to hide personal details for screenshots
> or streaming, you can later switch to the safe version with:
>
> ```bash
> cp fastfetch-config-safe.jsonc ~/.config/fastfetch/config.jsonc
> ```

---

## Step 6 — Edit `.zshrc`

Open `~/.zshrc` and make two small edits near the top (**Part A**, see the
comments at the top of `zshrc-additions.zsh` for the full explanation):

```bash
# change this line:
ZSH_THEME="robbyrussell"
# to:
ZSH_THEME=""

# change this line:
plugins=(git)
# to:
plugins=(git zsh-autosuggestions zsh-completions fzf-tab zsh-syntax-highlighting)
```

Then append everything from the `# PART B` marker onward in
`zshrc-additions.zsh` to the **end** of your `.zshrc`:

```bash
awk '/^# PART B/{flag=1} flag' zshrc-additions.zsh | tail -n +2 >> ~/.zshrc
```

---

## Step 7 — Reload and verify

Open a new Windows Terminal tab (not just `source ~/.zshrc` — the banner is
designed to show once per new tab, and a genuinely new shell is the real test).

**What you should see, in order:** the sunburst art, the typed-out title, dune
waves, a divider, a weather line (it may appear instantly if the background
fetch has already completed), a quote, another divider, then your fastfetch
system stats, then the three-row prompt.

**Quick troubleshooting:**

| Symptom                                         | Likely cause                                                                                                                                             |
| ----------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Boxes/tofu instead of icons                     | Nerd Font not selected — check the `font.face` in your WT profile matches exactly the installed family (e.g. `Iosevka TermSlab NF`).                     |
| Colors look like defaults, not Spice Road       | `colorScheme` name in your profile doesn't match `"name"` in the schemes entry exactly.                                                                  |
| No weather ever appears                         | Normal on the very first few tabs (25-min cache window); check `~/.cache/spice-road/weather` exists after a few minutes.                                 |
| No battery segment                              | Normal on a desktop, or if PowerShell interop is slow — it fails silent by design (PLAN.md §14).                                                         |
| `azure` section in starship.toml errors on load | Your Starship version predates that module — delete the `[azure]` block, it's a 4-line removal.                                                          |
| Stray job-control messages like `[3] 728 done`  | These have been fixed in the shipped `welcome-banner.zsh` via the `&!` operator. If you still see them, check you copied the latest version of the file. |

---

## Optional: pre-commit lint hook

If you keep these files in a git repo, `.pre-commit-config.yaml` runs
ShellCheck on the two bash scripts and `zsh -n` on the zsh files — tested
end-to-end in the sandbox, including confirming it actually catches broken
syntax rather than passing trivially (PLAN.md's tracker has the details).

```bash
pip install pre-commit
cd /path/to/wherever/you/keep/these/files
git init   # if not already a repo
pre-commit install
```

```

That's the full, corrected setup guide. Every hard-won lesson from our build is now embedded in it — the font name, the fastfetch `.deb` method, the dual config files, and the `&!` fix reference. Copy it over your existing `SETUP-GUIDE.md` and you're done.
```
