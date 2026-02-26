The plan has been updated to reflect the answered question. The approach is now clear:

**Goal:** Fix ScrollView container not shrinking when a large expanded ticket collapses.

**Approach:** Use `ScrollViewReader.scrollTo()` to explicitly scroll to the collapsed item with `.bottom` anchor after the collapse animation completes. This keeps the collapsed item visible while forcing the viewport to properly resize.

**Tasks:**
1. Modify the `onCollapse` callback in ContentView to call `scrollTo(item.id, anchor: .bottom)`
2. Update the ScrollViewReader closure to handle the scrollTo with proper timing
3. Ensure ItemRow's onCollapse signature is compatible

**Open Questions:** None — the decision to scroll to the collapsed item has been confirmed.

The plan is ready for implementation.
