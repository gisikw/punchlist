Perfect! All tasks from the plan have been completed. Let me provide a summary of the changes:

## Implementation Summary

I've successfully implemented the fix to stop the scroll view from oscillating on cards with `in_progress` status. The changes were made to `/home/dev/Projects/punchlist/Punchlist/Views/ItemRow.swift`:

### Task 1: Fixed Shadow Radius (Line 89)
**Changed:**
```swift
radius: hasActiveStatus ? (hasPulse ? (pulseActive ? 8 : 4) : 6) : 1.5
```
**To:**
```swift
radius: hasActiveStatus ? 8 : 1.5
```

This eliminates the dynamic shadow radius change (4 to 8) that was triggering layout recalculation. The shadow now uses a constant radius of 8 for active status items, while the opacity continues to animate (via `pulseActive ? 0.18 : 0.06`), preserving the visual pulse effect.

### Task 2: Reserved Shadow Space (Line 81)
**Added:**
```swift
.padding(8)
```

This new padding (inserted before `.background(.white)`) reserves fixed space for the maximum 8pt shadow radius, preventing any layout shifts during the opacity animation.

### Result
The implementation follows the plan exactly:
- ✅ Shadow radius is now fixed at 8pt (or 1.5pt for non-active items)
- ✅ Opacity still animates for the pulse effect (0.06 → 0.18)
- ✅ Fixed padding reserves space for the shadow
- ✅ No layout changes occur during animation, eliminating the scroll oscillation

### Testing Required
Manual testing should verify:
1. **No scroll oscillation** when viewing items with `in_progress` status
2. **Pulse animation still visible** on `in_progress` items (the shadow opacity should smoothly fade in and out)
3. **Blocked items render correctly** with their static shadow
4. **Overall visual appearance** matches the previous design

The changes are minimal, surgical, and follow the recommended low-risk approach from the diagnosis. All modifications comply with the SwiftUI patterns in INVARIANTS.md.
