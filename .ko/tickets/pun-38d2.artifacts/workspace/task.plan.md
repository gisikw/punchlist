Perfect! I've created the plan. The implementation is straightforward:

## Summary

The plan extends the existing breathing animation to the entire card by making the blue border stroke pulse in sync with the shadow. Currently:
- The shadow already pulses (opacity 0.03 → 0.28)
- The circle indicator already pulses (fill opacity and scale)
- The border stroke is static at 0.3 opacity

The fix animates the border stroke opacity using the same `pulseActive` state, creating a unified breathing glow around the entire card that syncs with the existing animations.

This is a minimal change (one line modification) that leverages the existing animation infrastructure and respects the constraint from pun-36ad (no layout-affecting changes, only opacity animation).
