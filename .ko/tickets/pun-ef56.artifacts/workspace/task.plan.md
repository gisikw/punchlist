Perfect! I've created a plan to make the in_progress animation more noticeable. The plan focuses on:

1. **Increasing shadow opacity contrast** (from 0.06-0.18 to 0.03-0.28) to make the glow more dramatic
2. **Increasing circle fill opacity contrast** (from 0.1-0.25 to 0.15-0.4) to make the breathing dot more obvious
3. **Adding a subtle scale animation** to the circle (1.0 to 1.08) to create a gentle growing/shrinking effect

The approach respects the constraint from the previous fix (pun-36ad) that prevents changing shadow radius to avoid scroll oscillation. It keeps the 2-second easeInOut animation for a calm breathing quality while making it much more visually prominent.

The plan is ready for review at `.ko/tickets/pun-ef56.artifacts/plan.md`.
