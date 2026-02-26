---
id: pun-aa6b
status: closed
deps: []
created: 2026-02-26T17:19:41Z
type: task
priority: 2
---
# Can we add a general 1.5s threshold on offline, not just in startup? I see it frequently appear and disappear around minor network flakiness

## Notes

**2026-02-26 19:09:07 UTC:** Question: Should the ViewModel's cold-start threshold also be reduced to 1.5 seconds, or should it remain at 3 seconds?
Answer: Nope, these are different things. Startup, let's give 3s of connectivity grace. Intermittent, 1.5s. So, both things

**2026-02-26 19:15:15 UTC:** # Implementation Summary

## What Was Done

Successfully reduced the SSE disconnect debounce threshold from 3 seconds to 1.5 seconds to fix frequent offline indicator flickering during minor network interruptions.

### Changes Made

1. **SSEManager.swift:120** — Changed `Task.sleep(for: .seconds(3))` to `Task.sleep(for: .seconds(1.5))` in the offline timer
2. **SSEManager.swift:123** — Updated log message from `"offline (3s elapsed)"` to `"offline (1.5s elapsed)"`
3. **INVARIANTS.md:64** — Updated documentation from "shown after 3s of disconnect" to "shown after 1.5s of disconnect"
4. **PollingFallbackTests.swift:17,30** — Updated test documentation comments referencing the timing from 3 seconds to 1.5 seconds

### Key Architectural Decision

The implementation correctly distinguishes between **two separate timing thresholds** with different purposes:

- **SSEManager disconnect debounce (changed to 1.5s)**: Prevents the offline indicator from flickering during brief network interruptions after SSE has dropped. This is what the ticket requested.
- **ViewModel cold-start threshold (kept at 3s)**: Provides grace period during initial app launch before showing offline indicator, allowing time for slower initial network setup.

This distinction was confirmed with the ticket author: *"Startup, let's give 3s of connectivity grace. Intermittent, 1.5s."*

## Notable Decisions

- **No ViewModel changes**: The `PunchlistViewModel.swift` line 13 threshold remains at 3 seconds as intended
- **Test updates**: Only updated documentation comments in test files, not actual test assertions (no tests were asserting specific timing)

## Verification

- ✅ Build succeeded with `just check`
- ✅ All tests passed (23 test cases)
- ✅ All four planned tasks completed exactly as specified
- ✅ No deviations from plan
- ✅ INVARIANTS.md updated to match implementation

## Impact

The offline indicator will now appear after 1.5 seconds of SSE disconnect instead of 3 seconds, reducing the perceived lag when detecting actual network issues while still avoiding flicker on very brief interruptions.

**2026-02-26 19:15:15 UTC:** ko: SUCCEED
