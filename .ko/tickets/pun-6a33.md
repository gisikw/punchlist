---
id: pun-6a33
status: closed
deps: []
created: 2026-02-25T23:48:05Z
type: task
priority: 1
---
# Replace punchlist-server with ko HTTP API: KoAPI client layer

New Swift service (KoAPI) that talks to `knockout.gisi.network` instead of
`punch.gisi.network`. Replaces PunchlistAPI entirely.

Base URL: `https://knockout.gisi.network`

## Endpoint mapping

All commands go through `POST /ko` with `{"argv": [...]}`.

| Operation | argv |
|-----------|------|
| List projects | `["project","ls","--json"]` |
| List items | `["ls","--project=#slug","--json"]` |
| Add item | `["add","--project=#slug","title"]` |
| Close item | `["close","id"]` |
| Reopen item | `["open","id"]` |
| Bump item | `["bump","id"]` |
| Get questions | `["triage","id","--json"]` |
| Submit answers | `["triage","id","--answers","json"]` |
| Agent status | `["agent","status","--project=#slug"]` |
| Agent start | `["agent","start","--project=#slug"]` |
| Agent stop | `["agent","stop","--project=#slug"]` |

## Notes

- All commands with `--json` return structured JSON
- Toggle (done/undone) needs to know current status to pick close vs open
- `ko add` returns the new ticket ID; we need to parse that
- `--project` flag may not be needed for ticket-specific commands (close, open, bump)
  since ticket IDs are globally unique with prefixes
