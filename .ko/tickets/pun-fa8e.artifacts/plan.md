## Goal
When a ticket is both in-progress and in triage, the in-progress indicator wins visually: show a blue fill/glow with a grey circle outline (not the current grey fill that hides the blue).

## Context
All indicator logic lives in `ItemRow.swift`. The `circle` computed property (line 327) uses a ZStack with three layers:
1. Background glow circle — blue fill when `hasActiveStatus` (in-progress or blocked)
2. Status fill circle — grey fill when `hasTriage`, green fill when done/resolved
3. Border stroke — color from `circleColor`

Currently `hasTriage` unconditionally renders a solid grey fill circle (layer 2), which covers the blue glow from layer 1. The blue border still shows because `circleColor` (line 318) returns `.punchBlue` for `isInProgress` without considering triage.

The card-level border/shadow glow (lines 131-136) already responds to `hasActiveStatus` (blue for in-progress) regardless of triage, so no changes needed there.

## Approach
When `hasTriage && isInProgress`, skip the grey fill circle entirely so the blue glow from layer 1 shows through. To still hint at triage status, make the 22×22 circle border grey instead of blue in this combined state. This produces the described visual: "grey circle outline but with blue fill / glow."

## Tasks
1. [Punchlist/Views/ItemRow.swift:337] — In the `circle` ZStack, change `if hasTriage {` to `if hasTriage && !isInProgress {`. This prevents the grey fill from covering the blue glow when a ticket is simultaneously in triage and in-progress.
   Verify: A ticket with both `triage != nil` and `status == "in_progress"` shows a blue glow with no grey overlay.

2. [Punchlist/Views/ItemRow.swift:318] — In `circleColor`, insert a new case before `if isInProgress`:
   `if hasTriage && isInProgress { return .punchGray }`
   This makes the strokeBorder grey (not blue) when both states are active, providing the grey circle outline that acknowledges triage.
   Verify: The same ticket shows a grey ring stroke over the blue fill, matching the ticket's design suggestion.

## Open Questions
None. The ticket's design suggestion ("grey circle outline but with blue fill / glow") maps directly to: skip the grey fill layer → blue glow shows through; grey border stroke → triage hint retained.
