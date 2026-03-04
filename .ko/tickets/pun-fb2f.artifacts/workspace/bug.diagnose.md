Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
**Summary:** The bug is a classic gesture recognizer conflict. `collapsedProjectHoldOverlay` (ItemRow.swift:333–399) puts a `DragGesture(minimumDistance: 0)` on a full-card overlay using `.gesture(...)` (exclusive ownership). Since `minimumDistance: 0` fires immediately on touch-down, the overlay wins every touch before the scroll view can claim it — scroll is completely blocked.

Two fixes are viable:

1. **Option A (recommended, minimal):** Switch to `.simultaneousGesture(...)` and add a translation-distance check inside `onChanged` — if the finger moves more than ~8pt in any direction, cancel the hold task. Scroll and hold coexist, with the hold aborting when the user is clearly scrolling.

2. **Option B (ticket fallback):** Move the gesture to the circle area only (44pt column). Scroll is uncontested everywhere else on the card. Requires refactoring the tap-dispatch logic currently handled via `value.startLocation.x`.

Option A is a ~4-line change with low regression risk. Option B is cleaner architecturally if Option A's threshold proves hard to tune.
