# Workflow Rules (Auto-Loaded)

## Session Start Protocol

When beginning any session:
1. Look for state files: `docs/STATE.md`, `STATE.md`, or similar
2. If found, read to understand current project position
3. Briefly confirm understanding with user before proceeding
4. Check for any noted blockers or open questions

## During Work

### Compaction Checkpoints
Suggest `/compact` (or fresh session) at these safe boundaries — don't wait for context to feel heavy:

- **After a git commit** — work is saved, natural pause point
- **After completing a task or phase** — logical boundary, context from prior task is now pollution
- **After a topic switch** — old context becomes irrelevant noise
- **After heavy subagent research** — search results bloat context without ongoing value
- **After resolving a blocker** — debugging context is high-volume, low-reuse

When suggesting, be brief: `"Good checkpoint to /compact — state is saved."` Don't explain why unless asked.

### Context Preservation
- Use Task tool with subagents for research-heavy work to preserve main context
- PreCompact hook auto-saves STATE.md, so compaction is always safe

### Diagnosing UI/state regressions

When the user reports a UI element "used to be here yesterday" or "where did X go?", the FIRST step is `git log -p --follow <file>` or `git diff HEAD~N <file>` against the version they remember — BEFORE forming any hypothesis. The element may have been renamed, moved, or relocated to a different DOM tree in a prior commit. Only after confirming the change isn't in version history should you treat it as a fresh bug.

### Verifying a fix took effect

When a fix appears not to take effect — especially on a device, another browser, or any no-hot-reload / cached / CDN context — FIRST verify the **actually-served artifact** before re-debugging the source: `curl` the served HTML/CSS/JS chunk and grep for your change, check the server process restarted (PID changed), or load in a private/cacheless window. Treat "looks unchanged" as "possibly stale build/cache" until proven otherwise. Do not start a new code hypothesis until the served build is confirmed to contain the change.

The same rule applies beyond web builds: compare the version an installed binary reports against the version actually running before auditing config that both are presumed to share.

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
4. **Always produce the next-session initialization prompt.** Whenever a handoff is initiated —
   session end, a `/compact`, "we're done", or any context reset — write/update the project's
   next-session init prompt (e.g. `docs/superpowers/NEXT-SESSION-PROMPT.md` or equivalent) AND
   surface its text in the reply so it can be pasted into the fresh window. The prompt must:
   read STATE.md + the relevant spec first; state what just shipped (with the merge SHA); name
   the recommended next slice and alternatives; and restate the load-bearing conventions
   (branch/merge/push, abstraction-extraction default, subagent concurrency + per-phase verify).
   This is mandatory, not optional — a handoff without an init prompt is incomplete.

## Quality Checks

Before marking work complete, verify:
- [ ] Code runs without errors
- [ ] Changes are logically atomic (one concern per commit)
- [ ] Documentation reflects current state
- [ ] No sensitive data exposed
