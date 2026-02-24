---
id: pun-658f
status: closed
deps: []
created: 2026-02-24T14:59:09Z
type: task
priority: 2
---
# Accordion expand ticket on circle tap to show description

Tapping the circle on the left side of a ticket row should accordion-expand it
to reveal the ticket description below the title. This is the foundation for
the human review workflow — before we can show plan_questions or any other
detail, we need the expand/collapse mechanic.

## Scope
- **Project view only.** In personal view the circles are checkboxes (toggle
  done) — that behavior must not change. The accordion expand is a project
  view feature.
- Make the circle a tap target that toggles an expanded state on the ItemRow
- When expanded, show the ticket description below the title text
- Animate the expand/collapse with a spring transition
- Only one ticket should be expanded at a time (tapping another collapses the current)
- The existing tap targets (toggle, bump) should remain on the non-circle area
- Item model needs a `description` field (server already has access via ko)

## Not in scope
- plan_questions rendering (pun-f4a1)
- Any backend changes for answering questions
