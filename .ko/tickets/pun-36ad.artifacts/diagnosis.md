# Diagnosis: Scrolling Rocking Back and Forth

## Symptoms

When viewing punchlist cards, the scroll view exhibits an oscillating or "rocking" behavior where it eases up and down without user interaction. This creates an unwanted visual distraction and makes the interface feel unstable.

## Root Cause

The issue is caused by **conflicting animations on items that have the `in_progress` status**. Specifically:

1. **Pulse Animation on Card Shadow/Appearance** (ItemRow.swift:90-105)
   - When an item has `in_progress` status, a continuous pulse animation is triggered that animates the `pulseActive` state
   - This animation runs with `.easeInOut(duration: 2.0).repeatForever(autoreverses: true)`
   - The animation affects the card's shadow (blur radius and opacity), causing the visual bounds to expand/contract

2. **Animation on isExpanded State** (ItemRow.swift:83)
   - The entire card body has `.animation(.spring(response: 0.35, dampingFraction: 0.8), value: isExpanded)`
   - This means ANY state change triggers a spring animation on the entire card

3. **ScrollView Layout Recalculation**
   - As the shadow radius changes from the pulse (4 to 8 blur radius), the layout system recalculates the card's effective bounds
   - The ScrollView's content size changes slightly with each pulse cycle
   - The `.defaultScrollAnchor(.bottom)` in ContentView.swift:220 attempts to maintain scroll position at bottom
   - This creates a feedback loop: pulse → layout change → scroll adjustment → pulse → layout change → etc.

The "rocking" effect is the ScrollView's attempt to maintain the bottom anchor while the content size oscillates due to the pulsing shadow.

## Affected Code

**Primary:**
- `Punchlist/Views/ItemRow.swift:88-105` - Pulse animation initialization and shadow application
- `Punchlist/Views/ItemRow.swift:83` - Global animation modifier on card body

**Secondary:**
- `Punchlist/Views/ContentView.swift:220` - `.defaultScrollAnchor(.bottom)` interacting with changing content size

## Recommended Fix

There are several approaches to fix this, in order of preference:

### Option 1: Use Layout-Neutral Animation (Recommended)
Modify the pulse animation to only affect properties that don't trigger layout recalculation:
- Use a fixed `padding()` to reserve space for the maximum shadow radius
- Only animate the shadow's opacity, not its radius
- This prevents layout changes while maintaining visual feedback

### Option 2: Disable Implicit Animations on Shadow
Replace the global `.animation()` modifier with explicit animations only where needed:
- Remove line 83's `.animation(.spring(...), value: isExpanded)`
- Add explicit `withAnimation` wrappers in ContentView for expand/collapse actions
- This gives finer control over what gets animated

### Option 3: Remove defaultScrollAnchor for In-Progress Items
Conditionally disable `.defaultScrollAnchor(.bottom)` when any item is in progress:
- This breaks the feedback loop but may cause unexpected scroll behavior
- Less ideal as it changes navigation UX based on item state

## Risk Assessment

**Option 1 Risks:**
- Low risk - Layout-preserving changes are safe
- May need to adjust padding values to visually match current appearance
- Need to test with multiple in-progress items to ensure spacing looks correct

**Option 2 Risks:**
- Medium risk - Removing global animation could affect other UI transitions
- Requires careful review of all expand/collapse interactions
- May inadvertently remove desired animations elsewhere

**Option 3 Risks:**
- Medium-high risk - Changes fundamental scroll behavior
- Users may notice scroll position "jumping" when items change status
- Doesn't actually fix the root cause

**What Could Go Wrong:**
- If padding/spacing is miscalculated, cards might appear too close/far apart
- Visual appearance of the pulse effect might change slightly
- Other animations relying on the global modifier might stop working

**What Else It Might Affect:**
- Any other animations on the ItemRow (expand/collapse, hold-to-close bar)
- Spacing between cards in the list
- Visual alignment of cards with different statuses
- Shadow appearance for blocked/hasUnresolvedDep states (lines 240-242)
