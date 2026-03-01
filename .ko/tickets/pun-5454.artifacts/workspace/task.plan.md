Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Plan written to `$KO_ARTIFACT_DIR/plan.md`.

**Summary:** The fix is contained entirely in `ItemRow.swift`. The triage `TextField` (lines 81–107) has no focus management, so the keyboard doesn't appear automatically when the triage input is toggled on. The approach mirrors the existing `InputBar` pattern:

1. Add `@FocusState private var triageInputFocused: Bool`
2. Attach `.focused($triageInputFocused)` to the triage `TextField`
3. Add `.onChange(of: showTriageInput)` to set `triageInputFocused = newValue`, driving keyboard presentation/dismissal in sync with the input's visibility

No open questions.
