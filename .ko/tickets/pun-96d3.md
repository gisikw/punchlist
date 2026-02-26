---
id: pun-96d3
status: resolved
deps: []
created: 2026-02-26T15:32:35Z
type: task
priority: 2
---
# Add XCTest target and test pure model decoding (Item, PlanQuestion, filtering)

## Notes

**2026-02-26 15:38:28 UTC:** Question: How should the private `filtered()` method in PunchlistViewModel be tested?
Answer: Use @testable import (Recommended)
Make method internal and use @testable import Punchlist in tests; simplest and follows Swift conventions

**2026-02-26 15:38:28 UTC:** Question: Should the test suite be executable on remote build hosts via justfile, or is local test execution sufficient?
Answer: Add remote test execution (Recommended)
Create a `just test` command that executes tests on the remote build host, matching the CI workflow

**2026-02-26 15:52:46 UTC:** ko: SUCCEED
