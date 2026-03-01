Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Plan written to `.ko/tickets/pun-c13f.artifacts/plan.md`.

**Summary:** The bug is in `ItemRow.swift:332–344`. The `if item.done || isResolved` branch runs before the `else if hasTriage` branch, so a done ticket with triage shows the green checkmark instead of the grey circle. The fix is a one-block swap — check `hasTriage` first, then fall through to done/resolved. No open questions.
