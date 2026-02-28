## Summary

Implemented triage visual treatment as specified.

### What was done

1. **Item.swift** — Added `var triage: String?` field with `CodingKeys` entry and `decodeIfPresent` in the custom decoder. Only affects deserialization from API responses.

2. **ItemRow.swift** — Added `private var hasTriage: Bool` computed property.

3. **ItemRow.swift (circle)** — Added `else if hasTriage` branch rendering a filled `Color.punchGray` circle at 22pt, placed after the `done || isResolved` branch so a closed/resolved ticket always shows green (done wins).

4. **ItemRow.swift (tap overlay)** — Triage input is now gated on `onTriage != nil && !hasTriage`, so tapping the circle on an already-triaged ticket falls through to normal expand/toggle behavior.

### Notable decisions

No deviations from the plan. `hasTriage` placement (line 54 vs. the plan's "around line 26") is inconsequential — it sits correctly in the computed-property section.

### Nothing to flag

No edge cases were missed. The `done` state correctly supersedes triage visually. Triage suppression works for both personal and project ticket contexts since it only fires when `onTriage != nil` (project tickets) anyway.
