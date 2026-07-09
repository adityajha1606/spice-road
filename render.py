#!/usr/bin/env python3
"""
render.py — Regenerate all config files from the Spice Road palette.

Reads palette.py, then renders:
  - starship.toml          (from templates/starship.toml.j2)
  - windows-terminal-scheme.json (from templates/windows-terminal-scheme.json.j2)
  - windows-terminal-profile-settings.json (from templates/windows-terminal-profile-settings.json.j2)
  - ls_colors.zsh          (generated directly, no template needed)

Usage:  python3 render.py
After running, inspect the changed files and commit.
"""

import sys
from palette import palette
from jinja2 import Environment, FileSystemLoader

# ---------- helper ----------
def hex_to_rgb(hex_str: str) -> tuple[int, int, int]:
    """Convert '#RRGGBB' to (R, G, B). Raises ValueError on bad input."""
    h = hex_str.lstrip('#')
    if len(h) != 6:
        raise ValueError(f"Invalid hex color '{hex_str}': expected 6 hex digits")
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

# ---------- LS_COLORS generation ----------
def generate_ls_colors(palette):
    """Build the full LS_COLORS string from the palette."""

    di_bg     = palette['duskIndigo']
    di_fg     = palette['fg']
    ln_color  = palette['cyan']
    ex_color  = palette['brightRed']
    or_color  = palette['brightRed']
    archive   = palette['vermillion']
    image     = palette['yellow']
    media_color = palette['purple']   # renamed to avoid shadowing
    doc       = palette['white']
    code      = palette['gold']

    def bg_truecolor(h):
        r, g, b = hex_to_rgb(h)
        return f"48;2;{r};{g};{b}"
    def fg_truecolor(h):
        r, g, b = hex_to_rgb(h)
        return f"38;2;{r};{g};{b}"

    parts = [
        "fi=0",
        f"di=1;{bg_truecolor(di_bg)};{fg_truecolor(di_fg)}",
        f"ln=1;{fg_truecolor(ln_color)}",
        f"ex=1;{fg_truecolor(ex_color)}",
        f"or=1;{fg_truecolor(or_color)};4",
        f"mi=1;{fg_truecolor(or_color)};4",
        f"pi={fg_truecolor(palette['henna'])}",
        f"so={fg_truecolor(palette['cyan'])}",
        f"bd={bg_truecolor(palette['bronze'])};{fg_truecolor(palette['fg'])}",
        f"cd={bg_truecolor(palette['bronze'])};{fg_truecolor(palette['brightYellow'])}",
        f"su=1;{bg_truecolor(palette['vermillion'])};{fg_truecolor(palette['fg'])}",
        f"sg=1;{bg_truecolor(palette['vermillion'])};{fg_truecolor(palette['fg'])}",
        f"tw={bg_truecolor(palette['duskIndigo'])};{fg_truecolor(palette['green'])}",
        f"ow={bg_truecolor(palette['duskIndigo'])};{fg_truecolor(palette['brightGreen'])}",
        f"st={bg_truecolor(palette['duskIndigo'])};{fg_truecolor(palette['bronze'])}",
    ]

    archives  = ['tar','gz','bz2','xz','zst','zip','rar','7z','tgz','tbz2','iso','dmg','deb','rpm']
    images    = ['jpg','jpeg','png','gif','bmp','svg','webp','tiff','ico','heic','avif']
    media_exts= ['mp4','mkv','avi','mov','webm','flac','mp3','wav','ogg','m4a','m4v','flv']
    documents = ['pdf','md','doc','docx','txt','odt','rtf','epub','rst']
    code_exts = ['py','js','ts','tsx','jsx','rs','go','c','h','cpp','hpp',
                 'java','rb','sh','zsh','bash','toml','json','yaml','yml',
                 'html','css','scss','sql','lua','php']

    for ext in archives:   parts.append(f"*.{ext}={fg_truecolor(archive)}")
    for ext in images:     parts.append(f"*.{ext}={fg_truecolor(image)}")
    for ext in media_exts: parts.append(f"*.{ext}={fg_truecolor(media_color)}")
    for ext in documents:  parts.append(f"*.{ext}={fg_truecolor(doc)}")
    for ext in code_exts:  parts.append(f"*.{ext}={fg_truecolor(code)}")

    return 'export LS_COLORS=\'' + ':'.join(parts) + ':\'\nexport EZA_COLORS="$LS_COLORS"\n'

# ---------- Template rendering ----------
def render_templates(palette):
    try:
        env = Environment(loader=FileSystemLoader('templates'))
    except Exception as e:
        sys.exit(f"Error loading templates: {e}")

    ctx = {'palette': palette}
    ctx['styles'] = {
        'directory_style':        f"bg:{palette['bronze']} fg:{palette['fg']}",
        'directory_readonly':     f"fg:{palette['brightRed']}",
        'git_branch_style':       f"bg:{palette['duskIndigo']} fg:{palette['fg']}",
        'git_status_style':       f"bg:{palette['red']} fg:{palette['fg']}",
        'python_style':           f"bg:{palette['yellow']} fg:{palette['bg']}",
        'nodejs_style':           f"bg:{palette['green']} fg:{palette['bg']}",
        'docker_style':           f"bg:{palette['peacockDeep']} fg:{palette['fg']}",
        'aws_style':              f"bg:{palette['vermillion']} fg:{palette['fg']}",
        'gcloud_style':           f"bg:{palette['brightBlue']} fg:{palette['bg']}",
        'azure_style':            f"bg:{palette['blue']} fg:{palette['fg']}",
        'hostname_style':         f"bg:{palette['purple']} fg:{palette['fg']}",
        'jobs_style':             f"fg:{palette['copper']}",
        'memory_style':           f"fg:{palette['brightPurple']}",
        'cmd_duration_style':     f"fg:{palette['brightBlack']}",
        'status_style':           f"bg:{palette['brightRed']} fg:{palette['bg']} bold",
        'load_style':             f"fg:{palette['gold']}",
        'net_ok_style':           f"fg:{palette['brightGreen']}",
        'net_down_style':         f"fg:{palette['brightRed']} bold",
        'battery_style':          f"fg:{palette['brightYellow']}",
        'character_success':      f"bold fg:{palette['yellow']}",
        'character_error':        f"bold fg:{palette['brightRed']}",
        'character_vimcmd':       f"bold fg:{palette['brightCyan']}",
        'time_style':             f"fg:{palette['fg_muted']}",
        'frame_color':            palette['bronze'],
    }

    # starship.toml
    try:
        template = env.get_template('starship.toml.j2')
        with open('starship.toml', 'w', encoding='utf-8') as f:
            f.write(template.render(ctx))
    except Exception as e:
        sys.exit(f"Error rendering starship.toml: {e}")

    # windows-terminal-scheme.json
    try:
        template = env.get_template('windows-terminal-scheme.json.j2')
        with open('windows-terminal-scheme.json', 'w', encoding='utf-8') as f:
            f.write(template.render(ctx))
    except Exception as e:
        sys.exit(f"Error rendering windows-terminal-scheme.json: {e}")

    # windows-terminal-profile-settings.json (JSONC, for manual merge)
    try:
        template = env.get_template('windows-terminal-profile-settings.json.j2')
        with open('windows-terminal-profile-settings.json', 'w', encoding='utf-8') as f:
            f.write(template.render(ctx))
    except Exception as e:
        sys.exit(f"Error rendering windows-terminal-profile-settings.json: {e}")

    # ls_colors.zsh
    try:
        with open('ls_colors.zsh', 'w', encoding='utf-8') as f:
            f.write("# Auto-generated from palette.py by render.py — do not hand-edit\n")
            f.write(generate_ls_colors(palette))
    except Exception as e:
        sys.exit(f"Error writing ls_colors.zsh: {e}")

    print("All configs regenerated from palette.py.")

if __name__ == '__main__':
    render_templates(palette)