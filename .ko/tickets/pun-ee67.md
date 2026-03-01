---
id: pun-ee67
status: closed
deps: []
created: 2026-02-28T07:19:37Z
type: task
priority: 2
---
# We need an (x) in the add ticket input when text exists, to make it easy to remove the body if the user decides to skip

## Notes

**2026-02-28 07:59:42 UTC:** # After-Action Summary: pun-ee67

## What Was Done

Added a clear (×) button to `InputBar.swift` that appears when text is present in the add-ticket input field.

### Implementation

- Wrapped the bare `TextField` in an `HStack`
- Added a `Button` with an `"xmark.circle.fill"` SF Symbol on the trailing side
- Button sets `text = ""` on tap
- Button is conditionally rendered with `if !text.isEmpty` (no animation, as planned)
- Moved `.padding(14)`, `.background(.white)`, `.clipShape(...)`, and `.shadow(...)` to the `HStack` so the container styling is unchanged
- All existing submit logic preserved as-is

## Notable Decisions

- Used a plain `if` guard (not `opacity` or `.animation`) to show/hide the button — matches the plan's recommendation to avoid animation jank
- No changes outside `InputBar.swift` — the `text` binding is owned by the caller, so clearing it is safe from within the view

## Invariants Check

No invariants were violated. The change is purely additive UI within the input bar component. SwiftUI-only, no third-party dependencies, no new files.

**2026-02-28 07:59:42 UTC:** ko: SUCCEED
