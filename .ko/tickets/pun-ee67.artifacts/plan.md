## Goal
Add a clear (×) button to the add ticket input that appears when text is present, allowing the user to quickly clear it.

## Context
The add ticket input is entirely contained in `Punchlist/Views/InputBar.swift`. It's a `TextField` wrapped in a `View` with padding, white background, rounded corners, and a drop shadow. The `text` binding is owned by the caller; `InputBar` just presents and submits it. No other files need to change.

## Approach
Replace the bare `TextField` with an `HStack` containing the `TextField` and a conditionally-visible clear button. The button sets `text = ""` on tap and is only rendered when `text` is non-empty. Keep all existing styling on the outer container.

## Tasks
1. [Punchlist/Views/InputBar.swift] — Wrap the `TextField` in an `HStack`. Add a `Button` with an `"xmark.circle.fill"` SF Symbol to the trailing side that sets `text = ""` on tap, shown only when `!text.isEmpty`. Move the `.padding(14)` and background modifiers to the `HStack` so the layout stays identical when the button is hidden. Use `.animation(.default, value: text.isEmpty)` or a simple `if` — a plain `if` is sufficient and avoids any unwanted animation jank.
   Verify: Build succeeds. Typing in the input shows the (×); tapping it clears the field; submitting still works normally.

## Open Questions
None.
