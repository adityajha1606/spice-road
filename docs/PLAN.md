# The Spice Road – Terminal Cockpit Build Plan

A living blueprint. Every decision from the original conversation is recorded here, along with why I made it, every file that will exist, what it's for and where it goes. At the bottom there's a status tracker so I know exactly what's done and what's left. If I lose my thread during the build, this file is the anchor.

---

## 1. Concept

**Name:** The Spice Road  
**Why:** "Spice" ties to the Dune side; "Road" ties to the caravan, bazaar, Indian folk side. The name itself is the 60/40 fusion in two words.

**Design DNA, straight from the interview:**
- Overall mood: vivid, chaotic energy, but through earth tones and metallics – not neon. "Kaleidoscopic bronze," not cyberpunk.
- Visual world: **60% Dune desert-mirage sci‑fantasy** (sand, spice, bronze machinery, mirage haze, that vast scale) **+ 40% Rajasthani/Indian folk maximalism** (temple tilework, block‑print patterns, marigold and vermillion, brass and mosaic).
- Typography instinct: ornate decorative serif (picked after a live font preview).
- Density: full cockpit, nothing trimmed. The user explicitly said "make them all distinguished from each other, use best designs" for both dev‑context signals and system‑pulse stuff.
- Decoration: a welcome banner plus ambient extras (weather/quotes/stats) plus custom dividers plus light (not heavy) motion plus custom LS_COLORS plus a subtle background image.
- Workflows to flag: git, Python venv, Node, background jobs, SSH, Docker, cloud CLI (AWS/GCP/Azure). Kubernetes was explicitly deferred – not selected.
- Time budget: none. Build the full legendary version.

---

## 2. Complete color palette

Single source of truth: `palette.py`. Every other file pulls its colors from this table – nothing is re‑defined ad‑hoc elsewhere.

| Role | Name | Hex | RGB | Used in |
|---|---|---|---|---|
| Base background | bg | `#14100D` | 20,16,13 | WT background, banner bg |
| Base foreground | fg | `#F2E6D8` | 242,230,216 | WT foreground, parchment text |
| Muted foreground | fg_muted | `#C9B79C` | 201,183,156 | secondary text, clock |
| Selection | selection | `#4A3423` | 74,52,35 | WT text selection |
| Cursor | cursor | `#E8A33D` | 232,163,61 | WT cursor |
| ANSI black | black | `#1A1410` | 26,20,16 | terminal black |
| ANSI red | red | `#B5502D` | 181,80,45 | rust/terracotta – git status pill |
| ANSI green | green | `#7C8B3D` | 124,139,61 | desert moss – nodejs pill |
| ANSI yellow | yellow | `#E8A33D` | 232,163,61 | marigold – python pill |
| ANSI blue | blue | `#3E5578` | 62,85,120 | indigo – azure pill |
| ANSI purple | purple | `#7B3F61` | 123,63,97 | plum – ssh hostname pill |
| ANSI cyan | cyan | `#2E8C82` | 46,140,130 | peacock – general accents |
| ANSI white | white | `#D9C7A3` | 217,199,163 | sand tan |
| bright black | brightBlack | `#6B5D4F` | 107,93,79 | warm gray – cmd_duration text |
| bright red | brightRed | `#E8623A` | 232,98,58 | error states, exit‑code pill |
| bright green | brightGreen | `#A8BB5C` | 168,187,92 | network‑online text |
| bright yellow | brightYellow | `#F2C14E` | 242,193,78 | battery text |
| bright blue | brightBlue | `#6A87B8` | 106,135,184 | periwinkle – gcloud pill |
| bright purple | brightPurple | `#B0609E` | 176,96,158 | orchid – memory_usage text |
| bright cyan | brightCyan | `#4FB8AC` | 79,184,172 | vim‑mode character glyph |
| bright white | brightWhite | `#F2E6D8` | 242,230,216 | = fg |
| Copper | copper | `#B87333` | 184,115,51 | jobs text, LS_COLORS accent |
| Bronze | bronze | `#8C6239` | 140,98,57 | directory pill, frame lines ┌─│└ |
| Gold | gold | `#D4AF37` | 212,175,55 | cpu‑load text, metallic accents |
| Vermillion | vermillion | `#9B2C2C` | 155,44,44 | sindoor red – aws pill |
| Henna | henna | `#6B3A1F` | 107,58,31 | banner shading, background art |
| Dusk indigo | duskIndigo | `#1F2A44` | 31,42,68 | git_branch pill |
| Peacock deep | peacockDeep | `#14555A` | 20,85,90 | docker_context pill |

---

## 3. Typography system

Two separate typography decisions, because a terminal has two different typographic jobs:

1. **The monospace font you actually read and type in.**  
   This must be fixed‑width — no decorative web font can do this.  
   **Decision: Iosevka TermSlab NF.** Iosevka's TermSlab build adds real serif terminals to the letterforms — it's literally the monospace version of "ornate decorative serif," while staying perfectly legible at 10–13pt for code and git output.  
   **Alternative (not default):** Victor Mono Nerd Font — same idea, but leans into cursive italics for comments/git messages for extra flourish. You can swap it in 30 seconds if Iosevka TermSlab doesn't feel right once it's installed.

2. **The display treatment for the welcome banner and section headers.**  
   The font‑preview widget (an ornate Cinzel‑Decorative‑style serif) was a mood proxy — but figlet's ASCII fonts don't have a real ornate serif worth trusting.  
   **Decision: a hand‑built ASCII/Unicode banner,** not figlet‑generated — a stylized sun‑medallion rising over dune waves, framed by a bazaar‑tile border, colorized with a manually computed 24‑bit gradient from the palette. No runtime dependency, identical rendering everywhere.

---

## 4. Prompt engine decision

**Starship**, not Powerlevel10k or a fully custom prompt. Reasons:
- It ships built‑in modules for every signal we need: git, python, nodejs, docker_context, aws, gcloud, azure, hostname (ssh‑only), jobs, memory_usage, cmd_duration, battery, status (exit code).
- Each module has independent conditional visibility (e.g., docker_context only shows near Docker files) — exactly how "rich but not cluttered" works without hand‑rolled logic.
- Cross‑shell (works if I ever try fish or bash too), single static Rust binary, negligible prompt‑render latency when tuned (`command_timeout` set).
- TOML config is easy to read and edit, unlike Powerlevel10k's generated‑wizard `.p10k.zsh` (which is a pain to adjust later by hand).

---

## 5. Prompt architecture — three rows

```
┌─ ~/spice-road   main ✓  🐍 3.12 (venv)  ⬢ 20.11.0  🐳 default
│  ⚙ 1  🧠 42%  ◆ 0.38 0.29 0.22  ⇄ online  ⏱ 3.2s
└─ ◈                                                    14:07
```

| Row | Feel | Contains |
|---|---|---|
| 1 — top, bronze `┌─` | filled color pills, identity/context | directory, git_branch, git_status, python, nodejs, docker_context, aws, gcloud, azure, hostname(ssh‑only) |
| 2 — middle, bronze `│` | plain colored text, live numbers | jobs, memory_usage, cpu load (custom), network online/offline (custom), battery (custom), cmd_duration, exit‑code pill (only on error) |
| 3 — bottom, bronze `└─` | the actual input line | `◈` character (gold success / red error / cyan vim‑mode), right‑aligned 24h clock |

Every module in row 1 already has its own distinct background color (see palette table); every module in row 2 has its own distinct foreground color. This came directly from "make them all distinguished from each other" — nothing shares a color by accident.

**Status:** drafted and TOML‑validated (`starship.toml`). I haven't tested it against a live Starship binary yet (the sandbox has no network to install one) — final live check will happen on the actual WSL machine per the execution order below.

---

## 6. Windows Terminal configuration

Beyond the color scheme (already built), the profile needs:
- **Font face:** Iosevka TermSlab NF, size 11–12pt (11.5 if fractional sizes are supported, else 12).
- **Cursor shape:** filled box or bar, blinking — bar reads more "precision instrument," box reads more "retro terminal." I'll present both, default to bar.
- **Padding:** 8–10px, so the frame characters (┌─│└) don't feel cramped against the window edge.
- **Background image:** the generated Spice Road art (Section 7), `backgroundImageOpacity` set to 0.3, `backgroundImageStretchMode: "uniformToFill"`.
- **Acrylic/transparency:** optional layer on top of the background image — I recommend leaving acrylic *off* (useAcrylic: false) because we already have a background image; stacking both tends to muddy a dark palette. It's just a toggle, not forced.
- **Tab color:** set to bronze (`#8C6239`) so tabs read as part of the same system.

---

## 7. Background image

Procedurally generated (no network source needed) — a mandala/sun medallion motif over a dune‑wave silhouette, bronze/gold/indigo linework on the Spice Road background color, kept low‑opacity via Windows Terminal's own `backgroundImageOpacity` setting rather than baked transparency. That way I can tune intensity later without regenerating the file.

---

## 8. zsh plugin stack

Added on top of the user's existing oh‑my‑zsh install — nothing replaced, only extended.

| Plugin | Purpose | Theming note |
|---|---|---|
| `zsh‑syntax‑highlighting` | colors commands as you type — valid/invalid at a glance | `ZSH_HIGHLIGHT_STYLES` remapped to palette (valid=moss, error=rust) |
| `zsh‑autosuggestions` | ghost‑text history suggestions | suggestion color set to `fg_muted` |
| `zsh‑completions` | wider completion definitions | — |
| `fzf` + `fzf‑tab` | fuzzy popup for tab‑completion and Ctrl+R history search | `FZF_DEFAULT_OPTS` themed to palette |
| `zoxide` | `z`‑style smarter `cd`, learns your habits | — |
| `eza` | modern `ls` replacement — icons, git status, tree view | complements LS_COLORS, has its own optional theme |
| `bat` | `cat` replacement with syntax highlighting | paired with a matching bat theme |

---

## 9. LS_COLORS design

Hand‑crafted truecolor LS_COLORS (not vivid/dircolors‑generated, to avoid an extra Rust‑toolchain dependency) computed from the same palette so `ls` output is visibly part of the same system:

| Category | Color |
|---|---|
| Directories | dusk indigo bg / parchment fg |
| Symlinks | peacock |
| Executables | bright red (rust family) |
| Archives (.zip/.tar/.gz/…) | vermillion |
| Images (.png/.jpg/.svg/…) | marigold |
| Video/audio | plum |
| Documents (.pdf/.md/.docx/…) | sand tan |
| Code files (.py/.js/.rs/…) | gold |
| Broken symlink | bright red, bold |

---

## 10. Decoration layer (welcome banner)

Runs once per new interactive shell / tab, in this order:
1. **One‑time typing‑effect reveal** of the banner title only (a few hundred ms total — *not* a continuous animation, so it costs nothing on every prompt afterward).
2. **Hand‑built ASCII/Unicode art** — sun medallion over dune waves, bazaar‑tile border, gradient‑colorized.
3. **Divider** — repeating `⟡───⟡` rule in bronze.
4. **Ambient extras:**
   - Weather via `wttr.in`, cached to a file for ~20–30 minutes so it never slows shell startup.
   - A short epigram from a curated set of ~20 **original** desert/bazaar‑flavored aphorisms written for this project — deliberately *not* verbatim Dune quotes, to avoid reproducing Frank Herbert's copyrighted text.
   - System stats via `fastfetch` (C‑based, near‑zero overhead, unlike neofetch/bash) — it will automatically inherit the Windows Terminal ANSI palette, so no separate color config is needed beyond picking which modules to show.
5. **Divider**, then straight into the live prompt.

---

## 11. Workflow indicators

Git, Python venv, Node, jobs are always‑on signals (row 1/2). SSH, Docker, and cloud CLI (AWS/GCP/Azure) are conditional pills that only show up when relevant — already wired into `starship.toml`. Kubernetes was explicitly not selected; adding a `kubernetes` module later is a 4‑line TOML addition, documented as a future extension (Section 13).

---

## 12. Complete file manifest

| File | Purpose | Final destination (user's machine) |
|---|---|---|
| `palette.py` | single source of truth for all colors | build‑only, not deployed |
| `windows‑terminal‑scheme.json` | WT color scheme | pasted into WT `settings.json` → `schemes` array |
| `windows‑terminal‑profile‑settings.json` | font/cursor/padding/background image/tab color | merged into WT `settings.json` → your Ubuntu profile object |
| `starship.toml` | full prompt config | `~/.config/starship.toml` (WSL) |
| `ls_colors.zsh` | exported `LS_COLORS` string | `~/.config/spice‑road/ls_colors.zsh` (WSL), sourced from `.zshrc` |
| `battery.sh` | instant, prompt‑facing battery reader (cache‑only, forks the refresher) | `~/.config/starship‑helpers/battery.sh` (WSL) |
| `battery‑refresh.sh` | detached refresher — the only file that ever calls `powershell.exe` | `~/.config/starship‑helpers/battery‑refresh.sh` (WSL) |
| `welcome‑banner.zsh` | banner + weather + quote + fastfetch call | `~/.config/spice‑road/welcome‑banner.zsh` (WSL), sourced from `.zshrc` |
| `weather‑check.sh` | weather cache check/fetch, extracted so both the banner and the optional prefetch hook share one implementation | `~/.config/spice‑road/weather‑check.sh` (WSL) |
| `spice‑prefetch.sh` | optional — source near the top of `.zshrc` for an earlier battery/weather cache warm‑up; reuses battery.sh/weather‑check.sh's own locks rather than duplicating them | `~/.config/spice‑road/spice‑prefetch.sh` (WSL), optional Part C |
| `validate.sh` | health check — every check reports ✓ or ✗ explicitly (the version this replaced silently skipped failures) | anywhere, run manually: `bash validate.sh` |
| `preview‑colors.sh` | prints the full palette as swatches, generated from `palette.py` (no duplicate‑key risk) | anywhere, run manually: `bash preview‑colors.sh` |
| `.github/workflows/lint.yml` | CI — runs the *same* `.pre‑commit‑config.yaml`, not a parallel config | `.github/workflows/lint.yml` if you put this in a git repo |
| `banner‑art.zsh` | generated art data (sunburst/title/dune strings), sourced by welcome‑banner.zsh | `~/.config/spice‑road/banner‑art.zsh` (WSL) |
| `generate_banner_art.py` | the art generator itself — regenerate if you widen/restyle the banner | build tool, keep alongside `palette.py` |
| `fastfetch‑config.jsonc` | system‑stats module selection | `~/.config/fastfetch/config.jsonc` (WSL) |
| `zshrc‑additions.zsh` | plugin list + exports + source lines | appended to `~/.zshrc` (WSL) |
| `spice‑road‑background.png` | WT background art | anywhere on Windows filesystem, e.g. `C:\Users\<you>\Pictures\Terminal\` |
| `generate_background.py` | the generator itself — regenerate/tweak motifs, seed, or colors anytime | build tool, keep alongside `palette.py` if you want to re‑run it |
| `preview‑at‑0.14‑opacity.png` | reference mockup showing the art composited at the real recommended opacity with sample prompt text on top | reference only, not deployed |
| `.pre‑commit‑config.yaml` | lint hook: shellcheck on `*.sh`, `zsh -n` on `*.zsh` | project root of wherever you keep these files in git |
| `SETUP‑GUIDE.md` | final polished step‑by‑step for the user | reference document only |
| `tmux.conf` | themed tmux status bar — session/window chrome + git branch, load, battery, clock (complements Starship, doesn't duplicate it) | `~/.tmux.conf` (WSL) |

---

## 13. Future extensions (not built now, noted for later)

- Kubernetes context module (4‑line TOML addition).
- `eza`/`bat` custom theme files matching the palette exactly (currently just installed + enabled).
- tmux status bar themed to match, for anyone who wants persistent multiplexed sessions — offered as an optional add‑on, not assumed.
- Battery module could gain a low‑battery color threshold (currently single static color).
- **systemd timer for battery cache** — instead of `battery.sh` triggering a background refresh on staleness, a `systemd --user` timer could update the cache on a fixed schedule, fully decoupled from prompt rendering (requires `systemd=true` in `/etc/wsl.conf` and a WSL restart — genuinely a later refinement, not a blocker for the current design, which already doesn't block).

---

## 14. Open caveats (documented honestly, not glossed over)

- **WSL2 has no direct battery hardware access.** Solved with a two‑script split rather than a single stale‑check script, specifically so the prompt‑facing half never touches PowerShell:
  - `battery.sh` (what Starship actually calls, every prompt) only ever reads a cache file and checks its age — a stat + a cat. If stale, it forks `battery‑refresh.sh` fully detached (`nohup ... &`) and returns immediately.
  - `battery‑refresh.sh` (never called by Starship directly) does the actual slow `powershell.exe` round‑trip, off the prompt's critical path, and writes the cache atomically.
  - A lock file stops concurrent prompts (including across multiple terminal tabs) from stacking up redundant PowerShell calls while one refresh is in flight.
  - **Measured in the sandbox** with a mocked 1.2s‑slow PowerShell: cold‑cache prompt calls cost 25–47ms (fork overhead only), never the 1.2s. Warm‑cache reads cost ~11ms.
  - On a desktop with no battery, the refresher clears the cache and the module simply stays hidden — no error state, no false reading.
- **`azure` Starship module** — included and enabled; if the installed Starship version predates this module, it's a harmless no‑op to remove that one TOML block.
- **Font/icon rendering depends on the Nerd Font actually being selected** in Windows Terminal's profile — if glyphs show as boxes, that's the check to make first.

---

**Stray job‑control messages — early bug, later refactored away.**  
Early versions of `welcome-banner.zsh` sourced the weather fetch directly into the interactive shell, which caused backgrounded jobs to print spurious job‑control messages. We initially fixed that by switching `&` to `&!` (background + disown in one step). Later, we extracted the weather fetch into `weather-check.sh`, which always runs as a non‑interactive bash subprocess. That extraction inherently avoids any job‑control noise, so the current code does not use `&!` at all — the original fix was superseded. The historical test note is kept here for context:

- *Original test:* the `&!` approach was confirmed to eliminate the `[3] 728` / `[3] + 728 done ...` messages in a persistent pty session, while `setopt no_notify no_bg_nice` was found to only defer messages (NOTIFY) or change CPU scheduling (BG_NICE), not actually suppress them.

---

- [x] Pre‑commit lint hook (`.pre‑commit‑config.yaml`) — added after review flagged the gap. Verified ShellCheck does not support zsh at all (SC1071, confirmed by actually running it against our files); scoped ShellCheck to `*.sh` only and used `zsh -n` for `*.zsh`. Tested the real hook routing end‑to‑end in a throwaway git repo, including deliberately broken bash and zsh files to confirm both hooks actually catch errors rather than passing trivially.

- **`shellcheck‑py` in `.pre‑commit‑config.yaml`** fetches a prebuilt ShellCheck binary during its own pip install step. This sandbox's network allowlist blocks that specific download, so the *routing logic* (which files go to which hook) was verified with a locally‑installed ShellCheck substituted in instead — the actual shipped config uses the standard `shellcheck‑py` pre‑commit repo, which will fetch normally on an unrestricted machine.

- **Starship itself was not live‑compiled and run in the sandbox.** I tried — installed cargo, hit a rustc‑version mismatch on the latest release, pinned back to starship 1.20.1 (compatible with the available rustc 1.75), and let it compile against a dependency tree that includes a full git reimplementation (gitoxide) and D‑Bus bindings. It exceeded this tool's per‑call time limit twice. What *was* verified: the TOML parses correctly (`tomllib`), every module name and field matches Starship's well‑established config schema, and every custom‑module shell command (load average, network check, battery cache) was tested standalone and confirmed working. The one thing not verified live is Starship's own rendering of the final layout — worth a quick look on the actual WSL machine after setup.

- **tmux is more locale‑sensitive than zsh for Unicode rendering.** The sandbox initially rendered every symbol in `tmux.conf` as `_` — traced to having no UTF‑8 locale configured at all (confirmed: `LANG=`, everything `POSIX`). With `LANG=C.utf8` set, every symbol rendered correctly. WSL Ubuntu installs almost always have a proper locale already, but if tmux's status bar shows underscores/boxes instead of symbols, `locale` is the first thing to check — not the config.

## Build status tracker

- [x] Palette locked (`palette.py`)
- [x] Windows Terminal color scheme (`windows‑terminal‑scheme.json`) — JSON‑validated
- [x] Starship prompt (`starship.toml`) — TOML‑validated
- [x] Windows Terminal profile settings (`windows‑terminal‑profile‑settings.json`) — font/cursor/padding/background image/tab color
- [x] LS_COLORS (`ls_colors.zsh`) — generated from palette, verified against real GNU ls output on sample files
- [x] Battery helper scripts (`battery.sh` + `battery‑refresh.sh`) — tested against a mocked slow PowerShell, confirmed non‑blocking
- [x] Background image (`spice‑road‑background.png`) — mandala medallion + layered dune horizon + night‑sky accents, opacity empirically tuned to 0.3 (tested on real displays; the earlier 0.14 was invisible on most screens)
- [x] Welcome banner + ASCII art + weather + quotes (`welcome‑banner.zsh` + `banner‑art.zsh` + `generate_banner_art.py`) — installed real zsh in the sandbox and ran it end‑to‑end; caught and fixed two real bugs (unexpanded `\u` escapes in double‑quoted strings, and a sandbox proxy response being silently cached as fake weather) before shipping
- [x] fastfetch config (`fastfetch‑config.jsonc`) — built fastfetch 2.65.3 from source in the sandbox and tested the real config against it; module list trimmed to what's meaningful under WSL
- [x] zsh plugin stack + `.zshrc` additions (`zshrc‑additions.zsh`) — tested against a genuinely fresh oh‑my‑zsh install with all four community plugins really cloned (zsh‑autosuggestions, zsh‑completions, fzf‑tab, zsh‑syntax‑highlighting) and real fzf/eza/bat/zoxide via apt. Found and fixed a real bug: oh‑my‑zsh's bundled "fzf" plugin has fragile hardcoded path‑detection that broke on a standard apt install — replaced with direct, defensive fzf integration (tries `fzf --zsh` first, falls back through known file paths). Confirmed both plugins functionally active (not just cloned) by checking their real internal function names after shell init, and confirmed ZSH_HIGHLIGHT_STYLES overrides merged correctly with the plugin's own defaults (48 total keys). Starship itself could not be live‑compiled in the sandbox (see §14) — everything else in the chain was verified with a real binary.
- [x] Final polished setup guide with exact execution order (`SETUP‑GUIDE.md`)
- [x] tmux status bar (`tmux.conf`) — built after PLAN.md §13 flagged it as an optional stretch goal; tested against a real tmux 3.4 binary, including a genuine locale‑related rendering bug (sandbox had no UTF‑8 locale) that was root‑caused rather than assumed
- [x] `weather‑check.sh` extracted from `welcome‑banner.zsh`'s inline logic, so `spice‑prefetch.sh` can reuse the exact same lock/staleness handling instead of duplicating it — re‑tested against the same scenarios as the original inline version, all identical, plus confirmed job‑control noise is gone (root cause: the fork now happens inside a non‑interactive bash subprocess, not directly in the interactive zsh)
- [x] `spice‑prefetch.sh` — tested with 3 concurrent simulated tabs against a mocked slow PowerShell: exactly 1 call fired, not 3 (the bug found in an external review's version of this idea)
- [x] `validate.sh` — the version reviewed externally had a real bug (its `check()` was gated behind `&&`, so failures printed nothing); rewritten so every check explicitly reports ✓ or ✗, proven against both a passing and a deliberately‑missing case
- [x] `preview‑colors.sh` — the externally‑reviewed version had a real bug (hex‑keyed associative array with two duplicate keys silently dropped 2 of 28 color labels); rebuilt as an ordered list generated directly from `palette.py`
- [x] `.pre‑commit‑config.yaml` extended with real JSONC (via `json5`) and TOML validation hooks, plus `.github/workflows/lint.yml` that runs the same config in CI rather than a parallel one — all four hooks tested against real files (pass) and deliberately broken ones (correctly fail)