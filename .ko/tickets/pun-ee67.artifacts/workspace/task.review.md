Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Implementation matches the plan exactly. The `TextField` is wrapped in an `HStack`, the clear button uses `xmark.circle.fill` and is conditionally shown with a plain `if !text.isEmpty`, the outer padding/background/shadow styling is correctly moved to the `HStack`, and submit behavior is unchanged. No invariant violations.

```json
{"disposition": "continue"}
```
