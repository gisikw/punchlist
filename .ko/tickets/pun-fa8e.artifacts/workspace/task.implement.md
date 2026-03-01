Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Type-check passed. Here's what was changed:

**Task 1** — `ItemRow.swift:338`: Changed `if hasTriage {` to `if hasTriage && !isInProgress {`. When a ticket is both in triage and in-progress, the grey fill circle is skipped, letting the blue glow from the background layer show through.

**Task 2** — `ItemRow.swift:319` (after insertion): Added `if hasTriage && isInProgress { return .punchGray }` before the `isInProgress` case in `circleColor`. This makes the strokeBorder ring grey instead of blue in the combined state, providing the grey circle outline that hints at triage while the blue fill/glow dominates.

No deviations from the plan.
