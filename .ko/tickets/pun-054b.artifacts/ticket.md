---
id: pun-054b
status: open
deps: []
created: 2026-03-05T12:44:32Z
type: task
priority: 2
---
# The long press on circle project view isn't working. Let's try this: for a collapsed card in project view, tapping the circle hides the labels on the card and replaces them with nice tap target actions. SVG iconography. Have a comment icon which triggers the triage step, a block or unblock button, and a complete button

## Notes

**2026-03-05 14:21:04 UTC:** Question: Should the triage/comment button be hidden when the item already has a triage note, or always show it?
Answer: Always show triage button
Comment button always visible; allows adding multiple triage notes

**2026-03-05 14:21:04 UTC:** Question: When an item is NOT blocked, should the block/unblock button always show the block action, or should the button only appear when the item is already blocked?
Answer: If the item is not blocked, we wanna let the user block it. "Don't do this yet", effectively. If the ticket _is_ blocked, we want to let them reopen it
