Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
**Summary of findings:**

The bug is a simple `if / else if` ordering issue in `ItemRow.swift:332–344`.

The `circle` computed property checks `item.done || isResolved` **before** `hasTriage`. When a ticket is both done and has a triage value, the green fill + checkmark renders and the grey triage fill branch is never reached. The same ordering problem exists in `circleColor` (line 314), which would also return green for the stroke border instead of grey.

**Fix:** Swap the branch order so `hasTriage` is checked first in both `circle` and `circleColor`. Low-risk, fully localised change.
