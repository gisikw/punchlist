## Goal
Auto-focus the triage TextField when `showTriageInput` becomes true, so the keyboard appears immediately when the user taps the triage circle.

## Context
In `ItemRow.swift`, tapping the left 44pt zone (where the status circle lives) sets `showTriageInput.toggle()` (line 186). When `showTriageInput` is true, a `TextField("triage note...", text: $triageText)` is rendered inline (lines 81–107). Currently there is no focus management, so the keyboard does not appear automatically — the user must tap the field a second time.

`InputBar.swift` shows the project pattern: use a `FocusState<Bool>` var, attach `.focused($focusBinding)` to the `TextField`, and set the binding to `true` to trigger keyboard presentation.

## Approach
Add a `@FocusState private var triageInputFocused: Bool` to `ItemRow`. Attach `.focused($triageInputFocused)` to the triage `TextField`. Use `.onChange(of: showTriageInput)` on the enclosing `VStack` (or the field itself) to set `triageInputFocused = true` whenever `showTriageInput` transitions to `true`. Also clear focus (`triageInputFocused = false`) when `showTriageInput` becomes false, to avoid stale focus state.

## Tasks
1. [Punchlist/Views/ItemRow.swift] — Add `@FocusState private var triageInputFocused: Bool` alongside the existing `@State` declarations (after line 20).
   Verify: file compiles without errors.

2. [Punchlist/Views/ItemRow.swift:83] — Attach `.focused($triageInputFocused)` modifier to the triage `TextField` (after the existing `.font` modifier).
   Verify: file compiles without errors.

3. [Punchlist/Views/ItemRow.swift] — Add `.onChange(of: showTriageInput) { _, newValue in triageInputFocused = newValue }` on the outer `VStack` in `body` (or on the triage `TextField` block). This drives focus on and off in sync with the input's visibility.
   Verify: tapping the triage circle opens the keyboard immediately; tapping cancel or submitting dismisses the keyboard.

## Open Questions
None.
