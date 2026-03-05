---
id: pun-fb2f
status: closed
deps: []
created: 2026-03-04T18:07:36Z
type: task
priority: 2
---
# The long-press on collapsed card behavior that was recently introduced is great, but it intercepts scroll, which is a big problem. If this is solveable, let's solve it. If not, let's move the long press trigger to apply to the circles, alongside the tap-to-triage behavior that already lives there

## Notes

**2026-03-04 18:12:09 UTC:** # Summary: pun-fb2f — Fix collapsed card hold intercepting scroll

## What Was Done

Implemented Option A from the diagnosis: switched the `collapsedProjectHoldOverlay` gesture from exclusive `.gesture(...)` to `.simultaneousGesture(...)` and added a movement threshold check inside `onChanged`.

**Single change in `Punchlist/Views/ItemRow.swift`:**
- `.gesture(DragGesture(minimumDistance: 0)` → `.simultaneousGesture(DragGesture(minimumDistance: 0)`
- `onChanged { _ in` → `onChanged { value in`
- Added early-return guard: if either translation axis exceeds 8pt, cancel `holdDelayTask`, nil it out, reset `isHolding` and `holdProgress`, and return

## Notable Decisions

- **8pt threshold**: Chosen per plan/diagnosis recommendation. May need real-device tuning — the plan noted too-small risks false cancel on wobble, too-large risks slow scrollers still getting captured.
- **Option B not needed**: The `.simultaneousGesture` approach is minimal and preserves full-card UX. Option B (restrict gesture to 44pt circle column) remains documented as a fallback if hardware testing reveals fragility.

## Future Reader Notes

- If scroll-still-intercepted issues appear on device, increase threshold slightly (8→10pt) before considering Option B.
- The `holdDelayTask` nil-assignment on cancel is important — prevents a race where the task fires after the gesture was already cancelled.

**2026-03-04 18:12:09 UTC:** ko: SUCCEED
