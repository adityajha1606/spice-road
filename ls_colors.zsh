# Spice Road — LS_COLORS
# Generated from palette.py — truecolor (24-bit) SGR codes, so this looks
# identical regardless of terminal 256-color approximations.
#
# Legend (see PLAN.md §9 and §2 for the full palette table):
#   fi  regular files       — left neutral (0), so accents actually mean something
#   di  directories         — dusk indigo bg / parchment fg, bold
#   ln  symlinks            — peacock, bold
#   ex  executables         — bright red (rust family), bold
#   or  broken symlink      — bright red, bold + underline (distinct from ex)
#   mi  missing link target — same as 'or'
#   pi/so/bd/cd/su/sg/tw/ow/st — device/permission edge cases, themed for completeness
#   *.archive  (tar/zip/gz/…)  — vermillion
#   *.image    (png/jpg/svg/…) — marigold
#   *.media    (mp4/mp3/…)     — plum
#   *.doc      (pdf/md/txt/…)  — sand tan
#   *.code     (py/js/rs/…)    — gold
#
# One emergent behavior worth knowing: GNU ls prioritizes the executable-bit
# 'ex=' color over extension rules. A chmod +x'd .py or .sh file renders
# bright red, not gold — confirmed against real GNU ls below. That's a
# feature, not a bug: it flags "this runs" more urgently than "this is code."
#
# Zero runtime cost: this is a static string, computed once here, not
# regenerated on every shell start.

export LS_COLORS='fi=0:di=1;48;2;31;42;68;38;2;242;230;216:ln=1;38;2;46;140;130:ex=1;38;2;232;98;58:or=1;38;2;232;98;58;4:mi=1;38;2;232;98;58;4:pi=38;2;107;58;31:so=38;2;46;140;130:bd=48;2;140;98;57;38;2;242;230;216:cd=48;2;140;98;57;38;2;242;193;78:su=1;48;2;155;44;44;38;2;242;230;216:sg=1;48;2;155;44;44;38;2;242;230;216:tw=48;2;31;42;68;38;2;124;139;61:ow=48;2;31;42;68;38;2;168;187;92:st=48;2;31;42;68;38;2;140;98;57:*.tar=38;2;155;44;44:*.gz=38;2;155;44;44:*.bz2=38;2;155;44;44:*.xz=38;2;155;44;44:*.zst=38;2;155;44;44:*.zip=38;2;155;44;44:*.rar=38;2;155;44;44:*.7z=38;2;155;44;44:*.tgz=38;2;155;44;44:*.tbz2=38;2;155;44;44:*.iso=38;2;155;44;44:*.dmg=38;2;155;44;44:*.deb=38;2;155;44;44:*.rpm=38;2;155;44;44:*.jpg=38;2;232;163;61:*.jpeg=38;2;232;163;61:*.png=38;2;232;163;61:*.gif=38;2;232;163;61:*.bmp=38;2;232;163;61:*.svg=38;2;232;163;61:*.webp=38;2;232;163;61:*.tiff=38;2;232;163;61:*.ico=38;2;232;163;61:*.heic=38;2;232;163;61:*.avif=38;2;232;163;61:*.mp4=38;2;123;63;97:*.mkv=38;2;123;63;97:*.avi=38;2;123;63;97:*.mov=38;2;123;63;97:*.webm=38;2;123;63;97:*.flac=38;2;123;63;97:*.mp3=38;2;123;63;97:*.wav=38;2;123;63;97:*.ogg=38;2;123;63;97:*.m4a=38;2;123;63;97:*.m4v=38;2;123;63;97:*.flv=38;2;123;63;97:*.pdf=38;2;217;199;163:*.md=38;2;217;199;163:*.doc=38;2;217;199;163:*.docx=38;2;217;199;163:*.txt=38;2;217;199;163:*.odt=38;2;217;199;163:*.rtf=38;2;217;199;163:*.epub=38;2;217;199;163:*.rst=38;2;217;199;163:*.py=38;2;212;175;55:*.js=38;2;212;175;55:*.ts=38;2;212;175;55:*.tsx=38;2;212;175;55:*.jsx=38;2;212;175;55:*.rs=38;2;212;175;55:*.go=38;2;212;175;55:*.c=38;2;212;175;55:*.h=38;2;212;175;55:*.cpp=38;2;212;175;55:*.hpp=38;2;212;175;55:*.java=38;2;212;175;55:*.rb=38;2;212;175;55:*.sh=38;2;212;175;55:*.zsh=38;2;212;175;55:*.bash=38;2;212;175;55:*.toml=38;2;212;175;55:*.json=38;2;212;175;55:*.yaml=38;2;212;175;55:*.yml=38;2;212;175;55:*.html=38;2;212;175;55:*.css=38;2;212;175;55:*.scss=38;2;212;175;55:*.sql=38;2;212;175;55:*.lua=38;2;212;175;55:*.php=38;2;212;175;55:'

# eza (the modern ls in the plugin stack, §8) understands LS_COLORS directly
# for file-type coloring. A richer EZA_COLORS (git status / permission
# coloring on top of this) is the eza theme file noted in PLAN.md §13 —
# not built yet, deliberately deferred.
export EZA_COLORS="$LS_COLORS"
