Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
All three plan tasks are fully implemented and correct:

1. `@FocusState private var triageInputFocused: Bool` added at line 18
2. `.focused($triageInputFocused)` attached to the triage `TextField` at line 86
3. `.onChange(of: showTriageInput) { _, newValue in triageInputFocused = newValue }` on the outer `VStack` at lines 153–155

The `newValue` assignment handles both directions — focus on show, defocus on dismiss — matching the plan's guidance. No deviations, no scope creep, no safety concerns.

```json
{"disposition": "continue"}
```
