Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
All three tasks complete. Summary of changes to `Punchlist/Views/ItemRow.swift`:

**Task 1 (line 134):** Replaced `.background(.white)` with a `ZStack` background that renders `Color.punchGreen.opacity(0.35)` at `holdProgress * cardWidth` behind the card content, inside `.clipShape` so it respects the rounded corners. Only renders the green fill when `!isExpanded && !isPersonal && holdProgress > 0`.

**Task 2 (new property after `holdToCloseBar`):** Added `collapsedProjectHoldOverlay` — a `GeometryReader`-wrapped `Color.clear` with a `DragGesture`. Mirrors `holdToCloseBar`'s 200ms grace + 1.3s fill logic and the same conditional action (`onOpen`/`onClose`/`onToggle`). On quick tap (< 200ms), routes by `startLocation.x` to replicate the three-zone tap behavior: left 44pt → triage toggle or expand, right 20% → bump, center → expand. Done items call `onToggle()` on quick tap regardless of zone.

**Task 3 (line 80):** Changed the inner VStack's `.overlay` from always using `tapOverlay` to conditionally using `collapsedProjectHoldOverlay` when `!isExpanded && !isPersonal`, and `tapOverlay` otherwise.

No deviations from the plan.
