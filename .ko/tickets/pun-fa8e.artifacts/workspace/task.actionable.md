Punchlist dev shell
  just --list  — available recipes
  just check   — type-check Swift
  just build   — simulator build
The plan is **complete and actionable**:

✅ **Open Questions**: None listed. The design intent is unambiguous.

✅ **Completeness**: 
- Clear goal: visual precedence of in-progress over triage (blue fill with grey outline)
- Detailed context: explains the ZStack layers and current behavior
- Specific files and line numbers: `ItemRow.swift` (337, 318)
- Two ordered tasks with verification steps for each

✅ **Feasibility**: 
- File `Punchlist/Views/ItemRow.swift` exists in the codebase
- Line references are specific and correspond to the `circle` property and `circleColor` logic
- Approach is straightforward conditional logic: skip grey fill when `hasTriage && !isInProgress`, and make border grey when both states active

```json
{"disposition": "continue"}
```
