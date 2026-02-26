Plan written successfully. The plan covers:

1. **Goal**: Clear one-sentence summary of adding XCTest target and model/filtering tests
2. **Context**: Key findings about the project structure, model implementations with custom CodingKeys, filtering logic, and existing conventions from INVARIANTS.md
3. **Approach**: High-level strategy of adding a test target and writing pure decoding tests
4. **Tasks**: 5 ordered tasks with specific file references and verification steps:
   - Add XCTest target to project.pbxproj
   - Test Item decoding (including the derived `done` field)
   - Test PlanQuestion/PlanOption decoding
   - Test Project decoding
   - Test filtering logic
5. **Open Questions**: Two genuine architectural decisions:
   - Whether to add remote test execution to the justfile
   - How to handle testing the private `filtered()` method

Each task has a concrete verification step and the ordering implies dependencies (must add target before writing tests, must test models before testing logic that uses them).
