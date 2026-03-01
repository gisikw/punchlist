---
id: pun-fa8e
status: closed
deps: []
created: 2026-03-01T06:20:56Z
type: task
priority: 2
---
# Let the in-progress indicator supersede the triage indicator (though maybe still using a grey circle outline but with blue fill / glow would be nice)

## Notes

**2026-03-01 14:05:59 UTC:** ## Summary

Implemented visual precedence for the in-progress indicator over the triage indicator in `ItemRow.swift`.

### What was done

Two targeted changes in `ItemRow.swift`:

1. **`circleColor` (line 322):** Added `if hasTriage && isInProgress { return .punchGray }` before the existing `isInProgress` case. This changes the strokeBorder color to grey when both states are active, providing a subtle triage hint while still letting the blue glow dominate.

2. **`circle` ZStack (line 338):** Changed `if hasTriage {` to `if hasTriage && !isInProgress {`. This prevents the solid grey fill circle from covering the blue glow when a ticket is simultaneously in triage and in-progress.

### Result

A ticket that is both in triage and in-progress now displays: blue glow/fill (from `hasActiveStatus` layer) with a grey circle ring outline (from `circleColor`). This matches the ticket's design suggestion — "grey circle outline but with blue fill / glow."

### Decisions

No deviations from the plan. The implementation was straightforward and the plan's mapping to code was precise.

**2026-03-01 14:05:59 UTC:** ko: SUCCEED
