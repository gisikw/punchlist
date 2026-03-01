## Goal
Lighten the triage fill circle and ensure the blue in-progress stroke/glow renders on top of it when a ticket is both triaged and in-progress.

## Context
The `circle` computed property in `ItemRow.swift` (line 322) renders a ZStack:
1. Background glow circle (sized to fill the 30×30 frame) — drawn when `hasActiveStatus` or `hasUnresolvedDep`
2. `strokeBorder` circle (22×22) using `circleColor` — for in-progress this is `.punchBlue`
3. Filled overlay circle — green for done/resolved, or full `Color.punchGray` (22×22) for triage

The problem: the triage filled circle is drawn **after** the strokeBorder in the ZStack, so it renders on top and covers the blue stroke entirely. The card-level shadow glow (lines 133–134) still shows for in-progress tickets, but the circle's own stroke indicator is hidden.

`punchGray` is defined as `Color(red: 0.576, green: 0.573, blue: 0.576)` — `#939293`, a medium grey. The ticket asks for a lighter shade.

## Approach
Move the `strokeBorder` circle to render after the filled circles so it always sits on top. Then reduce the triage fill opacity (or lighten the color value) so the circle reads as a light grey indicator rather than solid mid-grey.

## Tasks
1. [`Punchlist/Views/ItemRow.swift:332`] — Reorder the ZStack inside `circle`: move the `strokeBorder` Circle below the `if item.done || isResolved / else if hasTriage` block so the stroke is drawn last (on top). The glow background circle stays first.
   Verify: in-progress ticket with triage now shows blue ring over the grey fill.

2. [`Punchlist/Views/ItemRow.swift:344–347`] — Change the triage fill from `.fill(Color.punchGray)` to `.fill(Color.punchGray.opacity(0.45))` to produce a lighter grey disc.
   Verify: triage circle visually reads as light grey; non-triage, non-active circles (plain grey stroke) still look distinct.

## Open Questions
None — the opacity value of 0.45 is a reasonable starting point for "lighter grey" against the white card background. If the exact shade needs tuning, the implementer can adjust the opacity constant.
