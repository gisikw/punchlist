---
id: pun-aa6b
status: blocked
deps: []
created: 2026-02-26T17:19:41Z
type: task
priority: 2
plan-questions:
  - id: q1
    question: "Should the ViewModel's cold-start threshold also be reduced to 1.5 seconds, or should it remain at 3 seconds?"
    context: "The plan proposes reducing SSEManager's disconnect debounce from 3s to 1.5s to fix frequent offline indicator flicker during network flakiness. The ViewModel has a separate 3-second cold-start threshold that delays showing the offline indicator during initial app launch. The ticket says 'not just in startup', which could suggest both thresholds should change, but the plan notes that the SSEManager change addresses the actual 'frequently appear and disappear' flakiness issue."
    options:
      - label: "Only change SSEManager (Recommended)"
        value: ssemanager_only
        description: "Reduce SSEManager's disconnect debounce to 1.5s to fix flakiness; keep ViewModel's cold-start threshold at 3s for stability during slow initial connections"
      - label: "Change both thresholds to 1.5s"
        value: both_to_1_5
        description: "Reduce both SSEManager and ViewModel thresholds to 1.5s for consistency across all scenarios"
      - label: "Use different values"
        value: different_values
        description: "Use 1.5s for SSEManager flakiness debounce and a different value (e.g., 2s) for ViewModel's cold-start threshold"
---
# Can we add a general 1.5s threshold on offline, not just in startup? I see it frequently appear and disappear around minor network flakiness
