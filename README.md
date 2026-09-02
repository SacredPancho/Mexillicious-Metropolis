# Agent Metropolis

A 3D world where each Claude Code project is a township on a shared plane, and each
live session is a "cadet" walking around inside it. When a session needs a reply, its
district signals — readable at city zoom, where a cadet is two pixels tall.

Status: **design + geometry prototype.** No backend yet.

## Open it

- `prototypes/metropolis.html` — isometric renderer, hex lattice, drag-to-rearrange.
  Standalone: no build, no dependencies, no CDN. Open it in a browser.
- `prototypes/hero.html` — the public, read-only website hero. Daylight scale-model look,
  click a district for details, fed by a hand-written `PROJECTS` array. No session data,
  no backend, no network calls. Drop `.hero` + the script into a page and delete the notes
  block. Follows the visitor's colour scheme; force it with `data-theme` on the root.
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
5. **The reply path is asymmetric.** Cloud sessions can be answered from anywhere with
   `claude -p "message" --cloud <session-id>` (add `--output-format json` for
   `{ok, session_id, url}`). Local terminal sessions cannot: there is no supported way to
   type into one that is already running. For those, `--resume` works only after the
   session stops, and `claude attach <id>` works for background ones.

## Resolved: how the backend reads and writes

Checked against the docs on 1 Sep 2026.

**There is no public HTTP API for the Claude Code session list.** `GET /v1/sessions` on
api.anthropic.com is a different product — Managed Agents, IDs `sesn_...`, authenticated
with `X-Api-Key`, carrying `agent_id`, `deployment_id`, `vault_ids` and
`outcome_evaluations`. It does not return claude.ai/code sessions. The docs say to find a
session ID "in your session list at claude.ai/code", which is a UI, not an endpoint.

So both halves go through the `claude` CLI, not HTTP:

| Need | Mechanism |
| --- | --- |
| Read the roster | headless Claude Code / Agent SDK process with the claude-code-remote MCP server attached |
| Reply to a cloud session | `claude -p "message" --cloud <session-id>` |
| Open a session locally | `claude --teleport <session-id>` |
| Local background sessions | `claude agents --json`, `claude attach <id>` |

The backend is therefore a Node process that shells out to `claude`. No API key, no
reverse-engineering, nothing unsupported. Cloud session IDs are `session_...` or `cse_...`.

## Three targets, one engine

| | Wall display | Control view | Website hero |
| --- | --- | --- | --- |
| Data | live session feed | live session feed | curated static JSON |
| Interaction | none | drag, hover, reply | click a district only |
| Read distance | 3 m | 40 cm | 40 cm, phone-first |
| Infra | Mac mini, always on | laptop / phone | none |

The public hero must never share a data source with the other two. Session titles and spend
reveal unreleased work and competitive research.

## Next

- Resolve the session-ID join, or decide the Commons is acceptable for v1. This is now the
  only thing blocking a backend. Test on a machine with real local sessions:
  compare `claude agents --json` UUIDs against the `session_...` IDs in the account feed.
- Decide: does a session touching two repos put a marker in the secondary township, or
  only the primary? Currently primary only, which leaves this repo's own district empty.
- Add the compound alert rule to the renderer: alert only when
  `status_bucket = REVIEW_READY` AND `connection_status = connected`.
