Plan written to `/home/dev/Projects/punchlist/.ko/tickets/pun-36ad.artifacts/plan.md`.

The fix is straightforward: the scroll is oscillating because the pulse animation on in_progress items changes the shadow radius between 4 and 8 points, which causes layout recalculation. Combined with the bottom-anchored ScrollView, this creates a feedback loop.

The solution is to reserve fixed space for the maximum shadow (8pt) and animate only the opacity, not the radius. This gives the same visual pulse effect without triggering layout changes.
