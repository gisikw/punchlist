Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Plan written. Summary:

**Fix**: Switch `collapsedProjectHoldOverlay` from `.gesture(...)` to `.simultaneousGesture(...)` and add a translation threshold check (~8pt) in `onChanged` to cancel the hold task when the user is clearly scrolling.

**Single task**: `ItemRow.swift:collapsedProjectHoldOverlay` — two changes:
1. `simultaneousGesture` instead of `gesture`
2. In `onChanged`, check `value.translation` and bail out if movement > 8pt

**Open question**: The 8pt threshold is a heuristic that may need tuning on real hardware. If it proves too fragile, Option B (restricting the gesture to the 44pt circle column) is the documented fallback.
