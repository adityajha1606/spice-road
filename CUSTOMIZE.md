# Customizing The Spice Road

The Spice Road is built to be tuned, not just installed. Everything traces back to a small number of source files, so most customizations are a one-line edit followed by a quick regeneration step.

Here's where to look.

---

## Changing the Palette

All 28 colors live in one place: `palette.py`. Open it, change any hex value, and save.

Because the background mandala, the banner art, and the `LS_COLORS` are all derived from that palette, you'll need to regenerate or manually update them so your changes take full effect.

```bash
# Regenerate background image and banner art
python3 generate_background.py
python3 generate_banner_art.py > banner-art.zsh
```

If your new palette changes the core terminal colors (background, foreground, ANSI), you must also update `windows-terminal-scheme.json` with the new hex values and re-apply it in Windows Terminal's settings.

Similarly, if you altered colors used in file-type highlighting, update `ls_colors.zsh` by hand—those strings are hand-crafted and not auto-generated.

Finally, after regenerating the background image, copy it to the location Windows Terminal expects (for example, `C:\Users\<you>\Pictures\Terminal\spice-road-background.png`) if you're using a static path there. Then restart your terminal.

---

## Adding a Cloud Provider Pill

The Row 1 pills in `starship.toml` are just Starship modules. To add another provider (for example, Kubernetes), drop a block like this into `starship.toml`:

```toml
[kubernetes]
disabled = false
format = '[$symbol$context]($style) '
style = "bg:#3E5578 fg:#F2E6D8"
```

Pick a background color that isn't already spoken for elsewhere in the palette—part of the cockpit philosophy is that no two pills share an accent by accident.

After saving, open a new terminal tab to see the pill appear.

---

## Swapping the Epigrams

The random desert-bazaar epigrams shown on the welcome banner live in the `SR_QUOTES` array near the top of `welcome-banner.zsh`.

Add, remove, or rewrite lines directly in that array. Each entry is just a quoted string, and the banner picks one at random on every new shell.

```zsh
SR_QUOTES=(
  "Your new line here."
  # ...existing quotes...
)
```

No regeneration is needed—this change takes effect the next time you open a shell.

---

## Adjusting Background Image Opacity

The background image's opacity is controlled by Windows Terminal itself, not by the theme files.

Open Windows Terminal's `settings.json` and find your Spice Road profile, then adjust:

```json
"backgroundImageOpacity": 0.3
```

`0.3` is the value we landed on after real-world testing—low enough to stay readable, strong enough to still see the mandala and dune silhouette.

Nudge it up or down in small steps (try `0.2` or `0.4`) and see what fits your lighting and font.

Changes take effect immediately when you open a new tab.

---

## Switching Between Full and Safe Fastfetch Configs

Two Fastfetch configs ship with the theme:

- **`fastfetch-config-full.jsonc`** — Includes everything, including disk, local IP, and battery.
- **`fastfetch-config-safe.jsonc`** — Uses the same layout but omits disk, local IP, and battery, making it safe for screenshots or streams.

To switch to the safe version:

```bash
cp fastfetch-config-safe.jsonc ~/.config/fastfetch/config.jsonc
```

To switch back to the full version:

```bash
cp fastfetch-config-full.jsonc ~/.config/fastfetch/config.jsonc
```

Either copy takes effect the next time Fastfetch runs—no shell restart required.
