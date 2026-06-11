# Personal Workflow Principles

These principles apply to ALL my projects.

## Golden Rules

1. **Fresh context per major task** - Suggest `/compact` or new session at safe checkpoints (see workflow.md)
2. **Discuss before plan** - Clarify requirements and approach before diving into implementation
3. **Plan before execute** - For non-trivial tasks, outline the approach first
4. **Verify before moving on** - Review outputs together before marking phases complete
5. **Document state changes** - Update `docs/STATE.md` (or equivalent) after significant work
6. **Atomic commits** - One logical change per commit, clear commit messages
7. **Test libraries in the real project, not isolated demos** - When evaluating a new library or framework feature, integrate it into the existing project's dev server first rather than building an isolated CDN/file:// demo. Isolated demos invent failure modes (CORS, `file://` origin restrictions, esm.sh peer-dep resolution, dual-React-instance bugs) that obscure the library's actual behavior. A throwaway test route in the real project costs ~5 minutes; debugging a CDN demo failing for environmental reasons can cost 30+ minutes per iteration.

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

## Skills — MANDATORY

**Invoke relevant skills before responding.** This is not optional.

- **Any feature/change/build request** → invoke `claude-mem:make-plan` FIRST (covers both brainstorming and plan writing)
- **Any bug/test failure/unexpected behavior** → use `debugger` agent FIRST
- **Any implementation from a plan** → invoke `claude-mem:do`
- **Before claiming work is done** → invoke `review`
- **For production/safety-critical code (sentinel, auth, payment, infra)** → invoke `/strict-review` instead of `/review` — runs the strict reviewer + adversarial verification against NASA P10 / OWASP Top 10 / IEC 61508 / CERT spirit.
- **After completing a feature** → invoke `wrap-up`

Do NOT rationalize skipping skills. "This is simple" is not an excuse. Invoke the skill; if it turns out unnecessary, you'll know in seconds.

## Planning → Execution Workflow

When a task requires planning (most non-trivial tasks):
1. Invoke `claude-mem:make-plan` → design doc + implementation plan with bite-sized tasks
2. Present the user with execution options:
   - **Option A (Recommended for complex work):** `/compact` + fresh session with plan as context + auto-accept edits. This gives the implementer clean context.
   - **Option B:** Invoke `claude-mem:do` for subagent-driven execution in current session
   - **Option C:** Manual step-by-step in current session
3. Always recommend Option A for plans with 5+ tasks.

## Agent Types

When spawning agents, always use the full qualified `plugin:agent` name. Common ones:
- `code-simplifier:code-simplifier` (NOT `code-simplifier`)
- `feature-dev:code-reviewer` (NOT `code-reviewer` — that's a different standalone agent)
- `feature-dev:code-explorer`
- `feature-dev:code-architect`
- `code-reviewer-strict` — heavy, opus-based standalone agent; orchestrated by `/strict-review` slash command (do not invoke directly)

**Before spawning parallel agents, follow the coordination protocol in `agent-coordination.md`.** Key rules:
- Read-only agents → parallel freely
- Write agents → `isolation: "worktree"` when parallel, sequential when overlapping files
- Never spawn parallel writers without declaring file targets first

## Communication Style

- Lead with insights, not methodology
- Quantify uncertainty in findings
- Connect technical work to business impact
- Ask clarifying questions early rather than assuming
- When proposing copy for headings, taglines, eyebrows, or section labels in customer-facing materials, default to concrete artifacts (a service, a deliverable, a buyable thing) rather than abstract narrative concepts. If asked for a "standardized" set, propose at least one concrete-artifact variant alongside any abstract option, and flag which you recommend.
