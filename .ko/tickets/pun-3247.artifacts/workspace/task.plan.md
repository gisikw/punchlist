I've written the implementation plan to `/home/dev/Projects/punchlist/.ko/tickets/pun-3247.artifacts/plan.md`.

## Summary

The plan addresses the requirement to show tickets completed during an agent run with a reviewable indicator. Key approach:

1. **Track agent session start** — Store timestamp when agent starts
2. **Filter completed tickets by session** — Use backend's `modified` timestamp to show only tickets completed after agent start
3. **Visual transition** — Replace agent slider with green completion circle when agent stops
4. **Toggle review mode** — Tapping circle shows/hides session-completed tickets

The plan identifies 6 implementation tasks across the Item model, ViewModel, and View layers, with verification steps for each. I've flagged 4 open questions about timestamp handling, visual design, persistence behavior, and multi-session edge cases for your input.
