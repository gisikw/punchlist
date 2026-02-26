## Goal
Make the in_progress ticket animation more noticeable while keeping the breathing effect.

## Context
The current implementation in `Punchlist/Views/ItemRow.swift` uses a subtle pulse animation for `in_progress` items:

- Lines 93-94: Shadow opacity animates between 0.06 and 0.18 over 2 seconds
- Lines 245: Circle fill opacity animates between 0.1 and 0.25 over 2 seconds
- Lines 97-110: The `pulseActive` state drives a `.easeInOut(duration: 2.0).repeatForever(autoreverses: true)` animation

The ticket indicates the breathing dot is "nice, but too subtle" — the animation exists but needs more visual emphasis. The app uses a consistent design language with specific colors defined in the Color extension (lines 278-286): punchBlue (#78DCE8) for in_progress items.

Recent work (pun-36ad) fixed shadow-induced scroll oscillation by using fixed shadow radius (8) and animating only opacity, so we must preserve that constraint.

## Approach
Increase the animation contrast by widening the opacity range and potentially adding a subtle scale effect to the circle indicator. We'll make the pulse more obvious through:
1. Stronger shadow opacity range (currently 0.06-0.18, increase to make more dramatic)
2. More dramatic circle fill opacity range (currently 0.1-0.25, increase contrast)
3. Consider adding a gentle scale animation to the circle itself to enhance the breathing effect

Keep the 2-second duration and easeInOut timing to maintain the calm "breathing" quality. Avoid changing shadow radius (fixes pun-36ad constraint).

## Tasks
1. [Punchlist/Views/ItemRow.swift:93] — Increase shadow opacity range for in_progress pulse. Change from `0.06 to 0.18` to something more dramatic like `0.03 to 0.28` to create stronger contrast that's more visible.
   Verify: `just check` succeeds.

2. [Punchlist/Views/ItemRow.swift:245] — Increase circle fill opacity range for in_progress pulse. Change from `0.1 to 0.25` to something stronger like `0.15 to 0.4` to make the breathing dot more obvious.
   Verify: `just check` succeeds.

3. [Punchlist/Views/ItemRow.swift:241-266] — Add subtle scale animation to the circle for in_progress items. Apply `.scaleEffect()` modifier to the outer ZStack that varies with `pulseActive` (e.g., scale between 1.0 and 1.08) to create a gentle growing/shrinking effect synchronized with the opacity pulse.
   Verify: `just check` succeeds and `just build` completes.

4. Manual testing — Run in simulator with at least one in_progress item. Verify the pulse animation is more noticeable than before. Check that blocked items (punchPink) and items with unresolved dependencies (punchOrange) still render correctly with their static appearance. Ensure no scroll oscillation occurs (pun-36ad regression check).
   Verify: Animation is obviously visible without being distracting; no scroll bounce; other statuses unaffected.

## Open Questions
Should we also increase the animation duration slightly (e.g., 2.0s → 2.5s) to make the breathing more languid and noticeable? The current 2-second cycle might be fast enough that the increased contrast alone is sufficient, but a slower cycle could make it even more obvious. Probably fine to start with just the opacity and scale changes.
