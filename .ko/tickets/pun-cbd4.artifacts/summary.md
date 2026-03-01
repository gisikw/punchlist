# Summary

## What Was Done

Two small changes to `Punchlist/Views/ItemRow.swift` in the `circle` computed property:

1. **Reordered ZStack layers** — The `strokeBorder` Circle (22×22, colored with `circleColor`) was moved from its previous position (before the done/triage fill conditionals) to after them. It now renders last, sitting on top of any filled disc. This ensures the blue in-progress stroke is visible even when a ticket also has a triage value.

2. **Lightened triage fill** — The triage disc fill changed from `Color.punchGray` (solid, ~`#939293`) to `Color.punchGray.opacity(0.45)`, producing a noticeably lighter grey against the white card background.

## Notable Decisions

- Opacity 0.45 was the value specified in the plan as a reasonable starting point. No tuning was needed.
- The glow background circle (first in the ZStack) and the green done/resolved fill were left untouched.

## For Future Readers

The ZStack order in `circle` is now: (1) glow background, (2) done/resolved or triage fill, (3) strokeBorder. This layering guarantees the stroke color is always the topmost visual element on the circle.
