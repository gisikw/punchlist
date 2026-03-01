Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
All three tasks are complete. Here's a summary:

**Task 1** — Added `@FocusState private var triageInputFocused: Bool` to `ItemRow` (line 18, before the other `@State` vars).

**Task 2** — Attached `.focused($triageInputFocused)` to the triage `TextField`, after the `.font(.system(size: 14))` modifier.

**Task 3** — Added `.onChange(of: showTriageInput) { _, newValue in triageInputFocused = newValue }` on the outer `VStack`, alongside the existing `hasPulse` onChange handler. This drives focus on/off in sync with the triage input's visibility.

No deviations from the plan. `just check` passed cleanly.
