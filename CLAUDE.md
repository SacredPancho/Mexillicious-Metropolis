# Mexillicious Metropolis

A city where every coding project is a township on a shared hex plane and every live
agent session is a figure walking inside it. Built so one glance replaces scrolling a
session list.

Local working copy: `~/Documents/_MEXILLICIOUS/AI/Mexillicious Metropolis`
Repo: `SacredPancho/Mexillicious-Metropolis`

## Layout

- `prototypes/hero.html` — public, read-only website hero. Daylight scale-model look.
- `prototypes/metropolis.html` — private wall/control view. Night look, live-data shaped.
- `docs/data-model.html` — session feed → township/cadet field mapping.
- `README.md` — every design decision and why, plus the open problems.

## Three targets, one engine

| | Wall display | Control view | Website hero |
| --- | --- | --- | --- |
| Data | live session feed | live session feed | hand-written array |
| Interaction | none | drag, hover, reply | click a district |
| Distance | 3 m | 40 cm | 40 cm, phone-first |
| Infra | Mac mini, always on | laptop / phone | none |

## Hard rules

- **Never put session data in `hero.html`.** Session titles, statuses and spend reveal
  unreleased work and competitive research. The public city is hand-written only.
- **No build step, no dependencies, no CDN.** Both renderers are single files that open
  directly in a browser. Fonts come from Google Fonts; everything else ships inline.
  Do not introduce three.js or a bundler without saying why.
- **`prism()` is the only solid primitive.** It extrudes any convex footprint, so
  rotated and n-sided shapes come free. Add shapes by writing footprints, not new
  drawing code.
- **One landmark per district.** At hero scale a district is ~90px. A second large
  object competes with the silhouette and both stop reading.

## Conventions

- Flat-top hex lattice, axial `(q, r)`, `cube_round` for snapping. Ground is one global
  plane; townships are prop groups placed on it, never tiles carrying their own ground.
- Borders are physical — a plinth raised a different amount per district, so seams are a
  lit step. Glowing rings are hover/alert state only.
- Themes vary on five knobs and nothing else: accent hue, prop kit, layout rule, ground
  tint, figure behaviour. Camera, sun, scale rule and material library are fixed.
- Painter's algorithm: objects sorted by `x + z`, shadows gathered in a geometry-only
  pass (`SILENT`) then filled once so they never double-darken.

## Before changing the renderers

Read `README.md` first — it records decisions that look arbitrary in the code and the
counter-examples that produced them, including why one-township attribution was reversed.
