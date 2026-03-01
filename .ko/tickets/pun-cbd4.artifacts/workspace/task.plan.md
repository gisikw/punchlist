Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Plan written to `.ko/tickets/pun-cbd4.artifacts/plan.md`. Here's the summary:

**Two issues identified in `ItemRow.swift:circle` (line 322):**

1. **Z-order bug**: The triage fill circle is rendered *after* the `strokeBorder` in the ZStack, so it covers the blue stroke entirely on in-progress+triaged tickets. Fix: move the `strokeBorder` to render last (on top of fills).

2. **Grey too dark**: Triage fill uses solid `Color.punchGray` (`#939293`). Fix: use `Color.punchGray.opacity(0.45)` for a lighter disc.

The card-level shadow glow already works correctly for in-progress tickets (it's driven by `hasActiveStatus` independently of triage), so only the circle's internal rendering needs adjustment.
