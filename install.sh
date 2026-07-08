#!/bin/bash
#
# install.sh — The Spice Road: WSL2 Terminal Cockpit Installer
#
# Project:   The Spice Road (60% Dune desert sci-fantasy × 40% Rajasthani
#            Indian folk maximalism)
# Repo:      https://github.com/adityajha1606/spice-road
# Target:    WSL2 Ubuntu 22.04 LTS + Windows Terminal (Store), Windows 11.
#            oh-my-zsh is assumed already installed.
#
# Run this from the root of the cloned repository:
#   ./install.sh            # normal run (will prompt for confirmation + sudo)
#   ./install.sh --dry-run  # print what would happen, touch nothing
#
# The script is idempotent — safe to re-run.
#
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────
#  Globals
# ─────────────────────────────────────────────────────────────────────────

# Resolve repo root as the directory this script lives in, not $PWD, so the
# installer works correctly regardless of where it's invoked from.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DRY_RUN=false
LOG_PREFIX="[Spice Road]"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Populated during installation
WIN_USER=""
FONT_FACE="Iosevka TermSlab NF"   # fallback default per spec

# ─────────────────────────────────────────────────────────────────────────
#  Logging helpers
# ─────────────────────────────────────────────────────────────────────────

log()     { echo -e "${CYAN}${LOG_PREFIX}${NC} $1"; }
success() { echo -e "${GREEN}${LOG_PREFIX}${NC} $1"; }
warn()    { echo -e "${YELLOW}${LOG_PREFIX} WARNING:${NC} $1"; }
error_exit() { echo -e "${RED}${LOG_PREFIX} ERROR:${NC} $1" >&2; exit 1; }

# Safety net: if anything escapes our explicit error handling, fail loudly
# with a clear message instead of a bare bash stack trace.
trap 'echo -e "${RED}${LOG_PREFIX} ERROR:${NC} Unexpected failure near line ${LINENO}. Aborting." >&2' ERR

# run <cmd string> — executes a command, or just prints it under --dry-run.
# Returns the underlying command's exit status (0 for a dry-run preview).
run() {
    if $DRY_RUN; then
        echo -e "  ${YELLOW}[dry-run]${NC} $*"
        return 0
    fi
    eval "$@"
}

# ─────────────────────────────────────────────────────────────────────────
#  Arg parsing
# ─────────────────────────────────────────────────────────────────────────

for arg in "$@"; do
    case "$arg" in
        --dry-run)
            DRY_RUN=true
            ;;
        -h|--help)
            echo "Usage: ./install.sh [--dry-run]"
            echo "  --dry-run   Show what the installer would do without changing anything."
            exit 0
            ;;
        *)
            warn "Unknown argument: $arg (ignored)"
            ;;
    esac
done

# ─────────────────────────────────────────────────────────────────────────
#  Step 1 — Welcome & confirmation
# ─────────────────────────────────────────────────────────────────────────

print_banner() {
cat << 'BANNER'

   ███████╗██████╗ ██╗ ██████╗███████╗    ██████╗  ██████╗  █████╗ ██████╗
   ██╔════╝██╔══██╗██║██╔════╝██╔════╝    ██╔══██╗██╔═══██╗██╔══██╗██╔══██╗
   ███████╗██████╔╝██║██║     █████╗      ██████╔╝██║   ██║███████║██║  ██║
   ╚════██║██╔═══╝ ██║██║     ██╔══╝      ██╔══██╗██║   ██║██╔══██║██║  ██║
   ███████║██║     ██║╚██████╗███████╗    ██║  ██║╚██████╔╝██║  ██║██████╔╝
   ╚══════╝╚═╝     ╚═╝ ╚═════╝╚══════╝    ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝

        60% Dune desert sci-fantasy × 40% Rajasthani folk maximalism
                    WSL2 Terminal Cockpit Installer
BANNER
}

confirm_start() {
    print_banner
    echo ""
    if $DRY_RUN; then
        log "Running in --dry-run mode. No files will be changed, nothing will be installed."
    fi
    read -r -p "$(echo -e "${CYAN}${LOG_PREFIX}${NC} Proceed with installation? [y/N] ")" answer
    case "$answer" in
        [Yy]*) ;;
        *) echo "Aborted. Nothing was changed."; exit 0 ;;
    esac
    echo ""
}

# ─────────────────────────────────────────────────────────────────────────
#  Step 2 — Detect Windows username
# ─────────────────────────────────────────────────────────────────────────

detect_windows_username() {
    log "Detecting Windows username..."
    WIN_USER=$(powershell.exe -NoProfile -Command '[System.Environment]::UserName' 2>/dev/null \
        | tr -d '\r\n' | xargs) || true

    if [[ -z "$WIN_USER" ]]; then
        error_exit "Could not detect the Windows username via powershell.exe. Is WSL interop working?"
    fi
    success "Windows username detected: $WIN_USER"
}

# ─────────────────────────────────────────────────────────────────────────
#  Step 3 — Font auto-detection
# ─────────────────────────────────────────────────────────────────────────

detect_font() {
    log "Detecting installed Nerd Fonts..."
    local font_list
    font_list=$(powershell.exe -NoProfile -Command \
        '(New-Object -ComObject Shell.Application).Namespace(0x14).Items() | % { $_.Name }' \
        2>/dev/null | tr -d '\r') || true

    # Exact-match check first (preferred), so "...NF" doesn't accidentally
    # match on the "...NFM" line via a loose substring grep.
    if echo "$font_list" | grep -qix "Iosevka TermSlab NF"; then
        FONT_FACE="Iosevka TermSlab NF"
    elif echo "$font_list" | grep -qix "Iosevka TermSlab NFM"; then
        FONT_FACE="Iosevka TermSlab NFM"
    elif echo "$font_list" | grep -qi "Victor Mono Nerd Font"; then
        FONT_FACE=$(echo "$font_list" | grep -i "Victor Mono Nerd Font" | head -n1)
    else
        warn "No matching Nerd Font found (looked for Iosevka TermSlab NF/NFM, Victor Mono Nerd Font)."
        warn "Falling back to default: $FONT_FACE"
    fi
    success "Using font family: $FONT_FACE"
}

# ─────────────────────────────────────────────────────────────────────────
#  Step 4 — Package installation
# ─────────────────────────────────────────────────────────────────────────

install_eza() {
    if command -v eza &>/dev/null; then
        log "eza already installed, skipping."
        return
    fi
    log "Installing eza via its official repo..."
    run "sudo apt install -y gpg"
    run "sudo mkdir -p /etc/apt/keyrings"
    run "wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg"
    run 'echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list'
    run "sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list"
    run "sudo apt update && sudo apt install -y eza"
    success "eza installed."
}

install_starship() {
    if command -v starship &>/dev/null; then
        log "starship already installed, skipping."
        return
    fi
    log "Installing starship..."
    run "curl -sS https://starship.rs/install.sh | sh -s -- -y"
    success "starship installed."
}

install_fastfetch() {
    if command -v fastfetch &>/dev/null; then
        log "fastfetch already installed, skipping."
        return
    fi
    log "Installing fastfetch 2.65.2..."
    run "wget -q https://github.com/fastfetch-cli/fastfetch/releases/download/2.65.2/fastfetch-linux-amd64.deb -O /tmp/fastfetch-linux-amd64.deb"
    run "sudo dpkg -i /tmp/fastfetch-linux-amd64.deb"
    run "rm -f /tmp/fastfetch-linux-amd64.deb"
    success "fastfetch installed."
}

install_packages() {
    log "Running apt update..."
    if ! run "sudo apt update"; then
        error_exit "apt update failed. Aborting."
    fi

    log "Installing core packages: build-essential cmake git curl fzf bat zoxide"
    if ! run "sudo apt install -y build-essential cmake git curl fzf bat zoxide"; then
        error_exit "Core package installation failed. Aborting."
    fi

    install_eza
    install_starship
    install_fastfetch
}

# ─────────────────────────────────────────────────────────────────────────
#  Step 5 — oh-my-zsh plugins
# ─────────────────────────────────────────────────────────────────────────

install_omz_plugins() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        warn "oh-my-zsh not found at \$HOME/.oh-my-zsh. Skipping plugin installation."
        return
    fi

    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    log "Installing oh-my-zsh plugins into $zsh_custom/plugins ..."
    mkdir -p "$zsh_custom/plugins"

    _clone_plugin() {
        local name="$1" url="$2"
        local dest="$zsh_custom/plugins/$name"
        if [[ -d "$dest" ]]; then
            log "  Plugin '$name' already present, skipping."
        else
            run "git clone --depth 1 $url $dest"
            success "  Cloned plugin: $name"
        fi
    }

    _clone_plugin "zsh-autosuggestions"    "https://github.com/zsh-users/zsh-autosuggestions"
    _clone_plugin "zsh-completions"        "https://github.com/zsh-users/zsh-completions"
    _clone_plugin "fzf-tab"                "https://github.com/Aloxaf/fzf-tab"
    _clone_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"
}

# ─────────────────────────────────────────────────────────────────────────
#  Step 6 — Copy runtime files
# ─────────────────────────────────────────────────────────────────────────

copy_runtime_files() {
    log "Creating config directories..."
    mkdir -p "$HOME/.config/spice-road"
    mkdir -p "$HOME/.config/starship-helpers"
    mkdir -p "$HOME/.config/fastfetch"

    log "Copying runtime files..."
    _copy_if_exists() {
        local src="$REPO_ROOT/$1" dest="$2"
        if [[ -f "$src" ]]; then
            run "cp -f '$src' '$dest'"
        else
            warn "  Source file not found in repo (skipped): $1"
        fi
    }

    _copy_if_exists "starship.toml"              "$HOME/.config/starship.toml"
    _copy_if_exists "ls_colors.zsh"               "$HOME/.config/spice-road/ls_colors.zsh"
    _copy_if_exists "welcome-banner.zsh"          "$HOME/.config/spice-road/welcome-banner.zsh"
    _copy_if_exists "banner-art.zsh"              "$HOME/.config/spice-road/banner-art.zsh"
    _copy_if_exists "weather-check.sh"            "$HOME/.config/spice-road/weather-check.sh"
    _copy_if_exists "spice-prefetch.zsh"           "$HOME/.config/spice-road/spice-prefetch.sh"
    _copy_if_exists "battery.sh"                  "$HOME/.config/starship-helpers/battery.sh"
    _copy_if_exists "battery-refresh.sh"          "$HOME/.config/starship-helpers/battery-refresh.sh"
    _copy_if_exists "fastfetch-config-full.jsonc" "$HOME/.config/fastfetch/config.jsonc"
    _copy_if_exists "fastfetch-config-safe.jsonc" "$HOME/.config/fastfetch/fastfetch-config-safe.jsonc"

    log "Setting execute permissions..."
    for f in battery.sh battery-refresh.sh weather-check.sh spice-prefetch.zsh; do
        for dir in "$HOME/.config/starship-helpers" "$HOME/.config/spice-road"; do
            if [[ -f "$dir/$f" ]]; then
                run "chmod +x '$dir/$f'"
            fi
        done
    done

    success "Runtime files copied."
}

# ─────────────────────────────────────────────────────────────────────────
#  Step 7 — Copy background image to Windows filesystem
# ─────────────────────────────────────────────────────────────────────────

copy_background_image() {
    log "Copying background image to the Windows filesystem..."
    local src="$REPO_ROOT/spice-road-background.png"
    local dest_dir_wsl="/mnt/c/Users/$WIN_USER/Pictures/Terminal"

    if [[ ! -f "$src" ]]; then
        warn "spice-road-background.png not found in repo root. Skipping."
        return
    fi

    run "mkdir -p '$dest_dir_wsl'"
    run "cp -f '$src' '$dest_dir_wsl/spice-road-background.png'"
    success "Background image copied to C:\\Users\\$WIN_USER\\Pictures\\Terminal\\spice-road-background.png"
}

# ─────────────────────────────────────────────────────────────────────────
#  Step 8 — Patch .zshrc
# ─────────────────────────────────────────────────────────────────────────

patch_zshrc() {
    local zshrc="$HOME/.zshrc"
    if [[ ! -f "$zshrc" ]]; then
        warn ".zshrc not found at $zshrc. Skipping shell config patch."
        return
    fi

    log "Patching .zshrc..."

    # Backup once, never overwrite an existing backup.
    if [[ ! -f "$zshrc.backup" ]]; then
        run "cp '$zshrc' '$zshrc.backup'"
        success "  Backed up .zshrc -> .zshrc.backup"
    else
        log "  Backup already exists (.zshrc.backup), leaving it untouched."
    fi

    # 1) Disable the oh-my-zsh theme; starship will own the prompt.
    if grep -q '^ZSH_THEME="robbyrussell"' "$zshrc"; then
        run "sed -i 's/^ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"\"/' '$zshrc'"
        success "  Disabled oh-my-zsh theme (robbyrussell -> none)."
    else
        log "  ZSH_THEME already customized, leaving as-is."
    fi

    # 2) Enable our plugins, idempotently.
    if grep -q '^plugins=(git zsh-autosuggestions zsh-completions fzf-tab zsh-syntax-highlighting)' "$zshrc"; then
        log "  Plugins already configured, skipping."
    elif grep -q '^plugins=(git)' "$zshrc"; then
        run "sed -i 's/^plugins=(git)/plugins=(git zsh-autosuggestions zsh-completions fzf-tab zsh-syntax-highlighting)/' '$zshrc'"
        success "  Updated plugins list."
    else
        warn "  Could not find a 'plugins=(git)' line to patch. Add the Spice Road plugins manually:"
        warn "    plugins=(git zsh-autosuggestions zsh-completions fzf-tab zsh-syntax-highlighting)"
    fi

    # 3) Append the "Part B" block from zshrc-additions.zsh exactly once,
    #    guarded by a marker line at the end of the file.
    if tail -n1 "$zshrc" 2>/dev/null | grep -q '### SPICE ROAD INSTALLED ###'; then
        log "  Spice Road shell additions already present, skipping."
    else
        local additions_src="$REPO_ROOT/zshrc-additions.zsh"
        if [[ -f "$additions_src" ]]; then
            if $DRY_RUN; then
                echo -e "  ${YELLOW}[dry-run]${NC} would append Part B of zshrc-additions.zsh + marker to $zshrc"
            else
                {
                    echo ""
                    awk '/^# PART B/{flag=1} flag' "$additions_src"
                    echo "### SPICE ROAD INSTALLED ###"
                } >> "$zshrc"
                success "  Appended Spice Road shell additions."
            fi
        else
            warn "  zshrc-additions.zsh not found in repo root. Skipping Part B append."
        fi
    fi
}

# ─────────────────────────────────────────────────────────────────────────
#  Step 9 — Inject Windows Terminal settings
# ─────────────────────────────────────────────────────────────────────────

inject_windows_terminal() {
    log "Preparing Windows Terminal settings injection..."

    local win_temp_wsl="/mnt/c/Users/$WIN_USER/AppData/Local/Temp"
    local ps1_wsl_path="$win_temp_wsl/spice-road-inject-wt.ps1"
    local ps1_win_path="C:\\Users\\$WIN_USER\\AppData\\Local\\Temp\\spice-road-inject-wt.ps1"
    local bg_win_path="C:/Users/$WIN_USER/Pictures/Terminal/spice-road-background.png"

    mkdir -p "$win_temp_wsl" 2>/dev/null || true

    # NOTE: heredoc delimiter is single-quoted ('PS1EOF') so bash does not
    # try to expand any $variables inside the PowerShell script below —
    # those are PowerShell's own $FontFamily/$BackgroundPath/$_ etc.
    cat > "$ps1_wsl_path" << 'PS1EOF'
param(
    [Parameter(Mandatory=$true)][string]$FontFamily,
    [Parameter(Mandatory=$true)][string]$BackgroundPath
)

$ErrorActionPreference = "Stop"

# --- Locate settings.json (Store package first, then unpackaged fallback) ---
$candidatePaths = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
)

$settingsPath = $null
foreach ($p in $candidatePaths) {
    if (Test-Path $p) { $settingsPath = $p; break }
}

if (-not $settingsPath) {
    Write-Host "[Spice Road] Could not locate Windows Terminal settings.json. Skipping." -ForegroundColor Yellow
    exit 1
}

Write-Host "[Spice Road] Found settings.json at: $settingsPath"

# --- Backup original before touching anything ---
$backupPath = "$settingsPath.backup"
Copy-Item -Path $settingsPath -Destination $backupPath -Force
Write-Host "[Spice Road] Backed up settings.json -> $backupPath"

try {
    $raw = Get-Content -Path $settingsPath -Raw
    $settings = $raw | ConvertFrom-Json

    # --- Spice Road color scheme (hardcoded per spec) ---
    $spiceScheme = [ordered]@{
        name                = "Spice Road"
        background          = "#14100D"
        foreground          = "#F2E6D8"
        cursorColor         = "#E8A33D"
        selectionBackground = "#4A3423"
        black               = "#1A1410"
        red                 = "#B5502D"
        green               = "#7C8B3D"
        yellow              = "#E8A33D"
        blue                = "#3E5578"
        purple              = "#7B3F61"
        cyan                = "#2E8C82"
        white               = "#D9C7A3"
        brightBlack         = "#6B5D4F"
        brightRed           = "#E8623A"
        brightGreen         = "#A8BB5C"
        brightYellow        = "#F2C14E"
        brightBlue          = "#6A87B8"
        brightPurple        = "#B0609E"
        brightCyan          = "#4FB8AC"
        brightWhite         = "#F2E6D8"
    }

    if (-not $settings.schemes) {
        $settings | Add-Member -NotePropertyName "schemes" -NotePropertyValue @() -Force
    }
    # Drop any prior "Spice Road" scheme so re-runs don't duplicate it.
    $schemesList = @($settings.schemes | Where-Object { $_.name -ne "Spice Road" })
    $schemesList += (New-Object PSObject -Property $spiceScheme)
    $settings.schemes = $schemesList

    # --- Find the Ubuntu-22.04 WSL profile, falling back to any WSL profile ---
    $profileList = $settings.profiles.list
    $target = $profileList | Where-Object { $_.source -eq "Microsoft.WSL" -and $_.name -like "*Ubuntu*" } | Select-Object -First 1
    if (-not $target) {
        $target = $profileList | Where-Object { $_.source -eq "Microsoft.WSL" } | Select-Object -First 1
    }

    if (-not $target) {
        Write-Host "[Spice Road] No Microsoft.WSL profile found. Skipping profile patch." -ForegroundColor Yellow
    } else {
        if (-not $target.font) {
            $target | Add-Member -NotePropertyName "font" -NotePropertyValue (New-Object PSObject) -Force
        }
        $target.font | Add-Member -NotePropertyName "face"   -NotePropertyValue $FontFamily -Force
        $target.font | Add-Member -NotePropertyName "size"   -NotePropertyValue 11.5 -Force
        $target.font | Add-Member -NotePropertyName "weight" -NotePropertyValue "normal" -Force

        $target | Add-Member -NotePropertyName "colorScheme"                -NotePropertyValue "Spice Road" -Force
        $target | Add-Member -NotePropertyName "cursorShape"                -NotePropertyValue "bar" -Force
        $target | Add-Member -NotePropertyName "cursorColor"                -NotePropertyValue "#E8A33D" -Force
        $target | Add-Member -NotePropertyName "padding"                    -NotePropertyValue "10, 8, 10, 8" -Force
        $target | Add-Member -NotePropertyName "tabColor"                   -NotePropertyValue "#8C6239" -Force
        $target | Add-Member -NotePropertyName "backgroundImage"            -NotePropertyValue $BackgroundPath -Force
        $target | Add-Member -NotePropertyName "backgroundImageOpacity"     -NotePropertyValue 0.3 -Force
        $target | Add-Member -NotePropertyName "backgroundImageStretchMode" -NotePropertyValue "uniformToFill" -Force
        $target | Add-Member -NotePropertyName "backgroundImageAlignment"   -NotePropertyValue "center" -Force
        $target | Add-Member -NotePropertyName "useAcrylic"                 -NotePropertyValue $false -Force
        $target | Add-Member -NotePropertyName "opacity"                    -NotePropertyValue 100 -Force

        Write-Host "[Spice Road] Patched profile: $($target.name)"
    }

    $json = $settings | ConvertTo-Json -Depth 10
    Set-Content -Path $settingsPath -Value $json -Encoding UTF8
    Write-Host "[Spice Road] Windows Terminal settings.json updated successfully."
}
catch {
    Write-Host "[Spice Road] ERROR patching settings.json: $_" -ForegroundColor Red
    Write-Host "[Spice Road] Restoring backup..." -ForegroundColor Yellow
    Copy-Item -Path $backupPath -Destination $settingsPath -Force
    exit 1
}
PS1EOF

    if $DRY_RUN; then
        echo -e "  ${YELLOW}[dry-run]${NC} would run: powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"$ps1_win_path\" -FontFamily \"$FONT_FACE\" -BackgroundPath \"$bg_win_path\""
        return
    fi

    if powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$ps1_win_path" \
        -FontFamily "$FONT_FACE" -BackgroundPath "$bg_win_path"; then
        success "Windows Terminal settings injected."
    else
        warn "Windows Terminal injection reported an error — check the PowerShell output above."
    fi
}

# ─────────────────────────────────────────────────────────────────────────
#  Step 10 — Optional: spice-prefetch.zsh activation
# ─────────────────────────────────────────────────────────────────────────

maybe_enable_prefetch() {
    local zshrc="$HOME/.zshrc"
    [[ -f "$zshrc" ]] || return

    echo ""
    read -r -p "$(echo -e "${CYAN}${LOG_PREFIX}${NC} Enable early battery/weather prefetch on shell startup? [y/N] ")" answer
    case "$answer" in
        [Yy]*)
            local marker="# SPICE ROAD PREFETCH HOOK"
            if grep -qF "$marker" "$zshrc"; then
                log "Prefetch hook already present, skipping."
                return
            fi

            if $DRY_RUN; then
                echo -e "  ${YELLOW}[dry-run]${NC} would insert prefetch hook near the top of .zshrc"
                return
            fi

            local tmp
            tmp=$(mktemp)
            {
                echo "$marker"
                echo '[[ -f "$HOME/.config/spice-road/spice-prefetch.zsh" ]] && source "$HOME/.config/spice-road/spice-prefetch.sh"'
                echo ""
                cat "$zshrc"
            } > "$tmp"
            mv "$tmp" "$zshrc"
            success "Prefetch hook inserted at the top of .zshrc (before oh-my-zsh loads)."
            ;;
        *)
            log "Skipping prefetch activation."
            ;;
    esac
}

# ─────────────────────────────────────────────────────────────────────────
#  Step 11 — Run validation
# ─────────────────────────────────────────────────────────────────────────

run_validation() {
    local validate_script="$REPO_ROOT/validate.sh"
    if [[ ! -f "$validate_script" ]]; then
        warn "validate.sh not found in repo root. Skipping validation step."
        return
    fi

    log "Running validate.sh..."
    if $DRY_RUN; then
        echo -e "  ${YELLOW}[dry-run]${NC} would run: bash '$validate_script'"
        return
    fi

    if bash "$validate_script"; then
        success "Validation passed."
    else
        warn "validate.sh reported issues — see output above."
    fi
}

# ─────────────────────────────────────────────────────────────────────────
#  Step 12 — Final message
# ─────────────────────────────────────────────────────────────────────────

final_message() {
    echo ""
    echo -e "${GREEN}${BOLD}The Spice Road installation is complete.${NC}"
    echo -e "  ${CYAN}→${NC} Close ALL Windows Terminal windows completely (not just the tab)."
    echo -e "  ${CYAN}→${NC} Open a new Ubuntu-22.04 tab to enter the cockpit."
    echo -e "  ${CYAN}→${NC} Background image: C:\\Users\\$WIN_USER\\Pictures\\Terminal\\spice-road-background.png"
    echo -e "  ${CYAN}→${NC} Font in use: $FONT_FACE"
    echo -e "  ${CYAN}→${NC} fastfetch config: full profile active; safe fallback saved alongside it."
    echo ""
    echo -e "  May your spice flow and your prompt never lag."
    echo ""
}

# ─────────────────────────────────────────────────────────────────────────
#  Main
# ─────────────────────────────────────────────────────────────────────────

main() {
    confirm_start
    detect_windows_username
    detect_font
    install_packages
    install_omz_plugins
    copy_runtime_files
    copy_background_image
    patch_zshrc
    inject_windows_terminal
    maybe_enable_prefetch
    run_validation
    final_message
}

main "$@"
