## Summary

I've completed the diagnosis of the disappearing tickets bug. Here's what I found:

**The Problem**: When a large expanded ticket (with description, plan questions, etc.) collapses, SwiftUI's ScrollView doesn't immediately shrink its content size, causing tickets to seemingly disappear until the user scrolls.

**Root Cause**: The issue is a layout synchronization problem between:
- The animated collapse of `ItemRow` (0.35s spring animation)
- `LazyVStack`'s lazy measurement behavior
- ScrollView's content size calculations not updating fast enough

When a ticket that might be 300-500pt tall collapses back to ~80pt, the LazyVStack doesn't immediately recalculate total content height, and the scroll position isn't adjusted, leaving the view "pointed" at content that's now off-screen.

**Recommended Fix**: Use the existing `ScrollViewReader` (already present but unused) to adjust scroll position during collapse. This would maintain visibility of content before/after the collapsed item.

**Risk Level**: Low to Medium - mainly need to test edge cases like collapsing the top item, collapsing while at bottom, and rapid successive collapses.

The full diagnosis with technical details, alternative solutions, and risk assessment has been written to the artifact directory.
