Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Plan written. The change is self-contained to `InputBar.swift` — wrap the `TextField` in an `HStack`, add a trailing `xmark.circle.fill` button that clears `text` and is hidden when the field is empty. No architectural questions.
