## Summary

I've identified the root cause of the scrolling issue. The problem is a **feedback loop between the pulsing animation on in-progress cards and the ScrollView's layout system**:

1. **Cards with `in_progress` status** have a continuous 2-second pulse animation that changes the shadow blur radius (4px ↔ 8px)
2. **Changing shadow radius** causes the layout system to recalculate the card's effective bounds
3. **The ScrollView** tries to maintain its `.defaultScrollAnchor(.bottom)` position as content size changes
4. **Result**: The scroll position oscillates up and down with each pulse cycle

**Key files affected:**
- `ItemRow.swift:88-105` - Where the pulse animation is applied to shadow
- `ItemRow.swift:83` - Global animation modifier that amplifies the effect
- `ContentView.swift:220` - Bottom anchor that responds to layout changes

**Recommended fix:** Use layout-neutral animations by reserving fixed space for the shadow and only animating opacity instead of radius. This maintains the visual pulse effect without triggering layout recalculation.

The diagnosis has been written to `/home/dev/Projects/punchlist/.ko/tickets/pun-36ad.artifacts/diagnosis.md` with detailed analysis and three potential fix approaches with risk assessments.
