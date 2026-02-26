---
id: pun-96d3
status: blocked
deps: []
created: 2026-02-26T15:32:35Z
type: task
priority: 2
plan-questions:
  - id: q1
    question: "Should the test suite be executable on remote build hosts via justfile, or is local test execution sufficient?"
    context: "The project uses remote macOS builds via SSH per INVARIANTS.md. The justfile currently has build/distribute commands but no test command."
    options:
      - label: "Add remote test execution (Recommended)"
        value: remote_test_command
        description: "Create a `just test` command that executes tests on the remote build host, matching the CI workflow"
      - label: "Local testing only"
        value: local_testing
        description: "Keep tests local for development; CI can run tests separately if needed"
  - id: q2
    question: "How should the private `filtered()` method in PunchlistViewModel be tested?"
    context: "The filtering logic is critical but currently private. Testing it requires choosing between exposing internals or testing indirectly."
    options:
      - label: "Use @testable import (Recommended)"
        value: testable_import
        description: "Make method internal and use @testable import Punchlist in tests; simplest and follows Swift conventions"
      - label: "Test through ViewModel public API"
        value: indirect_testing
        description: "Set up ViewModel state and verify the items array without directly calling filtered()"
      - label: "Extract to pure function"
        value: pure_function
        description: "Move filtering logic to a standalone testable function separate from ViewModel"
---
# Add XCTest target and test pure model decoding (Item, PlanQuestion, filtering)
