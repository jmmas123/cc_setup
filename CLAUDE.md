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

## Communication Style

- Lead with insights, not methodology
- Quantify uncertainty in findings
- Connect technical work to business impact
- Ask clarifying questions early rather than assuming
