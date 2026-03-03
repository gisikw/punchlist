Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Plan written to `.ko/tickets/pun-ea5a.artifacts/plan.md`. Here's a summary:

**Goal:** Collapsed cards in project mode get a full-card hold gesture that fills green left-to-right and executes the same conditional action as the expanded hold bar (unblock, close, or toggle).

**Three changes to `ItemRow.swift`:**

1. **Green fill in background** — Replace `.background(.white)` with a `ZStack` that puts `Color.punchGreen.opacity(0.35)` (width = `holdProgress * cardWidth`) behind the card content, inside `.clipShape` so it respects rounded corners.

2. **`collapsedProjectHoldOverlay`** — New computed property mirroring `holdToCloseBar`'s gesture logic. Uses `DragGesture(minimumDistance: 0)` with the same 200ms grace + 1.3s fill + conditional action (`onOpen`/`onClose`/`onToggle`). On quick release (< 200ms), routes to the correct tap action using `value.startLocation.x` to replicate the existing three-zone tap behavior (triage left, bump right, expand center).

3. **Wire it in `body`** — Swap `tapOverlay` for `collapsedProjectHoldOverlay` when `!isExpanded && !isPersonal`. The existing `tapOverlay` continues to handle expanded cards and personal mode unchanged.
