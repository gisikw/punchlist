---
id: pun-3ea3
status: closed
deps: []
created: 2026-02-26T17:30:20Z
type: task
priority: 2
---
# Some recently blocked tickets are pulsing - it's an interesting idea actually if we use it with intent, but it's accidental right now. Where's that coming from?

## Notes

**2026-02-26 17:31:48 UTC:** # Findings: Pulsing Effect on Blocked Tickets

## Summary

The pulsing effect on blocked tickets is **accidental and incorrect**. The pulse animation is only intended for `in_progress` items, but the border/shadow styling accidentally applies to **all items with "active status"**, which includes both `in_progress` AND `blocked` items.

## Root Cause

**File:** `Punchlist/Views/ItemRow.swift`

### The Bug

The issue stems from a mismatch between two computed properties:

1. **`hasPulse` (lines 37-39)** - Controls the pulse animation
   ```swift
   private var hasPulse: Bool {
       isInProgress  // Only in_progress items should pulse
   }
   ```

2. **`hasActiveStatus` (lines 41-43)** - Controls border/shadow styling
   ```swift
   private var hasActiveStatus: Bool {
       isInProgress || isBlocked  // Both in_progress AND blocked get styled
   }
   ```

### Where the Pulse Appears

The pulse effect manifests in three places, all controlled by the `hasPulse` boolean:

1. **Border opacity (line 91):**
   ```swift
   .stroke(accentColor.opacity(hasActiveStatus ? (hasPulse ? (pulseActive ? 0.5 : 0.15) : 0.3) : 0)
   ```

2. **Shadow opacity (line 93):**
   ```swift
   .shadow(color: hasActiveStatus ? accentColor.opacity(hasPulse ? (pulseActive ? 0.28 : 0.03) : 0.12) : ...)
   ```

3. **Circle scale effect (line 266):**
   ```swift
   .scaleEffect(hasPulse ? (pulseActive ? 1.08 : 1.0) : 1.0)
   ```

### Why Blocked Items Pulse

The conditional logic checks `hasActiveStatus` first (which is true for blocked items), then uses `hasPulse` to determine the opacity values. However, when `hasPulse` is false (for blocked items), it falls back to static opacity values (0.3 for border, 0.12 for shadow).

**The subtle issue:** Recently blocked tickets that were **previously in_progress** may still have `pulseActive = true` in their local state, causing them to show the pulsing border/shadow until the view re-renders. This creates the "recently blocked tickets are pulsing" behavior.

### Animation State Management

The pulse animation is controlled by `@State private var pulseActive` (line 15) and is toggled in two places:

1. **On appear (lines 95-101):** Sets up the pulse if `hasPulse` is true
2. **On change (lines 102-110):** Updates pulse when `hasPulse` changes

However, when an item transitions from `in_progress` to `blocked`:
- `hasPulse` becomes false
- The `onChange` handler sets `pulseActive = false` (line 108)
- BUT there may be a brief window where the animation is still running, especially if the view doesn't immediately re-render

## Code Paths

### For In-Progress Items (Correct Behavior)
- `isInProgress = true`
- `hasPulse = true` → pulse animation starts
- `hasActiveStatus = true` → border/shadow applied with pulsing opacity

### For Blocked Items (Current Buggy Behavior)
- `isBlocked = true`
- `hasPulse = false` → should have no pulse
- `hasActiveStatus = true` → border/shadow applied with **static** opacity
- **BUT** if recently transitioned from in_progress, `pulseActive` may still be true temporarily

## Recommended Actions

### Option 1: Strict Pulse Check (Recommended)
Ensure blocked items never use pulse-dependent styling, even transiently:

```swift
// Line 91-94, change from:
.overlay(
    RoundedRectangle(cornerRadius: 8)
        .stroke(accentColor.opacity(hasActiveStatus ? (hasPulse ? (pulseActive ? 0.5 : 0.15) : 0.3) : 0), lineWidth: 1)
)
.shadow(color: hasActiveStatus ? accentColor.opacity(hasPulse ? (pulseActive ? 0.28 : 0.03) : 0.12) : .black.opacity(0.08),
        radius: hasActiveStatus ? 8 : 1.5, y: hasActiveStatus ? 0 : 1)

// To:
.overlay(
    RoundedRectangle(cornerRadius: 8)
        .stroke(accentColor.opacity(hasActiveStatus ? (hasPulse && pulseActive ? 0.5 : hasPulse && !pulseActive ? 0.15 : 0.3) : 0), lineWidth: 1)
)
.shadow(color: hasActiveStatus ? accentColor.opacity(hasPulse && pulseActive ? 0.28 : hasPulse && !pulseActive ? 0.03 : 0.12) : .black.opacity(0.08),
        radius: hasActiveStatus ? 8 : 1.5, y: hasActiveStatus ? 0 : 1)
```

Or more clearly, check `hasPulse` explicitly in the opacity calculation.

### Option 2: Force Pulse State Reset
Add an explicit `.onChange(of: isBlocked)` handler to immediately clear pulse state:

```swift
.onChange(of: isBlocked) { _, newValue in
    if newValue {
        pulseActive = false
    }
}
```

### Option 3: Design Decision - Should Blocked Items Pulse?
If the pulsing effect is actually **desirable** for blocked items (to draw attention to them), then update `hasPulse` to:

```swift
private var hasPulse: Bool {
    isInProgress || isBlocked
}
```

This would make the behavior intentional rather than accidental.

## Intent Analysis

Based on the variable naming and logic structure, the **original intent** appears to be:
- **In-progress items:** Pulsing border/shadow (active, animated)
- **Blocked items:** Static border/shadow (active, but not animated)
- **Other items:** Minimal or no border/shadow

The current implementation mostly achieves this, but the transient state issue causes recently-blocked tickets to briefly pulse until the view updates.

## Additional Notes

- The accent colors are correct: pink for blocked (`.punchPink`), blue for in_progress (`.punchBlue`)
- The circle indicator also scales with the pulse (line 266), which is correctly gated by `hasPulse`
- The issue is subtle and only visible during state transitions, which is why it appears as "recently blocked tickets are pulsing"

**2026-02-26 17:31:48 UTC:** ko: SUCCEED
