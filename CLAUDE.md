# Personal Workflow Principles

These principles apply to ALL my projects.

## Golden Rules

1. **Fresh context per major task** - Suggest `/compact` or new session at safe checkpoints (see workflow.md)
2. **Discuss before plan** - Clarify requirements and approach before diving into implementation
3. **Plan before execute** - For non-trivial tasks, outline the approach first
4. **Verify before moving on** - Review outputs together before marking phases complete
5. **Document state changes** - Update `docs/STATE.md` (or equivalent) after significant work
6. **Atomic commits** - One logical change per commit, clear commit messages

## Context Management

- PreCompact hook auto-saves STATE.md — compaction is always safe
- Use subagents for heavy research to preserve main context

## Project Structure Expectation

Every project should ideally have:
- `CLAUDE.md` (root) - Project-specific instructions and domain knowledge
- `docs/STATE.md` - Current position, recent decisions, session handoff
- `docs/ROADMAP.md` - Phase overview and progress

## Reasoning Effort

- Default effort level should be HIGH. If you notice a task requires deep multi-step reasoning, architecture decisions, debugging, or complex code changes — say so and remind the user to use `ultrathink` in their prompt or switch effort via `/model`.
- For trivial tasks (file reads, simple edits, quick lookups), adaptive thinking will naturally scale down — no action needed.
- When uncertain about complexity, err on the side of deeper reasoning.

## Superpowers Skills — MANDATORY

You have superpowers skills installed. **You MUST invoke relevant skills before responding.** This is not optional.

- **Any feature/change/build request** → invoke `brainstorming` FIRST, then `writing-plans`
- **Any bug/test failure/unexpected behavior** → invoke `systematic-debugging` FIRST
- **Any implementation from a plan** → invoke `executing-plans` or `subagent-driven-development`
- **Before claiming work is done** → invoke `verification-before-completion`
- **After completing a feature** → invoke `finishing-a-development-branch`

Do NOT rationalize skipping skills. "This is simple" is not an excuse. Invoke the skill; if it turns out unnecessary, you'll know in seconds.

## Planning → Execution Workflow

When a task requires planning (most non-trivial tasks):
1. Invoke `brainstorming` → design doc
2. Invoke `writing-plans` → implementation plan with bite-sized tasks
3. Present the user with execution options:
   - **Option A (Recommended for complex work):** `/compact` + fresh session with plan as context + auto-accept edits. This gives the implementer clean context.
   - **Option B:** Subagent-driven development in current session
   - **Option C:** Manual step-by-step in current session
4. Always recommend Option A for plans with 5+ tasks.

## Communication Style

- Lead with insights, not methodology
- Quantify uncertainty in findings
- Connect technical work to business impact
- Ask clarifying questions early rather than assuming
