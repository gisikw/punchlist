Good! The build succeeded. Now I need to manually test the app in the simulator. Since I can't directly interact with the iOS simulator from here, let me document what needs to be verified according to Task 2:

---

## Implementation Summary

I've successfully completed **Task 1** from the plan:

### Task 1: Make the border stroke opacity pulse for in_progress items ✓

**File modified:** `Punchlist/Views/ItemRow.swift:91`

**Change:** Updated the border stroke overlay to animate opacity based on the `pulseActive` state:
- **Before:** Static opacity of `0.3` for `in_progress` items
- **After:** Animated opacity that pulses between `0.5` (active) and `0.15` (inactive) for `in_progress` items, synced with the existing shadow pulse

The implementation uses the same `pulseActive` state that drives the shadow (lines 93-94) and circle indicator (lines 245, 266) animations, ensuring all three elements breathe together in a coordinated 2-second cycle.

**Verification:** `just check` passed successfully, and `just build` succeeded, confirming the code compiles correctly.

---

### Task 2: Manual Testing (Ready for User Verification)

The build is ready for manual testing in the simulator. According to the plan, the following should be verified:

1. **Blue border pulses in sync with shadow** — The border stroke opacity should animate between 0.5 and 0.15, creating a unified breathing glow around `in_progress` items
2. **Cohesive with circle animation** — The border, shadow, and circle indicator should all pulse together
3. **Other statuses unaffected** — Blocked items (static pink border) and dependency items (static orange border) should remain static
4. **No scroll oscillation** — Regression check from pun-36ad: confirm that animating only opacity (not radius) prevents scroll bounce

The implementation follows the plan exactly, using only opacity changes (no layout-affecting modifications) to preserve the fix from pun-36ad.
