# Personal Workflow Principles

These principles apply to ALL my projects.

## Golden Rules

1. **Fresh context per major task** - Proactively suggest `/compact` or new session after completing phases or at ~60% context usage
2. **Discuss before plan** - Clarify requirements and approach before diving into implementation
3. **Plan before execute** - For non-trivial tasks, outline the approach first
4. **Verify before moving on** - Review outputs together before marking phases complete
5. **Document state changes** - Update `docs/STATE.md` (or equivalent) after significant work
6. **Atomic commits** - One logical change per commit, clear commit messages

## Context Management

- At approximately 100,000 output tokens, proactively suggest `/compact` with a brief summary of what was accomplished
- The `PreCompact` hook automatically captures session state to `docs/STATE.md` before compaction — no need to manually document state before compacting
- On session start, the `SessionStart` hook injects STATE.md content as context for continuity
- Use subagents/Task tool for heavy research to preserve main context
- After major task completion, suggest starting fresh if context is heavy

## Session Discipline

When starting a session:
1. Check for `docs/STATE.md` or similar state file
2. Read it to understand current position
3. Confirm understanding before proceeding

When ending or pausing:
1. Summarize what was accomplished
2. Update state documentation
3. Note any blockers or open questions

## Project Structure Expectation

Every project should ideally have:
- `CLAUDE.md` (root) - Project-specific instructions and domain knowledge
- `docs/STATE.md` - Current position, recent decisions, session handoff
- `docs/ROADMAP.md` - Phase overview and progress

## Code Standards

- Type hints in Python (PEP 484)
- Docstrings for public functions (NumPy style)
- No hardcoded secrets - use environment variables
- Prefer editing existing files over creating new ones
- Use `logging` module, not print statements

## Tools & Preferences

- Use `uv` over pip when available
- Use `rg` (ripgrep) for searching
- Use `gh` CLI for GitHub operations
- Prefer pytest with `-xvs` for debugging tests

## Communication Style

- Lead with insights, not methodology
- Quantify uncertainty in findings
- Connect technical work to business impact
- Ask clarifying questions early rather than assuming
