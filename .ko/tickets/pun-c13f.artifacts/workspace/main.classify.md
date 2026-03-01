Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Looking at this ticket:

**"Triage indicator should take precedence over all others - right now the "done" indicator supersedes the triage grey circle"**

This is asserting unexpected behavior: the display priority/layering is wrong. The triage indicator should render on top but currently the "done" indicator is taking precedence instead.

This is reporting a problem with the current implementation and needs investigation into the UI rendering code to identify where the indicator layering/display order is determined and fix it accordingly.

```json
{"disposition": "route", "workflow": "bug"}
```
