# Design Manifesto

I got tired of terminals that look like they're apologizing for existing. Gray-on-black minimalism is fine if that's what you want, but I wanted a cockpit — something where every readout has a place and a color, and nothing shares an accent by accident.

The visual language blends two things I keep coming back to: the scale of Dune deserts (dunes, sunbursts, mirage haze) and the density of Rajasthani folk design (marigold, brass, tilework, bazaar stalls). It lands somewhere around 60% Dune desert sci-fi, 40% Indian folk subculture. The result is warm, ornate, and built for a terminal that doesn't need to stay quiet.

Every color in the theme lives in one file: `palette.py`. Twenty-eight named colors, one source of truth. Change a hex there, regenerate, and the whole cockpit follows — the Windows Terminal scheme, the prompt pills, the background mandala, the hand-built LS_COLORS. Marigold (#E8A33D) pulls double duty as cursor and yellow, borrowing from the saffron-and-turmeric sacks in an open market. Vermillion (#9B2C2C) is the weight of sindoor, kept separate from the dustier rust (#B5502D) used for terminal red. Indigo (#3E5578) and duskIndigo (#1F2A44) bring in the cold of a desert night against all that warmth. Desert moss (#7C8B3D) is the one green — pale and scrubby, not jungle-lush. Parchment sets the base layer: foreground at #F2E6D8, the sand-colored page everything else sits on. Brass shows up structurally — copper (#B87333) and bronze (#8C6239) frame the whole interface, most visibly in the bronze lines drawn around every prompt row.

That three-row prompt is the dashboard. Row one is context: color-coded pills for where you are and what's touching your shell. Row two shows vitals — background jobs, memory, load, a small ◆ that signals whether you're online. Row three is the judgment line: a single ◈ character that shifts color the moment a command succeeds, fails, or waits in vim mode. No buried info, no overloaded single line.

Typography follows the same logic. The default is Iosevka Term Slab Nerd Font — an ornate serif designed to work in monospace and actually readable in code. If you prefer cursive italics in comments and diffs, Victor Mono Nerd Font is a good alternate. Swap the `font.face` in Windows Terminal's profile and the whole cockpit adapts.

The welcome banner is hand-built, not a figlet output. A generic font renderer can't produce a sunburst medallion or dune waves that actually feel like sand. It's generated once from its own script and then left alone. Weather information refreshes asynchronously in a background subprocess, ensuring a slow network never delays shell startup. The fetch logic lives in `weather-check.sh`, so the banner simply reads the cached result. Battery works similarly: a cached read refreshed in the background, so the prompt stays fast and PowerShell never makes it stutter.

Two fastfetch configs come with the theme. One is the full daily-driver view (disk, local IP, battery). The other omits those details, safe for screenshots and streams. Both inherit the Spice Road palette automatically from the Windows Terminal color scheme.

None of this is decoration for its own sake. It's a terminal built to be used every day, with a lot of thought put into making it feel worth sitting in front of.
