---
id: pun-aa6b
status: open
deps: []
created: 2026-02-26T17:19:41Z
type: task
priority: 2
---
# Can we add a general 1.5s threshold on offline, not just in startup? I see it frequently appear and disappear around minor network flakiness

## Notes

**2026-02-26 19:09:07 UTC:** Question: Should the ViewModel's cold-start threshold also be reduced to 1.5 seconds, or should it remain at 3 seconds?
Answer: Nope, these are different things. Startup, let's give 3s of connectivity grace. Intermittent, 1.5s. So, both things
