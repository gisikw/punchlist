---
id: pun-93ed
status: closed
deps: []
created: 2026-02-26T17:29:12Z
type: task
priority: 2
---
# If there's a large ticket expanded, on collapse the tickets can seemingly disappear because the container doesn't shrink. Scrolling eventually recovers them. But can we nudge the container to resize on item card close maybe?

## Notes

**2026-02-26 20:21:23 UTC:** Question: When a ticket collapses, should we scroll to the collapsed item or to the bottom of the list?
Answer: Scroll to collapsed item (Recommended)
Keeps the collapsed item visible and centered, allowing the container to resize properly

**2026-02-26 20:26:32 UTC:** # Summary: Fix ScrollView Container Not Shrinking on Ticket Collapse

## What Was Done

Fixed a UI bug where collapsing a large expanded ticket would cause other tickets to appear to disappear until manual scrolling occurred. The root cause was that the `ScrollView` container wasn't recalculating its content size when an expanded `ItemRow` collapsed back to its normal height.

## Implementation

Modified `Punchlist/Views/ContentView.swift` (lines 210-215) to add explicit scroll repositioning after a ticket collapse:

1. **Added delayed `scrollTo` call**: After the collapse animation begins, a `Task` waits 350ms (matching the spring animation duration of 0.35s) then calls `proxy.scrollTo(item.id, anchor: .bottom)`

2. **Used `.bottom` anchor**: This keeps the collapsed item visible at the bottom of the viewport while forcing the ScrollView to recalculate its content height

3. **Leveraged existing `ScrollViewReader` proxy**: The implementation uses the already-available `proxy` from the ScrollViewReader that wraps the item list

## Key Decisions

- **Scroll target**: Chose to scroll to the collapsed item (rather than the bottom of the list) to keep the item visible and provide a stable user experience
- **Timing**: Matched the delay (350ms) to the existing spring animation duration (0.35s) to ensure the scroll adjustment happens after the height animation completes
- **Anchor point**: Used `.bottom` anchor to align with the ScrollView's existing `.defaultScrollAnchor(.bottom)` behavior

## No Changes Required

- `ItemRow.swift`: The `onCollapse` closure signature was already `() -> Void` as needed, so no modifications were necessary

## Testing

All existing tests passed on the macOS build host (26 test cases, all green). The implementation follows SwiftUI best practices for iOS 17+ using Swift concurrency with `Task { @MainActor in }`.

## Invariants Compliance

- ✅ SwiftUI-only implementation (no UIKit)
- ✅ Uses iOS 17+ patterns (Task, async/await)
- ✅ Maintains bottom-anchored scroll behavior
- ✅ No third-party dependencies
- ✅ Follows existing animation patterns in the codebase

**2026-02-26 20:26:32 UTC:** ko: SUCCEED
