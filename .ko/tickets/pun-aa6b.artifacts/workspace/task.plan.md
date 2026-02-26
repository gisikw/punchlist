The plan is complete. I've investigated the codebase and identified that there are actually two separate 3-second thresholds:

1. **SSEManager's disconnect debounce** (line 120) — delays marking the connection as offline after SSE drops, to avoid flicker from brief network interruptions
2. **ViewModel's startup threshold** (line 13) — prevents showing the offline indicator during initial cold-start latency

The ticket mentions "frequently appear and disappear around minor network flakiness," which points to the SSEManager's disconnect timer being the primary culprit. The plan proposes changing that to 1.5 seconds, which will reduce the debounce time and make the offline indicator appear faster after disconnects.

I've flagged an open question about whether the ViewModel's cold-start threshold should also be reduced, since the ticket says "not just in startup" but the SSEManager change would address the main issue described. This gives the implementer the context to make an informed decision or ask for clarification.
