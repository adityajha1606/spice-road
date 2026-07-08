# Design Manifesto

Every terminal is a cockpit. Most people just don't treat it that way.

The Spice Road started from a refusal: no more gray‑on‑black minimalism, no more terminals that look like they're apologizing for existing. This one is a full cockpit — a precision instrument where every readout has a home, and every home has its own color. Nothing here shares an accent by accident.

The concept runs roughly 60% Dune desert‑mirage sci‑fantasy, 40% Rajasthani Indian folk maximalism. The Dune half brings scale: dune waves, a sunburst medallion, the shimmer of a mirage that never quite resolves. The Rajasthani half brings density: spice caravans, marigold garlands over a market stall, hammered brass catching lamplight, tilework rhythm repeated until it becomes pattern. Together it reads like a bazaar at the edge of an oasis — ornate, warm, unbothered by the idea that a terminal should stay quiet.

Every color traces back to one file, `palette.py`, the single source of truth for all 28 named colors. Change one value there and regenerate, and the whole cockpit follows — from the Windows Terminal scheme to the prompt pills, from the background mandala to the hand‑crafted LS_COLORS. Marigold (#E8A33D) does double duty as cursor and yellow, standing in for saffron and turmeric heaped in open sacks. Vermillion (#9B2C2C) carries the weight of sindoor, distinct from the dustier rust (#B5502D) used for terminal red. Indigo (#3E5578) and its deeper cousin duskIndigo (#1F2A44) hold the cool of desert night against all that warmth. Desert moss (#7C8B3D) is the one green that doesn't try to be a jungle — pale, hardy scrub‑olive rather than anything lush. Parchment feeds the base layer: fg at #F2E6D8, the sand‑colored page every pill and pane sits on. Brass appears structurally, not just decoratively — copper (#B87333) and bronze (#8C6239) frame the whole experience, most visibly in the bronze frame drawn around every prompt row.

That three‑row prompt is the cockpit's dashboard. Row one is context: color‑coded pills for where you are and what touches your shell. Row two is vitals — jobs, memory, load, a small ◆ marking whether you're online. Row three is judgment: a single ◈ character that changes color the instant something succeeds, fails, or waits on vim mode. Nothing important gets buried in one overloaded line.

Typography follows the same logic. The default typeface is Iosevka Term Slab Nerd Font, an ornate decorative serif translated into monospace and code‑readable. For those who prefer cursive italics in comments and diffs, Victor Mono Nerd Font is an equally ornate alternative — swap the `font.face` in Windows Terminal's profile and the cockpit adapts instantly.

The welcome banner is hand‑built, not figlet‑generated, because a generic font renderer can't produce a medallion or dune waves that actually feel like sand. It comes from its own generation script and is then left alone. The weather line fetches non‑blocking, disowned with the `&!` operator so a slow network can never hang your shell — cached for 25 minutes. Battery works the same way: a battery cache read on every prompt, refreshed separately, so job control stays clean and PowerShell never makes your prompt stutter.

Two fastfetch configs ship with the theme — a full daily‑driver view with disk, IP, and battery, and a screenshot‑safe version that omits those details. Both inherit the Spice Road palette automatically from the Windows Terminal color scheme.

None of it is decoration for its own sake. It's a desert crossing dressed as a terminal, built to be lived in.
