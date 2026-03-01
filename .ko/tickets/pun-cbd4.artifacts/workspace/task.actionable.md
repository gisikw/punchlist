Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
```json
{"disposition": "continue"}
```

The plan is **ready for implementation**:

✅ **No open questions** — The plan explicitly addresses the opacity value (0.45) as a reasonable starting point, noting it can be tuned later if needed.

✅ **Complete** — Clear goal, well-documented context with line number references, a sound approach (reorder ZStack layers + adjust opacity), and two specific, verifiable tasks with file locations and verification steps.

✅ **Feasible** — The ZStack rendering strategy is standard SwiftUI, the file locations (`ItemRow.swift`) and color references (`punchGray`) are plausible, and the technique (moving layers in a ZStack, adjusting opacity) is straightforward to implement.
