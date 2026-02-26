# Implementation Summary

## What Was Done

Fixed the scroll view oscillation issue that occurred when viewing cards with `in_progress` status. The problem was caused by the pulse animation dynamically changing the shadow radius between 4 and 8 points, which triggered layout recalculation in the ScrollView. Combined with `.defaultScrollAnchor(.bottom)`, this created a feedback loop causing the scroll view to "rock" up and down.

### Changes Made

**File:** `Punchlist/Views/ItemRow.swift`

1. **Line 81**: Added `.padding(8)` to reserve fixed space for the maximum shadow radius
   - This padding prevents layout shifts when the shadow animates
   - Placed before `.background(.white)` in the modifier chain

2. **Line 90**: Fixed shadow radius to a constant value
   - Changed from: `radius: hasActiveStatus ? (hasPulse ? (pulseActive ? 8 : 4) : 6) : 1.5`
   - Changed to: `radius: hasActiveStatus ? 8 : 1.5`
   - Shadow opacity still animates: `pulseActive ? 0.18 : 0.06`
   - This preserves the visual pulse effect while eliminating layout changes

## Plan Compliance

✅ **Task 1 completed**: Shadow radius fixed to constant value (8pt for active status)
✅ **Task 2 completed**: Fixed padding (8pt) added to reserve shadow space
✅ **Task 3 pending**: Manual testing required (see below)

All planned changes were implemented exactly as specified. No deviations from the plan.

## Invariants Check

✅ All INVARIANTS.md contracts maintained:
- SwiftUI-only approach (no UIKit wrappers)
- Uses `@Observable` pattern (no changes to model layer)
- No third-party dependencies introduced
- Follows existing SwiftUI modifier patterns in the file
- No changes to data model or network layer

## Testing Required

Manual verification needed (as specified in plan Task 3):
1. **Scroll stability**: Verify no oscillation when viewing items with `in_progress` status
2. **Pulse animation**: Confirm the shadow pulse effect is still visible on `in_progress` items
3. **Blocked items**: Check that blocked/unresolved-dep items still render correctly with their static shadow
4. **Visual appearance**: Ensure overall card appearance matches previous design (the 8pt padding may make cards slightly larger)

## Notable Decisions

- **Fixed radius choice**: Used 8pt (the maximum from the original animation) instead of the non-pulse value of 6pt. This ensures the pulse animation has full visual impact while maintaining layout stability.
- **Padding placement**: Added padding before `.background(.white)` rather than after, which ensures the padding is included in the white background area and doesn't create extra space outside the card.

## What Future Readers Should Know

The root cause was that SwiftUI's layout system treats shadow radius changes as layout-affecting, even though shadows don't typically affect layout in CSS. The solution follows a common pattern: reserve space for the maximum extent of an animating property, then animate only properties that don't affect layout (like opacity).

If similar scroll oscillation issues appear with other animations, check for:
1. Animating properties that affect layout (size, padding, shadow radius)
2. ScrollView anchoring behavior (especially `.defaultScrollAnchor(.bottom)`)
3. Whether the animation can be converted to animate layout-neutral properties (opacity, color, offset)
