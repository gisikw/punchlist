---
id: pun-e67b
status: closed
deps: [pun-f4a1]
created: 2026-02-24T14:59:19Z
type: task
priority: 2
---
# Wire up plan_questions answers to backend (reopen ticket on last answer)

Connect the plan_questions UI (pun-f4a1) to the punchlist-server backend so
answers are persisted and tickets unblock automatically.

## Scope
- Server: new endpoint to fetch plan_questions for a ticket (reads from ko ticket notes or a sidecar file)
- Server: new endpoint to submit an answer for a question
- Server: when all questions for a ticket are answered, reopen the ticket so the
  agent can resume work with the human's guidance
- Client: fetch real question data when expanding a blocked ticket
- Client: submit answers on option tap, persist selection state
- Client: freeform text input submits as a note on the ticket
- Item model gains a `questions` field (or fetched on expand)

## Open questions
- Where do plan_questions live? ko ticket notes? A sidecar .json in .ko/tickets/?
- How does the agent read the answers? Note on the ticket? Structured field?
- Should answering trigger an immediate agent build, or just reopen for the next loop?
