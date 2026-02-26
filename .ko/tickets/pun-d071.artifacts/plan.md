## Goal
Display tickets with "resolved" status using a green visual treatment in project view, similar to how completed items are shown.

## Context
The app currently has visual treatments for different ticket statuses in `ItemRow.swift`:
- **blocked** status: pink/red accent (`.punchPink`) with border and shadow
- **in_progress** status: blue accent (`.punchBlue`) with pulsing animation
- **hasUnresolvedDep**: orange accent (`.punchOrange`)
- **closed** status: treated as `done`, shows green checkmark circle

The `Item` model has a `status` field. Current observed values in tickets are: "closed", "in_progress", "blocked", "open". The ticket asserts that "resolved" is an existing status value (though no current tickets use it). The `done` property is derived from `status == "closed"` (line 32 of Item.swift).

"Resolved" is described as "the work is done, and a human should see it" — often used for question tickets or wontfix scenarios. It's conceptually complete but warrants human attention, unlike "closed" which fades into the background. The ticket references "red treatment for questions" which appears to mean the pink treatment used for blocked tickets.

Key files:
- `Punchlist/Models/Item.swift`: Item model with status field
- `Punchlist/Views/ItemRow.swift`: Visual treatment logic (lines 21-46 for status checks, 228-234 for circle color, 41-46 for accent color)

## Approach
Add a "resolved" status check to `ItemRow.swift` that treats it similarly to closed/done items — showing the green filled circle with checkmark but without strikethrough text or gray color, since the work is done but warrants human review. This maintains visual distinction from truly closed items.

## Tasks
1. [Punchlist/Views/ItemRow.swift] — Add computed property `isResolved` that checks `item.status == "resolved"` (similar to `isInProgress` and `isBlocked` properties around line 21-27).
   Verify: Build succeeds with `just check`.

2. [Punchlist/Views/ItemRow.swift:circleColor] — Update the `circleColor` computed property to return `.punchGreen` when `isResolved` is true, inserting the check after the `item.done` check (around line 229).
   Verify: Resolved tickets show green circle border.

3. [Punchlist/Views/ItemRow.swift:circle] — Update the `circle` view to show a filled green circle with checkmark for resolved items, similar to done items. Add conditional check for `isResolved` alongside the existing `item.done` check (around lines 250-258).
   Verify: Resolved tickets display with green filled circle and checkmark icon.

4. [Punchlist/Views/ItemRow.swift:accentColor] — Optionally add resolved status to the `accentColor` property if we want a subtle green border/shadow treatment. This may not be needed if the green circle is sufficient visual indicator.
   Verify: Visual appearance matches intent — resolved items are visually distinguished with green treatment.

## Open Questions
None — the implementation follows the existing pattern for status-based visual treatments. The ticket specifies using "the same completed circle treatment" which clearly means the green filled circle with checkmark. The main assumption is that resolved items should NOT get the gray/strikethrough treatment of closed items, since they're meant to draw attention for human review rather than fade into the background.
