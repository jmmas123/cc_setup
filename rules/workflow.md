# Workflow Rules (Auto-Loaded)

## Session Start Protocol

When beginning any session:
1. Look for state files: `docs/STATE.md`, `STATE.md`, or similar
2. If found, read to understand current project position
3. Briefly confirm understanding with user before proceeding
4. Check for any noted blockers or open questions

## During Work

### Context Awareness
- Monitor context usage mentally
- At heavy context (~60%+), proactively mention:
  > "We've covered a lot. Want to `/compact` or start fresh before the next task?"
- Use Task tool with subagents for research-heavy work to preserve main context

### State Documentation
After completing significant work:
1. Summarize what was accomplished
2. Offer to update state documentation
3. Note any decisions made and their rationale

### Phase Transitions
When completing a project phase:
1. Verify all deliverables are complete
2. Update state/roadmap documentation
3. Suggest fresh session for next phase

## Session End Protocol

Before ending or when user indicates they're done:
1. Summarize session accomplishments
2. Update `docs/STATE.md` with:
   - Current position
   - What was completed
   - Next steps
   - Any open questions
3. Ensure any important context is preserved in documentation

## Quality Checks

Before marking work complete, verify:
- [ ] Code runs without errors
- [ ] Changes are logically atomic (one concern per commit)
- [ ] Documentation reflects current state
- [ ] No sensitive data exposed
