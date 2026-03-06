## Summary

Changed the inner `HStack` in `circleActionsOverlay` from `HStack(spacing: 20)` to `HStack(spacing: 0)` and added `Spacer()` at the leading edge, between each of the three buttons, and at the trailing edge. This distributes the comment, block/unblock, and complete buttons evenly across the full available row width, reducing mistap risk.

No architectural decisions required — the approach was unambiguous. No tests exist in this codebase. Scope was tightly contained to a single layout change in `ItemRow.swift`.
