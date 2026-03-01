Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Plan written to `.ko/tickets/pun-fa8e.artifacts/plan.md`.

**Summary:** Two small changes to `ItemRow.swift`:

1. **Line 337** — Change `if hasTriage {` to `if hasTriage && !isInProgress {` so the grey fill circle is skipped when in-progress, letting the existing blue glow show through.

2. **Line 318** — Add `if hasTriage && isInProgress { return .punchGray }` to `circleColor` so the strokeBorder ring is grey (not blue) in the combined state — the grey outline that hints at triage while the blue fill/glow dominates.
