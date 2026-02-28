Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Plan written to `/home/dev/Projects/punchlist/.ko/tickets/pun-347b.artifacts/plan.md`.

**Summary:**

The ticket adds an inline triage text input triggered by tapping the status circle on project tickets. Four files to touch:

1. **`KoAPI.swift`** — Add `triageItem(id:text:)` calling `ko triage <id> <text>`.
2. **`PunchlistViewModel.swift`** — Add `triageItem(_:text:)` action method (fire-and-forget, like `bumpItem`).
3. **`ItemRow.swift`** — The main work: add `onTriage: ((String) -> Void)?` callback, add local `showTriageInput`/`triageText` state, restructure `tapOverlay` to carve a 44pt circle zone out of the left region that toggles the triage input instead of expanding, and render an inline `TextField` + submit/cancel when `showTriageInput == true`.
4. **`ContentView.swift`** — Wire up `onTriage` to `viewModel.triageItem(item, text:)` for project items, `nil` for personal.

No open questions — the patterns are well-established in the codebase and the requirements are clear.
