# Diagnosis: Collapsed Card Hold Gesture Intercepts Scroll

## Symptoms

Long-pressing a collapsed project card works correctly (fills green left-to-right, triggers actions), but the gesture intercepts scroll events in the list, making the app difficult or impossible to scroll when touching a card.

## Root Cause

`collapsedProjectHoldOverlay` (ItemRow.swift:333–399) places a `Color.clear` view covering the **entire card surface** with a `DragGesture(minimumDistance: 0)` attached via `.gesture(...)`.

`DragGesture(minimumDistance: 0)` begins recognizing immediately on touch-down — before any movement is detected — and `.gesture(...)` (non-simultaneous) gives the drag recognizer exclusive ownership. This defeats SwiftUI's ScrollView gesture recognizer, which needs to observe initial movement to claim a scroll gesture. The result: any touch that begins on a collapsed card is owned by the hold overlay, and the scroll view never gets the opportunity to scroll.

This is fundamentally different from the `holdToCloseBar` at the bottom of expanded cards: that element is a small, intentional interaction target. Users don't scroll through it, and even if they did, they've already expanded the card — scroll interception is less harmful there. The collapsed overlay covers the full card and is hit on virtually every scroll gesture.

## Affected Code

- **`ItemRow.swift:333–399`** — `collapsedProjectHoldOverlay` property
  - `DragGesture(minimumDistance: 0)` on a full-card `Color.clear` overlay
  - Attached with `.gesture(...)` (exclusive, not simultaneous)
- **`ItemRow.swift:80–86`** — body overlay switching logic that applies `collapsedProjectHoldOverlay` when `!isExpanded && !isPersonal`

## Recommended Fix

Two viable paths:

### Option A: `simultaneousGesture` + scroll-cancel heuristic (minimal change, preserves full-card UX)

Change `.gesture(DragGesture(minimumDistance: 0)...)` to `.simultaneousGesture(DragGesture(minimumDistance: 0)...)` in `collapsedProjectHoldOverlay`. Then, inside `onChanged`, check `value.translation` — if the vertical movement exceeds a small threshold (e.g., 8–10pt), cancel `holdDelayTask` and reset state. This allows the scroll view to run simultaneously, and the hold is abandoned if the user is clearly scrolling rather than holding in place.

```
// pseudocode for onChanged
if abs(value.translation.height) > 8 || abs(value.translation.width) > 8 {
    holdDelayTask?.cancel()
    isHolding = false
    holdProgress = 0
    return
}
```

This is the least invasive change and preserves the full-card visual fill (green spreading from left to right).

### Option B: Move gesture to the circle area (ticket's fallback suggestion)

Attach the hold gesture exclusively to the 44pt-wide circle column instead of the full card. The circle is already a tap target for triage/expand. Adding a `DragGesture(minimumDistance: 0)` only to that 44pt area means the scroll view can claim touches anywhere else on the card uncontested.

The card background fill animation (`holdProgress`) still works regardless of where the gesture lives, since it's a state variable on the whole view. However, `onEnded`'s tap-detection logic (reading `value.startLocation.x` to decide triage vs. expand vs. bump) would need refactoring since the gesture would no longer span the full width.

## Risk Assessment

### Option A risks
- The 8–10pt threshold is a heuristic; too small and holds still intercept slow scrollers, too large and users can accidentally cancel holds with minor finger wobble. Testing on real hardware needed.
- `simultaneousGesture` means the scroll view and hold gesture run in parallel. On a fast fling, `onChanged` fires multiple times before the hold task starts (within the 200ms grace period), so the cancellation path should reliably fire. But edge cases (very slow scroll starting within 200ms, then pausing) could still capture the gesture.
- The `onEnded` handler already handles the "released before threshold" case gracefully.

### Option B risks
- The UX changes: users must target the circle to trigger the hold, rather than pressing anywhere on the card. The ticket notes this as an acceptable fallback.
- The tap-dispatch logic currently in `onEnded` (triage vs. expand vs. bump based on x position) would need to move or be restructured. The 80/20 bump zone on the right would need its own gesture, likely restoring `tapOverlay` logic for the non-circle area.
- More code churn; higher chance of regression in tap routing.

**Recommendation: Option A first.** It's a two-line change with a localized risk surface. If the scroll-cancel threshold proves difficult to tune, fall back to Option B.

## Summary

The bug is a classic gesture recognizer conflict: `DragGesture(minimumDistance: 0)` with exclusive ownership covers the full card and wins every touch contest against the scroll view. The simplest fix is switching to `simultaneousGesture` and canceling the hold when the user's translation indicates a scroll. If that threshold is too fragile, moving the gesture to the circle element is a clean architectural fallback that the ticket already anticipates.
