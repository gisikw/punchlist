## Goal
Extend the breathing animation to the entire card by adding a pulsing blue glow/shadow around the card's border.

## Context
Current implementation in `Punchlist/Views/ItemRow.swift`:

- Lines 89-91: Card has a thin border stroke with static opacity (0.3) for in_progress items using `accentColor` (punchBlue #78DCE8)
- Lines 93-94: Shadow already pulses for in_progress items, animating opacity between 0.03 and 0.28 with the blue accent color
- Lines 241-266: Circle indicator pulses with fill opacity (0.15 to 0.4) and scale (1.0 to 1.08)
- Lines 96-110: `pulseActive` state drives the 2-second breathing animation

The shadow currently provides a subtle glow effect, but the border stroke remains static. The ticket requests making the whole card "have a breathing animation" with a "pulsing blue shadow/glow" — this means animating the border stroke opacity to sync with the existing shadow pulse.

Color constants are defined at lines 279-287. The punchBlue (#78DCE8) is already used for in_progress items.

Recent work (pun-36ad) fixed scroll oscillation by keeping shadow radius fixed at 8 and animating only opacity. We must preserve this constraint and avoid layout-affecting changes.

## Approach
Animate the border stroke opacity in sync with the existing shadow pulse. Currently the border uses `accentColor.opacity(hasActiveStatus ? 0.3 : 0)` with a static 0.3 opacity for in_progress items. We'll make this opacity animate along with `pulseActive` to create a coordinated breathing effect across both the shadow and the border.

This creates a unified glow effect where the blue halo around the entire card breathes in and out, complementing the existing shadow and circle animations.

## Tasks
1. [Punchlist/Views/ItemRow.swift:91] — Make the border stroke opacity pulse for in_progress items. Change the overlay stroke from static `0.3` opacity to animate between two values based on `pulseActive` state (e.g., `hasPulse ? (pulseActive ? 0.5 : 0.15) : 0.3`). This syncs the border breathing with the shadow pulse.
   Verify: `just check` succeeds.

2. Manual testing — Run in simulator with at least one in_progress item. Verify the blue border now pulses in sync with the shadow, creating a unified glow effect around the entire card. Confirm the breathing is noticeable and feels cohesive with the circle animation. Check that blocked items (static pink border) and dependency items (static orange border) remain unaffected. Verify no scroll oscillation occurs (pun-36ad regression check).
   Verify: Border and shadow pulse together creating a unified glow; no scroll bounce; other statuses unaffected.

## Open Questions
None. The implementation is straightforward — we're extending the existing pulse animation to the border stroke, using the same `pulseActive` state that already drives the shadow and circle animations.
