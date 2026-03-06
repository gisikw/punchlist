Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Plan written. The fix is a one-liner in `ItemRow.swift:375`: change `HStack(spacing: 20)` to `HStack(spacing: 0)` and add `Spacer()` between the three buttons so they distribute evenly across the available row width.
