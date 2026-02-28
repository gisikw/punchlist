Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Build succeeded. 

**Task 1 complete** — Modified `Punchlist/Views/InputBar.swift`:
- Wrapped the `TextField` in an `HStack`
- Added a conditionally-rendered `Button` with `xmark.circle.fill` SF Symbol on the trailing side
- Button sets `text = ""` on tap and only renders when `text` is non-empty
- Moved `.padding(14)`, `.background`, `.clipShape`, and `.shadow` to the `HStack` outer container

No deviations from the plan.
