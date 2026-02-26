The plan is complete and ready for review at `.ko/tickets/pun-593f.artifacts/plan.md`.

## Summary

The issue is straightforward: `hasUnblockedTickets` currently only excludes "blocked" and "done" tickets, but "resolved" tickets are also not agent-actionable (they're marked as done but need human review). 

The fix requires:
1. Adding `&& $0.status != "resolved"` to the `hasUnblockedTickets` check in PunchlistViewModel.swift
2. Adding tests to verify resolved tickets are excluded and in_progress tickets are included

This ensures the agent toggle hides when only non-actionable tickets (blocked, resolved, or done) remain in the project.
