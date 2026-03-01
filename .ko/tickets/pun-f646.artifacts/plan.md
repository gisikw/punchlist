## Goal
Remove the accent tint from the (x) clear button in InputBar so it renders in a neutral color without any app tint applied.

## Context
The clear button lives in `Punchlist/Views/InputBar.swift` at line 20–25. It uses `Image(systemName: "xmark.circle.fill")` with `.foregroundStyle(.secondary)`. The problem is that SwiftUI `Button` applies the app's accent color to its label by default, which overrides or tints the foreground style. Adding `.buttonStyle(.plain)` disables that default button tinting behavior, letting `.foregroundStyle(.secondary)` render as a clean grey without any color influence.

## Approach
Add `.buttonStyle(.plain)` to the clear Button in InputBar. This is a one-line change that removes the implicit accent tint while keeping the `.foregroundStyle(.secondary)` for a neutral grey appearance.

## Tasks
1. [Punchlist/Views/InputBar.swift] — Add `.buttonStyle(.plain)` to the `Button` that clears the text field (the one with `xmark.circle.fill`). Place it after the closing brace of the `label:` trailing closure.
   Verify: Build succeeds; the (x) button renders grey/secondary without any blue or accent tint.

## Open Questions
None.
