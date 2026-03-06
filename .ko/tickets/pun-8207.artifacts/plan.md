## Goal
Evenly distribute the three circle action buttons (comment, block/unblock, complete) across the full row width so they're easier to tap without mistaps.

## Context
The `circleActionsOverlay` view in `Punchlist/Views/ItemRow.swift` (line 367–411) renders three buttons inside an `HStack(spacing: 20)` with `.frame(maxWidth: .infinity)`. The fixed 20pt spacing causes the buttons to cluster together in the center of the available space rather than spreading out. The outer HStack reserves 44pt on the left (circle placeholder) and 20% of width on the right as dismiss tap targets.

## Approach
Replace the fixed `spacing: 20` on the inner button HStack with `spacing: 0` and insert `Spacer()` views between (and optionally around) the buttons. This distributes them evenly across the full available width.

## Tasks
1. [Punchlist/Views/ItemRow.swift:375] — Change `HStack(spacing: 20)` to `HStack(spacing: 0)` and add `Spacer()` between each button (and at the leading/trailing edges if needed) so the three buttons fill the row evenly.
   Verify: Build succeeds; in the simulator, tapping a circle in project view shows three buttons spread across the card width.

## Open Questions
None — even distribution is unambiguous given the ticket description.
