Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
```json
{"disposition": "continue"}
```

The plan is complete and ready for implementation:

- **Goal** is clear: add a conditionally-visible clear button to the input
- **Context** correctly identifies that only `InputBar.swift` needs modification
- **Approach** is straightforward: wrap the `TextField` in an `HStack` with a conditional button
- **Tasks** include specific details (SF Symbol name, animation guidance) and clear verification steps
- **Open Questions**: None

The plan references standard SwiftUI patterns (conditional rendering, SF Symbols, animation) and is scoped to a single file with minimal risk of side effects.
