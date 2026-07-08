# Customizing The Spice Road

The Spice Road is built to be tuned, not just installed. Almost everything traces back to a handful of source files, so most customizations are a one-line edit followed by a short regeneration step.

---

## Changing the Palette

All 28 colors live in `palette.py`. Change a hex value, save the file.

The background mandala, banner art, and `LS_COLORS` all derive from this palette, so you'll need to regenerate or manually update a few things afterward for the changes to take full effect.

```bash
# Regenerate background image and banner art
python3 generate_background.py
python3 generate_banner_art.py > banner-art.zsh
```

If your edits touched the core terminal colors (background, foreground, or ANSI color slots), update `windows-terminal-scheme.json` with the new hex values and re-apply the scheme in Windows Terminal.

If you changed any colors used in file-type highlighting, open `ls_colors.zsh` and edit the relevant entries by hand—those strings aren't auto-generated.

Finally, after regenerating the background image, copy it to the location Windows Terminal expects (for example, `C:\Users\<you>\Pictures\Terminal\spice-road-background.png`) and restart your terminal.

---

## Adding a Cloud Provider Pill

The Row 1 pills are standard Starship modules. To add another provider (for example, Kubernetes), add a block like this to `starship.toml`:

```toml
[kubernetes]
disabled = false
format = '[$symbol$context]($style) '
style = "bg:#3E5578 fg:#F2E6D8"
```

Choose a background color that isn't already assigned to another pill—the cockpit design philosophy is that no two modules share an accent color by accident.

Save the file and open a new terminal tab. The new pill will appear automatically.

---

## Swapping the Epigrams

The random desert-bazaar epigrams displayed on the welcome banner are stored in the `SR_QUOTES` array near the top of `welcome-banner.zsh`.

Add, remove, or rewrite entries directly. Each line is simply a quoted string, and the banner selects one at random every time a new shell starts.

```zsh
SR_QUOTES=(
  "Your new line here."
  # ...existing quotes...
)
```

No regeneration is required. The changes take effect the next time you open a shell.

---

## Adjusting Background Image Opacity

Background image opacity is controlled by Windows Terminal, not by the theme itself.

Open your Terminal `settings.json`, locate the Spice Road profile, and adjust:

```json
"backgroundImageOpacity": 0.3
```

We settled on `0.3` after testing—it keeps the terminal readable while still allowing the mandala and dune silhouette to show through.

Experiment with nearby values like `0.2` or `0.4` depending on your monitor and lighting.

Open a new terminal tab to see the change.

---

## Switching Between Full and Safe Fastfetch Configs

The theme includes two Fastfetch configurations:

- **`fastfetch-config-full.jsonc`** — Includes disk, local IP, and battery information.
- **`fastfetch-config-safe.jsonc`** — Uses the same layout but omits disk, local IP, and battery, making it suitable for screenshots and livestreams.

Switch to the safe configuration:

```bash
cp fastfetch-config-safe.jsonc ~/.config/fastfetch/config.jsonc
```

Switch back to the full configuration:

```bash
cp fastfetch-config-full.jsonc ~/.config/fastfetch/config.jsonc
```

Either command takes effect the next time Fastfetch runs—no shell restart is required.
