Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
All checks pass:
- **Plan compliance**: The one remaining task (verify service absent on ratched) was completed.
- **Deviations**: None. The forge mirror note is pre-documented in the plan itself.
- **Correctness**: Remote verification confirmed no punchlist systemd units on ratched.
- **Tests**: All passing (ProjectDecoding, ItemRow, PollingFallback, Filtering, PlanQuestion suites).
- **Scope**: No unrelated changes; only `.ko/` workspace files modified.

```json
{"disposition": "continue"}
```
