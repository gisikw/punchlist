The plan has been written to `/home/dev/Projects/punchlist/.ko/tickets/pun-23f9.artifacts/plan.md`. 

## Summary

I've created an implementation plan to fix the empty projects drawer issue. The diagnosis shows the root cause is silent failure of the initial project fetch, with no retry mechanism or recovery on app resume.

The plan includes 4 tasks:
1. Add immediate fallback with a default "user" project to prevent empty UI
2. Replace silent error handling with retry logic (3 attempts with exponential backoff)
3. Re-fetch projects in the `refresh()` method when app resumes
4. Manual verification with airplane mode testing

The fix is straightforward and requires no architectural changes—just adding resilience to the existing fetch logic in `PunchlistViewModel.swift`.
