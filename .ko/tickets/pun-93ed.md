---
id: pun-93ed
status: blocked
deps: []
created: 2026-02-26T17:29:12Z
type: task
priority: 2
plan-questions:
  - id: q1
    question: "When a ticket collapses, should we scroll to the collapsed item or to the bottom of the list?"
    context: "The plan identifies two approaches: (1) scrolling to the collapsed item keeps it visible and stable, (2) scrolling to the bottom maintains the bottom-anchored scroll behavior. The plan recommends scrolling to the collapsed item with `.bottom` anchor."
    options:
      - label: "Scroll to collapsed item (Recommended)"
        value: scroll_to_item
        description: "Keeps the collapsed item visible and centered, allowing the container to resize properly"
      - label: "Scroll to bottom of list"
        value: scroll_to_bottom
        description: "Maintains the bottom-anchored scroll philosophy, but may feel jarring if the item was in the middle of the viewport"
---
# If there's a large ticket expanded, on collapse the tickets can seemingly disappear because the container doesn't shrink. Scrolling eventually recovers them. But can we nudge the container to resize on item card close maybe?
