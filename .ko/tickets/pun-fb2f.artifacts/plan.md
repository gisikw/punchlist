## Goal
Fix the collapsed card hold gesture so it no longer intercepts scroll, by switching to simultaneous gesture recognition with scroll-cancellation on movement.

## Context
`collapsedProjectHoldOverlay` (ItemRow.swift:333–399) covers the entire collapsed card with a `Color.clear` view bearing a `DragGesture(minimumDistance: 0)` attached via `.gesture(...)` (exclusive). Because `DragGesture(minimumDistance: 0)` claims the touch immediately, the ScrollView never gets a chance to detect scroll intent. The `holdToCloseBar` on expanded cards avoids this problem because it's a small, deliberately-targeted strip — not a full-card overlay.

The diagnosis (diagnosis.md) evaluated two fixes:
- **Option A**: Switch to `.simultaneousGesture` + cancel hold on vertical/horizontal movement > threshold (~8–10pt). Minimal change, preserves full-card UX.
- **Option B**: Move gesture to the circle column only (~44pt wide). More invasive — requires restructuring tap dispatch logic.

Option A is the right first attempt per the diagnosis.

## Approach
In `collapsedProjectHoldOverlay`, change `.gesture(DragGesture(minimumDistance: 0)...)` to `.simultaneousGesture(DragGesture(minimumDistance: 0)...)`. Inside `onChanged`, receive the `value` (currently ignored) and check `value.translation` — if either axis exceeds ~8pt, cancel `holdDelayTask`, reset `isHolding` and `holdProgress`. The scroll view will now run simultaneously and win naturally when the user is scrolling; the hold cancels itself if movement is detected.

## Tasks
1. **[Punchlist/Views/ItemRow.swift:collapsedProjectHoldOverlay]** — Change `.gesture(DragGesture(minimumDistance: 0)` to `.simultaneousGesture(DragGesture(minimumDistance: 0)`. Update `onChanged` to accept `value` and add translation threshold check: if `abs(value.translation.width) > 8 || abs(value.translation.height) > 8`, cancel `holdDelayTask`, set `isHolding = false`, reset `holdProgress = 0`, and return early.
   Verify: Build succeeds. Manual test: scrolling past a collapsed project card no longer sticks/freezes. Holding still on a collapsed card still triggers the green fill and action.

## Open Questions
- **Threshold value**: 8pt is a heuristic from the diagnosis. Too small risks false cancels on finger wobble; too large risks slow scrollers still getting captured. 8–10pt is the suggested range — 8pt is the starting point, may need real-device tuning.
- **Option B as fallback**: If Option A proves too fragile after hardware testing, the fallback is to restrict the gesture to the 44pt circle column and restructure tap dispatch. This is a larger change and would need a separate pass.
