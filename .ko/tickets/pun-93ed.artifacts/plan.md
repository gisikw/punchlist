## Goal
Fix ScrollView container not shrinking when a large expanded ticket collapses, causing items to appear to disappear until scrolling.

## Context
The issue is in `ContentView.swift:176-220` where the `itemList` view is defined. When a large ticket is expanded via `expandedItemID`, the `ItemRow` grows in height to show the expanded content (ticket ID, description, and potentially plan questions). The `ScrollView` with `LazyVStack` correctly expands to accommodate this.

However, when the item collapses (via the hold-to-close bar's `onCollapse` callback at line 204-209), the `ItemRow` shrinks back down, but the `ScrollView`'s content size doesn't immediately update. This leaves the scroll position in a state where it appears items have disappeared — they're actually just above the viewport, and scrolling recovers them.

The collapse animation is triggered with `withAnimation(.spring(response: 0.35, dampingFraction: 0.8))` which animates the `expandedItemID` state change. The `ItemRow` has a matching animation modifier at line 88, but there's no explicit trigger to recalculate the scroll position after the content shrinks.

SwiftUI's `ScrollView` with bottom anchoring (`.defaultScrollAnchor(.bottom)` at line 218) should maintain the bottom-anchored position, but when content shrinks rapidly during collapse, the scroll offset can become stale.

## Approach
Use `ScrollViewReader`'s `scrollTo` method to explicitly scroll to the collapsed item after collapse completes. When an item collapses, we'll call `scrollTo(item.id, anchor: .bottom)` to keep the collapsed item visible while forcing the viewport to adjust to the new content height. This will be timed to align with the collapse animation duration (0.35s spring).

## Tasks
1. [Punchlist/Views/ContentView.swift:204-209] — Modify the `onCollapse` callback to accept the `ScrollViewReader`'s `proxy` parameter and call `proxy.scrollTo(item.id, anchor: .bottom)` after the collapse animation to force the scroll position to recalculate.
   Verify: Expand a large ticket, collapse it, and confirm items don't disappear.

2. [Punchlist/Views/ContentView.swift:178-219] — Update the `ScrollViewReader` closure to pass the `proxy` to `ItemRow`'s `onCollapse` callback, and add a small delay matching the animation duration before calling `scrollTo`.
   Verify: The scroll adjustment happens smoothly after the collapse animation completes.

3. [Punchlist/Views/ItemRow.swift:13] — Update the `onCollapse` closure signature to accept no parameters (it currently doesn't need the proxy — that will be handled in ContentView).
   Verify: Build succeeds, no compilation errors.

## Open Questions
None. The decision to scroll to the collapsed item (with `.bottom` anchor) has been confirmed — this keeps the item visible while properly resizing the container.
