# Spice Road palette — single source of truth
# 60% Dune desert-mirage sci-fantasy / 40% Rajasthani-Indian folk maximalist bazaar

palette = {
    # core surfaces
    "bg":            "#14100D",  # near-black warm umber, night desert sky
    "fg":            "#F2E6D8",  # parchment sand
    "fg_muted":      "#C9B79C",  # dusty tan
    "selection":     "#4A3423",  # muted bronze-brown
    "cursor":        "#E8A33D",  # marigold gold

    # ANSI 16 (normal)
    "black":         "#1A1410",
    "red":           "#B5502D",  # rust / terracotta
    "green":         "#7C8B3D",  # desert moss / olive
    "yellow":        "#E8A33D",  # marigold / saffron
    "blue":          "#3E5578",  # indigo (brightened for legibility)
    "purple":        "#7B3F61",  # plum / amethyst
    "cyan":          "#2E8C82",  # peacock teal (brightened)
    "white":         "#D9C7A3",  # sand tan

    # ANSI 16 (bright)
    "brightBlack":   "#6B5D4F",
    "brightRed":     "#E8623A",
    "brightGreen":   "#A8BB5C",
    "brightYellow":  "#F2C14E",
    "brightBlue":    "#6A87B8",
    "brightPurple":  "#B0609E",
    "brightCyan":    "#4FB8AC",
    "brightWhite":   "#F2E6D8",

    # extended accents (not ANSI slots, used in starship/banner/background/ls_colors)
    "copper":        "#B87333",
    "bronze":        "#8C6239",
    "gold":          "#D4AF37",
    "vermillion":    "#9B2C2C",  # sindoor red
    "henna":         "#6B3A1F",
    "duskIndigo":    "#1F2A44",
    "peacockDeep":   "#14555A",
}

def hx(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

if __name__ == "__main__":
    for k, v in palette.items():
        r, g, b = hx(v)
        print(f"{k:14s} {v}  rgb({r},{g},{b})")
