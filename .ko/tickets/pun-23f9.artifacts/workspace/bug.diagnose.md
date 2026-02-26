## Summary

I've diagnosed the bug where the projects drawer occasionally shows an empty list. 

**Root Cause**: The projects list is fetched once during app startup via an async API call. If this call fails (due to network timeout, server error, or JSON decoding issue), the error is silently swallowed by the `try?` operator, leaving the `projects` array empty. Additionally, the `refresh()` method that runs when the app returns to the foreground only re-fetches items, not projects, so there's no recovery mechanism.

**Key Findings**:
- Silent failure in `PunchlistViewModel.swift:51-58` using `try? await api.fetchProjects()`
- No retry logic or error handling
- Projects are never re-fetched on app resume
- Race conditions with SSE connection could exacerbate timing issues

**Recommended Fixes**:
1. Add retry logic (2-3 attempts with exponential backoff) to the initial project fetch
2. Re-fetch projects in the `refresh()` method
3. Consider providing a fallback default "user" project
4. Replace silent `try?` with explicit error handling for debugging

The diagnosis has been written to `.ko/tickets/pun-23f9.artifacts/diagnosis.md` with full details on symptoms, root cause, affected code, recommended fixes, and risk assessment.
