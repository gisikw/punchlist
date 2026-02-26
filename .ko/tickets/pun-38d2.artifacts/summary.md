# Implementation Summary: pun-38d2

## What Was Done
Extended the breathing animation to the entire `in_progress` card by making the blue border stroke pulse in sync with the existing shadow animation.

**Single-line change in `Punchlist/Views/ItemRow.swift:91`:**
- **Before:** Static border opacity of `0.3` for `in_progress` items
- **After:** Animated border opacity that pulses between `0.5` (active) and `0.15` (inactive) for `in_progress` items

The implementation uses the existing `pulseActive` state that already drives the shadow (lines 93-94) and circle indicator (lines 241-266) animations. This creates a unified breathing effect where the blue glow around the entire card pulses in a coordinated 2-second cycle.

## Notable Decisions
1. **Opacity range:** Chose `0.5` → `0.15` for the border to make it noticeable while keeping the glow subtle and elegant
2. **Preserved constraint:** Only animates opacity (not radius or other layout properties) to maintain the fix from pun-36ad that prevents scroll oscillation
3. **Conditional logic:** The implementation preserves the existing behavior for blocked/dependency statuses (static borders) by only pulsing when `hasPulse` is true

## Verification
- ✅ `just check` passed
- ✅ `just build` succeeded
- ⏳ Manual testing required: User should verify in simulator that:
  - Blue border and shadow pulse together creating unified glow
  - No scroll oscillation (regression check)
  - Other statuses (blocked/dependency) remain static

## Invariant Compliance
No invariants were violated. The change:
- Uses SwiftUI only (no UIKit)
- Maintains the single-file structure
- Follows the established animation pattern
- Preserves the color palette (#78DCE8 punchBlue)
- Keeps UI behavior consistent (no modals, instant updates)
