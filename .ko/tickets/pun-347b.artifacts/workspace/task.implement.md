Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Done. Here's a summary of changes:

**Task 1 — `KoAPI.swift`**
Added `triageItem(id:text:)` under `// MARK: - Items`, calling `run(["triage", id, text])` and discarding the result.

**Task 2 — `PunchlistViewModel.swift`**
Added `triageItem(_:text:)` in `// MARK: - Actions`. Trims whitespace, guards against empty text, then fire-and-forgets `api.triageItem(id:text:)` in a `Task`. No offline queue entry (triage is an annotation, not a state mutation).

**Task 3 — `ItemRow.swift`**
- Added `let onTriage: ((String) -> Void)?` parameter after `onCollapse`
- Added `@State private var showTriageInput = false` and `@State private var triageText = ""`
- Restructured `tapOverlay`'s non-done branch: leading 44pt `Color.clear` zone fires `showTriageInput.toggle()` when `onTriage != nil`, otherwise falls back to the existing expand/toggle behavior; remaining width zone handles expand; rightmost 20% zone handles bump (unchanged)
- Added `if showTriageInput` block between the overlay and the `if isExpanded` block: renders a `TextField` with a submit label and an X cancel button; submit trims text, calls `onTriage?`, then resets state

**Task 4 — `ContentView.swift`**
Passed `onTriage` to `ItemRow`: `nil` when `viewModel.isPersonal`, otherwise `{ text in viewModel.triageItem(item, text: text) }`.

No deviations from the plan.
