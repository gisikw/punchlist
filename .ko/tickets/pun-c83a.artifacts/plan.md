## Goal
Render the status circle as filled grey when a ticket has a triage value, and prevent re-triaging those tickets.

## Context
`Item.swift` has no `triage` field yet — it must be added. The JSON key will be `triage` (a string, presumably the triage note text). The `circle` computed property in `ItemRow.swift` (lines 322–346) handles all visual states; done/resolved render a filled green circle with checkmark. Other states only stroke the border. `circleColor` (lines 311–319) drives the stroke color. The tap overlay at lines 182–188 checks `onTriage != nil` to decide whether to open the triage input; `onTriage` is passed as `nil` for personal items and non-nil for project items (`ContentView.swift` line 219).

## Approach
Add an optional `triage: String?` field to `Item`. In `ItemRow`, add a `hasTriage` computed property. Modify `circle` to render a solid grey fill (matching the grey stroke path used for default state) when `hasTriage` is true, similar to how done renders filled green. Modify the tap overlay logic to suppress triage input when `item.triage != nil`.

## Tasks
1. [Punchlist/Models/Item.swift] — Add `var triage: String?` field, add `triage` to `CodingKeys`, decode it with `decodeIfPresent` in `init(from:)`. No change needed to the manual `init` (triage only comes from API responses).
   Verify: project builds without errors.

2. [Punchlist/Views/ItemRow.swift:hasTriage] — Add `private var hasTriage: Bool { item.triage != nil }` alongside the other status computed properties (around line 26).
   Verify: project builds.

3. [Punchlist/Views/ItemRow.swift:circle] — In the `circle` computed view, add a branch for `hasTriage` that renders a filled solid grey circle (using `Color.punchGray` fill, same 22pt frame), placed after the done/resolved branch check so done still wins if both are set. No checkmark overlay for triage.
   Verify: visually confirmed in simulator — triaged ticket shows filled grey circle.

4. [Punchlist/Views/ItemRow.swift:tap overlay] — In the tap gesture at line 185, change the condition from `if onTriage != nil` to `if onTriage != nil && !hasTriage` so that tapping the circle on an already-triaged ticket falls through to the normal expand/toggle behavior.
   Verify: tapping a triaged ticket's circle does not open the triage text input.

## Open Questions
None. The triage JSON key name (`triage`) is consistent with the field naming in `Item.swift` (no remapping needed since it's a lowercase single word). The "filled grey" treatment mirrors the done/resolved filled green pattern — solid fill, no additional icon.
