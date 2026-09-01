# Agent Metropolis

A 3D world where each Claude Code project is a township on a shared plane, and each
live session is a "cadet" walking around inside it. When a session needs a reply, its
district signals — readable at city zoom, where a cadet is two pixels tall.

Status: **design + geometry prototype.** No backend yet.

## Open it

- `prototypes/metropolis.html` — isometric renderer, hex lattice, drag-to-rearrange.
  Standalone: no build, no dependencies, no CDN. Open it in a browser.
- `docs/data-model.html` — field-by-field mapping from the session feed to what you see.

Both are also published as artifacts:
- Renderer — https://claude.ai/code/artifact/20d0cb6a-2fbf-4db2-933c-c09faccaa3e1
- Data model — https://claude.ai/code/artifact/f0cd64c7-7229-4c3f-b235-54ba92c1595b

## Decisions already made

**Hexagons, not pentagons.** Regular pentagons cannot tile a plane. Hexes give six
edge-neighbours all equidistant, no corner-only adjacency, and the least boundary per
unit of district area of any regular tiling. Cairo pentagons and Voronoi cells were both
considered and rejected — Voronoi specifically because dragging one district deforms
its neighbours.

**Terrain is global.** One continuous ground plane. Townships are groups of props placed
on top of it, never tiles carrying their own ground. This is what makes dragging free and
leaves roads, groves and blended seams as purely additive work later.

**Borders are physical, not drawn.** Each township sits on a plinth raised a different
amount, so adjacent districts meet at a lit step rather than an outline. The glowing hex
ring is hover/alert state only.

**Themes vary on five knobs, nothing else.** Accent hue, prop kit, layout rule, ground
tint, cadet behaviour. Camera, sun, scale rule, material library and silhouette grammar
are fixed across every township. A new project is a config object, not a modelling session.

**Data comes from the account session feed, not local hooks.** Local hooks only see one
machine and die when it sleeps. The account feed spans iOS, CLI and cloud.

## Known problems

1. **Attribution is missing.** 13 of 14 sessions in the live sample carried no repo field.
   Their titles clearly name projects, but nothing in the feed connects them. Everything
   unmapped lands in a "Commons" district — which is most of the city.
2. **The two feeds use different session IDs.** The account feed returns `session_01H8kr…`;
   local `claude agents --json` returns a plain UUID. No known join. Until this is settled
   they cannot be merged, so local `cwd` (the one reliable repo signal) is unreachable.
3. **`usage.cost_usd` is cloud-only.** CLI sessions report no usage block, so spend cannot
   drive skyline mass. Session count is the fallback.
4. **REVIEW_READY needs a compound rule.** It fires on sessions whose machine is asleep.
   Alert only when `status_bucket = REVIEW_READY` AND `connection_status = connected`.
5. **No reply path.** The feed is read-only. "Reply" has to open a session, not answer in
   place. There is no supported way to type into a session already running in a terminal.

## Next

- Verify whether a standalone app can call the session-list endpoint at all. If not, the
  backend has to be a headless Claude Code / Agent SDK process with the MCP server attached.
- Resolve the session-ID join, or decide the Commons is acceptable for v1.
- Decide: does a session touching two repos put a marker in the secondary township, or
  only the primary? Currently primary only, which leaves this repo's own district empty.
