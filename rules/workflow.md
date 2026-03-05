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

## Session End Protocol

Before ending or when user indicates they're done:
1. Briefly summarize session accomplishments
2. Update `docs/STATE.md` with facts only (no reasoning or analysis):
   - Current position (branch, phase, what's running)
   - What changed (files modified, metrics observed, commits made)
   - User decisions (what they chose, in their words)
   - Pending actions (only what was explicitly agreed)
   - Blockers (with exact error messages if applicable)
3. Keep STATE.md under 40 lines — it's a handoff document, not a narrative

## Quality Checks

Before marking work complete, verify:
- [ ] Code runs without errors
- [ ] Changes are logically atomic (one concern per commit)
- [ ] Documentation reflects current state
- [ ] No sensitive data exposed
