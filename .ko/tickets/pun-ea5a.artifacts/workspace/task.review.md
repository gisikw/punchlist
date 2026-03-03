Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
The implementation is solid. All three plan tasks were completed correctly:

1. **Background green fill** — rendered inside `.clipShape` so it respects rounded corners, conditioned on `!isExpanded && !isPersonal && holdProgress > 0`.
2. **`collapsedProjectHoldOverlay`** — faithful port of `holdToCloseBar` logic with quick-tap zone routing (44px left, 80% right, center) matching `tapOverlay` exactly.
3. **Overlay routing** — clean `if/else` replacing `tapOverlay` for collapsed project cards.

No deviations, no invariant violations, no security issues, no scope creep.

```json
{"disposition": "continue"}
```
