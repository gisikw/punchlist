Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
```json
{"disposition": "fail", "reason": "Implementation violated INVARIANTS.md: the 'Offline queue' invariant (mutations buffer locally and replay on reconnect) is explicitly documented, but the implementation removed the entire pendingQueue/drainQueue() system from PunchlistViewModel.swift. Additionally, the unrelated ticket pun-0597 was closed without explanation, and test documentation was updated to mask the regression. Only the InputBar.swift change (.buttonStyle(.plain)) was correct and in scope."}
```
