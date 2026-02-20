---
id: pun-4e44
status: open
deps: [pun-a24c, pun-9934]
links: []
created: 2026-02-20T14:02:02Z
type: task
priority: 2
---
# Swipe navigation — horizontal swipe to switch between ko projects

## Notes

**2026-02-20 14:02:30 UTC:** SwiftUI TabView with .tabViewStyle(.page) or a custom horizontal paging ScrollView. Default to personal project (index 0). Each page is a full item list view connected to its project's endpoints. Consider: should non-personal projects be read-only (no input bar) or full CRUD? Probably full CRUD — you'd want to close tickets from the phone too.
