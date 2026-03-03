## Goal
Make the "x" dismiss button in the input bar render as a lighter grey.

## Context
The clear button lives in `Punchlist/Views/InputBar.swift` at line 24. It currently uses `.foregroundStyle(.secondary)`, which renders as a mid-grey. A prior ticket (pun-f646) already removed color from this button. SwiftUI's hierarchy goes: `.primary` → `.secondary` → `.tertiary` → `.quaternary`, each progressively lighter/more faded.

## Approach
Change `.foregroundStyle(.secondary)` to `.foregroundStyle(.tertiary)` on the xmark button label. This is a one-line change that uses the built-in semantic color hierarchy without hardcoding values.

## Tasks
1. [Punchlist/Views/InputBar.swift:24] — Change `.foregroundStyle(.secondary)` to `.foregroundStyle(.tertiary)` on the `Image(systemName: "xmark.circle.fill")`.
   Verify: Build succeeds; the x button appears visibly lighter than before.

## Open Questions
None.
