Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
```json
{"disposition": "continue"}
```

The plan is complete and actionable:

- **Goal** is clear: evenly distribute the three circle actions
- **Context** provides specific file location and line number (`ItemRow.swift:367–411`, task at line 375)
- **Approach** is concrete: replace fixed spacing with `spacing: 0` and add `Spacer()` views
- **Verification** is testable: build succeeds, buttons spread across width in simulator
- **Open Questions**: none—the ticket is unambiguous

All prerequisites for implementation are met.
