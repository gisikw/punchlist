---
id: pun-f4a1
status: open
deps: [pun-658f]
created: 2026-02-24T14:59:15Z
type: task
priority: 2
---
# Render plan_questions UI for blocked tickets (hardcoded data)

When a ticket is blocked and expanded (via pun-658f), show a human review UI
below the ticket description. This is the visual layer only — hardcoded
question data, no backend wiring.

## Design
- Below the ticket description, render a horizontal rule
- For each question: show the question text, optional context paragraph, and
  a row of option buttons (pill-shaped, tappable)
- Selected options should get a distinct visual treatment (filled vs outlined)
- Below all questions, include a freeform text input for additional context
- Use the structure from example.json as the data shape:
  `{question, context, options: [{label, value, description}]}`
- Hardcode the same questions for every blocked ticket for now

## Visual direction
- Minimal, consistent with punchlist's existing aesthetic
- Questions should feel lightweight, not form-like
- Option buttons should be small pills, not full-width
- The pink blocked accent color should carry through subtly

## Not in scope
- Fetching real question data from the server
- Submitting answers (pun-e67b)
