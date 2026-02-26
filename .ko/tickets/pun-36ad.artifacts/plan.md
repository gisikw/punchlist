## Goal
Stop the scroll view from oscillating up and down when viewing cards with in_progress status.

## Context
The diagnosis identified the root cause: the pulse animation on in_progress items changes the shadow radius (4 to 8), which triggers layout recalculation in the ScrollView. Combined with `.defaultScrollAnchor(.bottom)` in ContentView.swift:220, this creates a feedback loop where the scroll position adjusts to maintain bottom anchor as content size changes, causing the "rocking" effect.

Relevant files:
- `Punchlist/Views/ItemRow.swift:88-105` — Pulse animation on shadow radius and opacity
- `Punchlist/Views/ItemRow.swift:83` — Global spring animation on isExpanded state
- `Punchlist/Views/ContentView.swift:220` — Bottom scroll anchor

The diagnosis recommends Option 1: use layout-neutral animation by fixing shadow space and only animating opacity. This prevents layout changes while maintaining visual feedback, and has the lowest risk.

## Approach
Modify ItemRow.swift to reserve fixed space for the largest shadow radius (8) using padding, then animate only the shadow's opacity instead of its radius. This prevents the shadow from changing the card's layout bounds during the pulse cycle, eliminating the scroll oscillation while preserving the visual pulse effect.

## Tasks
1. [Punchlist/Views/ItemRow.swift:88-89] — Replace the dynamic shadow radius (4 to 8) with a fixed radius of 8, and animate only the opacity. Change the shadow line to use a constant radius and vary only the opacity based on pulseActive state.
   Verify: Build succeeds with `just check`.

2. [Punchlist/Views/ItemRow.swift:80-82] — Add fixed padding around the card body to reserve space for the maximum shadow, preventing layout shift. Add `.padding(8)` before `.background(.white)` to accommodate the 8pt shadow radius.
   Verify: Visual inspection in simulator shows no scroll oscillation on in_progress items; pulse effect still visible.

3. Manual testing — Open the app with multiple items including at least one in_progress. Confirm scroll view is stable and doesn't rock. Verify pulse animation is still visible on in_progress items. Check blocked items still render correctly with their static shadow.
   Verify: No scroll oscillation; pulse visible; blocked/unresolved-dep items unaffected.

## Open Questions
None — the fix is mechanical and the diagnosis is thorough. We're implementing the recommended approach (Option 1) which has clear implementation steps and low risk.
