---
id: pun-eb19
status: closed
deps: []
created: 2026-02-26T05:36:56Z
type: task
priority: 2
plan-questions:
  - id: q1
    question: "Should we add a timeout to automatically clear pending additions if the SSE update doesn't arrive within a certain duration?"
    context: "The plan assumes SSE is reliable and will deliver updates after a REST mutation succeeds. Without a timeout, tickets could remain permanently visible if the SSE stream breaks after creation. A timeout would act as a safety valve but adds implementation complexity."
    options:
      - label: "Add timeout (Recommended)"
        value: with_timeout
        description: "Clear pending additions after 10 seconds; ensures tickets don't stay pinned if SSE fails"
      - label: "No timeout"
        value: no_timeout
        description: "Assume SSE reliability; simpler implementation, bet on server stability"
---
# There's still an issue where after ticket create in a project, the ticket immediately shows up, then a few seconds later, disappears. If I close the app, or switch projects, the ticket shows up just fine
