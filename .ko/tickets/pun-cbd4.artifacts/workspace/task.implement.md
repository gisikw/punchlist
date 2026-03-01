Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Type-check passes (only a pre-existing warning, no errors).

**Summary of changes made:**

**Task 1 — ZStack reorder (`ItemRow.swift:332–348`):** Moved the `strokeBorder` Circle to the end of the ZStack so it renders on top of all fill layers. The glow background stays first, fills (done/triage) come next, and the stroke is drawn last — ensuring the blue in-progress ring is always visible over the triage grey disc.

**Task 2 — Lighten triage fill (`ItemRow.swift:342`):** Changed `.fill(Color.punchGray)` to `.fill(Color.punchGray.opacity(0.45))` so the triage indicator reads as a light grey disc rather than solid mid-grey.

No deviations from the plan.
