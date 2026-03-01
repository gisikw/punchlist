Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
Looking at this ticket, it describes specific decommissioning steps to take:

- Stop and disable a systemd unit
- Archive or delete a repository
- Remove/redirect DNS and reverse proxy
- Update documentation

This is clearly describing **what to do** with a specific expected output: committed code and configuration changes to remove the punchlist-server infrastructure.

```json
{"disposition": "route", "workflow": "task"}
```
