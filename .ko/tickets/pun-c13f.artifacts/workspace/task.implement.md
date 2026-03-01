Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Type-check passes (only a pre-existing warning, no errors).

**Summary**

**Task 1** (`ItemRow.swift:332–344`): Swapped the conditional branches in the `circle` computed property. `hasTriage` is now checked first — a done ticket with a triage value will render the grey filled circle. The `item.done || isResolved` green checkmark branch is the `else if` fallback, so done tickets without triage still show the green checkmark.

No deviations from the plan.
