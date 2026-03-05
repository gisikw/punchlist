---
id: pun-054b
status: blocked
deps: []
created: 2026-03-05T12:44:32Z
type: task
priority: 2
plan-questions:
  - id: q1
    question: "When an item is NOT blocked, should the block/unblock button always show the block action, or should the button only appear when the item is already blocked?"
    context: "The circle actions overlay will have a lock icon button. Currently the plan assumes this button always shows and toggles between block (lock.fill) and unblock (lock.open.fill) based on item state. The alternative is to only show the button/action when the item is already blocked (unblock only)."
    options:
      - label: "Always show block/unblock (Recommended)"
        value: always_show
        description: "Block button appears for open items, unblock for blocked items; user can block from the actions panel"
      - label: "Only show when blocked"
        value: blocked_only
        description: "Button only appears for blocked items as an unblock action; non-blocked items cannot be blocked from here"
  - id: q2
    question: "Should the triage/comment button be hidden when the item already has a triage note, or always show it?"
    context: "The plan currently shows the comment button (bubble.left) unconditionally. The question is whether it should match the existing behavior where triage is only offered when no triage note exists yet, or allow adding multiple notes."
    options:
      - label: "Always show triage button"
        value: always_show
        description: "Comment button always visible; allows adding multiple triage notes"
      - label: "Hide when hasTriage is true"
        value: hide_when_present
        description: "Only show comment button when item has no triage note yet; prevents adding multiple notes"
---
# The long press on circle project view isn't working. Let's try this: for a collapsed card in project view, tapping the circle hides the labels on the card and replaces them with nice tap target actions. SVG iconography. Have a comment icon which triggers the triage step, a block or unblock button, and a complete button
