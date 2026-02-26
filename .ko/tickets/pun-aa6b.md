---
id: pun-aa6b
status: blocked
deps: []
created: 2026-02-26T17:19:41Z
type: task
priority: 2
plan-questions:
  - id: q1
    question: "Should the ViewModel's cold-start threshold also be reduced from 3 seconds to 1.5 seconds?"
    context: "The plan proposes changing SSEManager's disconnect debounce from 3 to 1.5 seconds to fix frequent offline indicator flicker. The ViewModel has a separate 3-second cold-start threshold that prevents showing offline during initial app launch. The ticket mentions 'not just in startup' which could suggest both thresholds should change."
    options:
      - label: "Only change SSEManager (Recommended)"
        value: ssemanager_only
        description: "Reduce SSEManager's debounce to 1.5s to fix flakiness, keep ViewModel's startup threshold at 3s for stability during slow initial connections"
      - label: "Change both thresholds"
        value: both_thresholds
        description: "Reduce both SSEManager's debounce and ViewModel's cold-start threshold to 1.5s for consistency"
      - label: "Different values"
        value: different_values
        description: "Use 1.5s for SSEManager flakiness debounce and a different value (e.g. 2s) for ViewModel's cold-start threshold"
---
# Can we add a general 1.5s threshold on offline, not just in startup? I see it frequently appear and disappear around minor network flakiness
