Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
## Summary

All 4 tasks complete, no deviations from the plan.

**`Punchlist/Models/Item.swift`**
- Added `var triage: String?` property
- Added `triage` to `CodingKeys`
- Added `triage = try c.decodeIfPresent(String.self, forKey: .triage)` in `init(from:)`

**`Punchlist/Views/ItemRow.swift`**
- Added `private var hasTriage: Bool { item.triage != nil }` alongside other status computed properties
- In `circle`: added `else if hasTriage` branch after the `done || isResolved` branch — renders a solid `Color.punchGray` filled circle (22pt), no icon
- In `tapOverlay`: changed `if onTriage != nil` to `if onTriage != nil && !hasTriage` — triaged tickets fall through to expand/toggle behavior
