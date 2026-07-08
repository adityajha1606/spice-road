"""
Spice Road — procedural background image generator.
Mandala/sun medallion (Rajasthani bazaar half) + layered dune horizon with
mirage haze (Dune half) + sparse night-sky accents. Rendered at 2x and
downsampled for clean anti-aliasing, no external assets required.

Usage: python3 generate_background.py
Output: spice-road-background.png (1920x1080)
"""
import math
import random
from PIL import Image, ImageDraw, ImageFilter
from palette import palette, hx

random.seed(42)  # reproducible

SCALE = 2
W, H = 1920 * SCALE, 1080 * SCALE

BG = hx(palette["bg"])


def with_alpha(hexname, a):
    r, g, b = hx(palette[hexname])
    return (r, g, b, a)


def draw_petal(d, cx, cy, ang_deg, r0, r1, half_width, color, alpha):
    """A tapered lens-shaped petal from radius r0 to r1, centered on angle ang_deg."""
    rad = math.radians(ang_deg)
    perp = math.radians(ang_deg + 90)
    bx0 = cx + r0 * math.cos(rad)
    by0 = cy + r0 * math.sin(rad)
    tx = cx + r1 * math.cos(rad)
    ty = cy + r1 * math.sin(rad)
    mx = cx + (r0 + r1) / 2 * math.cos(rad)
    my = cy + (r0 + r1) / 2 * math.sin(rad)
    left = (mx + half_width * math.cos(perp), my + half_width * math.sin(perp))
    right = (mx - half_width * math.cos(perp), my - half_width * math.sin(perp))
    d.polygon([(bx0, by0), left, (tx, ty), right], fill=with_alpha(color, alpha))


def draw_mandala(layer, center, max_radius):
    d = ImageDraw.Draw(layer)
    cx, cy = center

    # soft warm glow behind the whole medallion so it reads as a focal
    # point rather than blending into the dune tones
    glow = Image.new("RGBA", layer.size, (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    for i, r in enumerate(range(int(max_radius * 1.35), 0, -6 * SCALE)):
        a = int(10 + 40 * (1 - r / (max_radius * 1.35)))
        gd.ellipse([cx - r, cy - r, cx + r, cy + r], fill=with_alpha("gold", a))
    glow = glow.filter(ImageFilter.GaussianBlur(radius=18 * SCALE))
    layer.alpha_composite(glow)

    ring_specs = [
        (1.00, "bronze", 165, 3),
        (0.88, "copper", 135, 2),
        (0.74, "gold", 115, 2),
        (0.60, "bronze", 155, 3),
        (0.44, "copper", 135, 2),
        (0.28, "gold", 165, 2),
    ]
    for frac, color, alpha, width in ring_specs:
        r = max_radius * frac
        bbox = [cx - r, cy - r, cx + r, cy + r]
        d.ellipse(bbox, outline=with_alpha(color, alpha), width=width * SCALE)

    # dashed ring between the two outermost solid rings
    r_dash = max_radius * 0.94
    n_dashes = 48
    for i in range(n_dashes):
        a0 = (360 / n_dashes) * i
        a1 = a0 + (360 / n_dashes) * 0.5
        d.arc([cx - r_dash, cy - r_dash, cx + r_dash, cy + r_dash],
              a0, a1, fill=with_alpha("gold", 175), width=2 * SCALE)

    # beaded border just outside the outermost ring — small dots, bazaar-jewelry feel
    r_beads = max_radius * 1.04
    for i in range(72):
        ang = (360 / 72) * i
        rad = math.radians(ang)
        bx = cx + r_beads * math.cos(rad)
        by = cy + r_beads * math.sin(rad)
        s = 3 * SCALE
        d.ellipse([bx - s, by - s, bx + s, by + s], fill=with_alpha("copper", 125))

    # three layers of proper tapered petals, alternating accent colors,
    # each petal pointing outward from its ring
    petal_layers = [
        (max_radius * 0.62, max_radius * 0.98, 16, 16 * SCALE, "vermillion", 150),
        (max_radius * 0.34, max_radius * 0.60, 24, 11 * SCALE, "yellow", 140),
        (max_radius * 0.16, max_radius * 0.33, 32, 7 * SCALE, "copper", 130),
    ]
    for r0, r1, count, half_w, color, alpha in petal_layers:
        for i in range(count):
            ang = (360 / count) * i
            draw_petal(d, cx, cy, ang, r0, r1, half_w, color, alpha)

    # fine inner rings, tight and bright, like the center of a rangoli
    for r in [max_radius * 0.14, max_radius * 0.09, max_radius * 0.05]:
        bbox = [cx - r, cy - r, cx + r, cy + r]
        d.ellipse(bbox, outline=with_alpha("gold", 200), width=2 * SCALE)
    d.ellipse([cx - 5 * SCALE, cy - 5 * SCALE, cx + 5 * SCALE, cy + 5 * SCALE],
              fill=with_alpha("gold", 230))


def dune_layer_points(width, height, base_y, amplitude, freqs, phase, seed_jitter):
    rnd = random.Random(seed_jitter)
    pts = []
    n = 60
    for i in range(n + 1):
        x = width * i / n
        y = base_y
        for f, amp_mul in freqs:
            y += math.sin((x / width) * math.pi * 2 * f + phase) * amplitude * amp_mul
        y += rnd.uniform(-amplitude * 0.06, amplitude * 0.06)
        pts.append((x, y))
    return pts


def draw_dune_layers(layer, width, height):
    d = ImageDraw.Draw(layer)

    layers = [
        # (base_y_frac, amplitude, color, alpha, freqs, phase)
        (0.62, 46 * SCALE, "duskIndigo", 90, [(1.3, 1.0), (2.7, 0.4)], 0.4),
        (0.72, 40 * SCALE, "henna", 110, [(1.7, 1.0), (3.1, 0.3)], 1.7),
        (0.82, 34 * SCALE, "bronze", 130, [(2.1, 1.0), (4.0, 0.3)], 3.0),
        (0.92, 28 * SCALE, "copper", 150, [(2.6, 1.0), (5.0, 0.25)], 5.1),
    ]

    for i, (base_frac, amp, color, alpha, freqs, phase) in enumerate(layers):
        base_y = height * base_frac
        pts = dune_layer_points(width, height, base_y, amp, freqs, phase, seed_jitter=i)
        poly = pts + [(width, height), (0, height)]
        d.polygon(poly, fill=with_alpha(color, alpha))

    # mirage haze band sitting just above the furthest dune layer
    haze_y = height * 0.60
    haze = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    hd = ImageDraw.Draw(haze)
    band_h = int(90 * SCALE)
    for i in range(band_h):
        t = i / band_h
        a = int(50 * (1 - t))
        hd.line([(0, haze_y - band_h / 2 + i), (width, haze_y - band_h / 2 + i)],
                fill=with_alpha("marigold" if "marigold" in palette else "yellow", a))
    layer.alpha_composite(haze)


def draw_sky_accents(layer, width, height, count):
    d = ImageDraw.Draw(layer)
    rnd = random.Random(7)
    for _ in range(count):
        x = rnd.uniform(0, width)
        y = rnd.uniform(0, height * 0.55)
        size = rnd.uniform(1.5, 3.4) * SCALE
        color = rnd.choice(["gold", "copper", "fg_muted"])
        alpha = rnd.randint(70, 130)
        d.ellipse([x - size, y - size, x + size, y + size], fill=with_alpha(color, alpha))


def main():
    base = Image.new("RGBA", (W, H), (*BG, 255))

    sky_accents = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw_sky_accents(sky_accents, W, H, count=140)
    base.alpha_composite(sky_accents)

    dunes = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw_dune_layers(dunes, W, H)
    base.alpha_composite(dunes)

    mandala = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    center = (int(W * 0.82), int(H * 0.60))
    draw_mandala(mandala, center, max_radius=H * 0.42)
    base.alpha_composite(mandala)

    # slight overall blur on a duplicate, blended back in at low strength,
    # to soften the supersampled linework before final downsample
    softened = base.filter(ImageFilter.GaussianBlur(radius=1.2 * SCALE))
    base = Image.blend(base, softened, alpha=0.15)

    final = base.convert("RGB").resize((1920, 1080), Image.LANCZOS)
    final.save("spice-road-background.png", optimize=True)
    print("saved spice-road-background.png", final.size)


if __name__ == "__main__":
    main()
