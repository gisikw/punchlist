Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Build succeeded. 

**Summary:** Changed `HStack(spacing: 20)` to `HStack(spacing: 0)` and added `Spacer()` between and around all three buttons in `circleActionsOverlay` (ItemRow.swift:375). This distributes the comment, block/unblock, and complete buttons evenly across the full available row width instead of clustering them together.
