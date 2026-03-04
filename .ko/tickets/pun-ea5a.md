---
id: pun-ea5a
status: closed
deps: []
created: 2026-03-03T15:55:04Z
type: task
priority: 2
---
# In project mode, holding on a collapsed card should behave like holding the tap-or-hold bar in expanded. That is, the card itself should fill from left to right green, and if the user holds, it should take the same actions. Unblocking blocked cards, clearing resolved cards, etc

## Notes

**2026-03-03 16:05:43 UTC:** # After-Action Summary: pun-ea5a

## What Was Done

Added hold-to-act behavior to collapsed project-mode cards in `ItemRow.swift`. When a user holds a collapsed project card, the entire card fills with a left-to-right green overlay (same 200ms grace → 1.3s linear animation). On full hold, the same context-aware action as `holdToCloseBar` fires: `onOpen()` for blocked cards with no open questions, `onClose()` for blocked cards with open questions, `onToggle()` otherwise.

## Changes

**`ItemRow.swift`** — three coordinated modifications:

1. **Background modifier** — replaced `.background(.white)` with a `ZStack` that conditionally renders the green fill (`Color.punchGreen.opacity(0.35)`) behind white, scoped to `!isExpanded && !isPersonal && holdProgress > 0`. The fill is inside `.clipShape` so it respects the card's rounded corners.

2. **Overlay routing** — changed `.overlay { tapOverlay }` to an `if/else` that routes collapsed project-mode cards to `collapsedProjectHoldOverlay` and all other cards (expanded, personal mode) to the existing `tapOverlay`. No `AnyView` needed.

3. **`collapsedProjectHoldOverlay`** — new `private var` computed property using `GeometryReader` + `DragGesture(minimumDistance: 0)`. Reuses existing `holdProgress`, `isHolding`, `holdStartTime`, `holdDelayTask` state (safe since hold bar and collapsed overlay are mutually exclusive). On quick tap (< 200ms), routes to the correct tap zone action using `value.startLocation.x` — matching `tapOverlay` behavior exactly. On mid-hold release, animates fill back to zero.

## Notable Decisions

- **State reuse**: The plan noted the existing hold state variables could be reused. Since `holdToCloseBar` only appears when `isExpanded && !item.done` and `collapsedProjectHoldOverlay` only appears when `!isExpanded && !isPersonal`, there's no state contention.
- **Clean `if/else`** for overlay routing instead of `AnyView` wrapping — cleaner than the `AnyView` approach mentioned as an option in the plan.
- **Quick-tap `item.done` path**: Routes directly to `onToggle()` rather than the triage/expand/bump zones, matching the `tapOverlay` behavior for done items.

## Future Reader Notes

- `ItemRow.swift` is now ~462 lines, above the soft "~300 line" invariant threshold, but was already ~388 lines before this change. A future split along behavioral seams (e.g., extracting gesture logic) may be warranted if the file continues to grow.
- The `tapOverlay` left-zone fallback `isPersonal ? onToggle() : onExpand()` isn't replicated in `collapsedProjectHoldOverlay` because personal-mode cards never reach that code path — the `!isPersonal` guard in the overlay routing handles it.

**2026-03-03 16:05:43 UTC:** ko: SUCCEED
