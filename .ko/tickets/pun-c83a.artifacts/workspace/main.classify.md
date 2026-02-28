Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Looking at this ticket:

**"Triage visual treatment: if a ticket has a triage value, render the status circle as filled grey. Tickets with triage should not be eligible for additional triage (don't open the text input on tap)."**

This is describing **what to build**: specific UI and behavioral changes to implement. It has a clear expected output—committed code that:
1. Changes the status circle appearance when a ticket has a triage value
2. Disables the triage text input behavior for triaged tickets

This is straightforward feature implementation with no ambiguity about what needs to be done.

```json
{"disposition": "route", "workflow": "task"}
```
