Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
```json
{"disposition": "route", "workflow": "task"}
```

This ticket describes a specific, clear code change: remove color/tint styling from the clear button in InputBar. The expected output is committed code. The notes indicate the fix is straightforward (applying `.buttonStyle(.plain)` to the button), though they also flag that a previous attempt introduced unrelated regressions—those will need to be addressed during implementation by respecting the INVARIANTS.md constraints.
