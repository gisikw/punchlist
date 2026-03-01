Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Plan written to `.ko/tickets/pun-7b22.artifacts/plan.md`.

**Summary:** The fix is a one-line change to `hasUnblockedTickets` in `PunchlistViewModel.swift`. Currently it excludes all blocked tickets; it should also return `true` for blocked tickets that have a `triage` value (meaning a human has given the agent guidance to proceed). Resolved tickets still stay excluded, even if triaged. A new test in `FilteringTests.swift` will cover the triage cases.
