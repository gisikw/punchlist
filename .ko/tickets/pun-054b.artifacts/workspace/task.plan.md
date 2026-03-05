Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Plan written to `.ko/tickets/pun-054b.artifacts/plan.md`.

**Summary:** Tap the circle on a collapsed project card → `showCircleActions` flips true → text label hides, three icon buttons appear in its place via a new `circleActionsOverlay`. Tapping circle again (or any button) dismisses. The broken hold gesture on the circle zone is replaced with a simple tap.

**Two open questions flagged:**
1. Should the block button appear on non-blocked items (closing them), or only show as "unblock" when already blocked?
2. Should the triage button be hidden when a triage note already exists?
