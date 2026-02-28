Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Plan written to `.ko/tickets/pun-c83a.artifacts/plan.md`. Here's the summary:

**4 tasks across 2 files:**

1. **`Item.swift`** — Add `var triage: String?` with proper CodingKey and decode.
2. **`ItemRow.swift`** — Add `hasTriage` computed property.
3. **`ItemRow.swift` (circle view)** — Render solid filled grey circle when `hasTriage`, mirroring the done/resolved filled green pattern.
4. **`ItemRow.swift` (tap overlay)** — Gate triage input on `onTriage != nil && !hasTriage` so already-triaged tickets don't re-open the input.

No open questions — the approach is straightforward and follows existing patterns in the codebase.
