---
id: pun-ed88
status: blocked
deps: [pun-7201]
created: 2026-02-25T23:49:01Z
type: task
priority: 2
plan-questions:
  - id: q1
    question: "Should we continue mirroring punchlist-server to GitHub, or stop the mirror in the forge config?"
    context: "The cluster manifest defines punchlist-server with a GitHub mirror. Removing it from forge stops mirroring but leaves the GitHub repo intact. To mark it as archived on GitHub requires separate action."
    options:
      - label: "Remove from forge config (Recommended)"
        value: remove_mirror
        description: "Stop mirroring to GitHub; the GitHub repo remains but will be out of sync"
      - label: "Keep mirroring active"
        value: keep_mirror
        description: "Leave the forge config unchanged; punchlist-server continues to mirror to GitHub"
  - id: q2
    question: "After archiving punchlist-server locally, should we delete the directory or keep it?"
    context: "The plan archives the repo with a deprecation README and tag, but leaves it at /home/dev/Projects/punchlist-server/. You can delete it entirely or move it elsewhere after archiving."
    options:
      - label: "Keep the directory (Recommended)"
        value: keep_directory
        description: "Preserves the local repo history and archive tag for future reference"
      - label: "Delete the directory"
        value: delete_directory
        description: "Removes the punchlist-server directory entirely to clean up the projects folder"
---
# Decommission punchlist-server

Once the iOS client talks directly to ko serve, punchlist-server is dead code.

- Stop and disable the punchlist systemd unit on ratched
- Archive or delete the punchlist-server repo
- Remove any DNS / reverse proxy pointing at punch.gisi.network
  (or redirect to knockout.gisi.network)
- Update Punchlist API Surface doc in exocortex notes
