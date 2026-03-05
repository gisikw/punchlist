Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
```json
{
  "disposition": "needs_input",
  "plan_questions": [
    {
      "id": "q1",
      "question": "When an item is NOT blocked, should the block/unblock button always show the block action, or should the button only appear when the item is already blocked?",
      "context": "The circle actions overlay will have a lock icon button. Currently the plan assumes this button always shows and toggles between block (lock.fill) and unblock (lock.open.fill) based on item state. The alternative is to only show the button/action when the item is already blocked (unblock only).",
      "options": [
        {
          "label": "Always show block/unblock (Recommended)",
          "value": "always_show",
          "description": "Block button appears for open items, unblock for blocked items; user can block from the actions panel"
        },
        {
          "label": "Only show when blocked",
          "value": "blocked_only",
          "description": "Button only appears for blocked items as an unblock action; non-blocked items cannot be blocked from here"
        }
      ]
    },
    {
      "id": "q2",
      "question": "Should the triage/comment button be hidden when the item already has a triage note, or always show it?",
      "context": "The plan currently shows the comment button (bubble.left) unconditionally. The question is whether it should match the existing behavior where triage is only offered when no triage note exists yet, or allow adding multiple notes.",
      "options": [
        {
          "label": "Always show triage button",
          "value": "always_show",
          "description": "Comment button always visible; allows adding multiple triage notes"
        },
        {
          "label": "Hide when hasTriage is true",
          "value": "hide_when_present",
          "description": "Only show comment button when item has no triage note yet; prevents adding multiple notes"
        }
      ]
    }
  ]
}
```
