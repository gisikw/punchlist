## Goal
Make the triage grey circle take visual precedence over the done/resolved green checkmark in the status circle.

## Context
The `circle` computed property in `Punchlist/Views/ItemRow.swift` (lines 322–352) renders the status indicator. The inner conditional block (lines 332–344) uses `if item.done || isResolved` first, then `else if hasTriage`. This means a ticket that is both done and has a triage value will show the green checkmark, not the grey triage circle. The ticket says triage should take precedence over all other indicators.

The `hasTriage` computed property (line 55) returns `item.triage != nil`.

## Approach
Swap the order of the two branches so `hasTriage` is checked first. If a ticket has a triage value, render the grey circle regardless of done/resolved state. Only fall through to the green checkmark if `hasTriage` is false.

## Tasks
1. [Punchlist/Views/ItemRow.swift:332–344] — Swap the `if item.done || isResolved` and `else if hasTriage` branches so the triage grey circle renders first when `hasTriage` is true, with the done/resolved green checkmark as the `else if` fallback.
   Verify: A done ticket with a triage value shows the grey filled circle; a done ticket without triage still shows the green checkmark.

## Open Questions
None.
