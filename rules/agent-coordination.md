# Agent Coordination Protocol (Auto-Loaded)

## Agent Classification

Before spawning agents, classify each by intent:

| Class | Examples | Parallel? | Isolation? |
|-------|----------|-----------|------------|
| **Read-only** | Explore, research, code-explorer, code-reviewer | Yes, freely | None needed |
| **Write — disjoint files** | Agents editing different modules/directories | Yes | `isolation: "worktree"` |
| **Write — overlapping files** | Agents that may touch the same files | **No — sequential only** | N/A |

**Read-only / review agents must inspect history WITHOUT mutating the working tree** — use `git show <sha>:<path>`, `git diff A..B`, `git log -p <sha>` against explicit SHAs. NEVER `git checkout` / `switch` / `stash` / `reset` / `restore` in a subagent: the parent's current branch + working tree are shared state, and switching them silently corrupts the parent's view (committed work can look reverted). When dispatching a review agent, pass BASE_SHA/HEAD_SHA and tell it to use SHA-based inspection only.

## Subagent Mandate Boundaries (surface, don't self-decide)

A subagent executes **exactly** the task it was dispatched with — no more. When it discovers something outside that task — a new bug, a review finding it wasn't asked to fix, a better approach, a scope expansion, a follow-up it "may as well do" — it must **STOP and SURFACE it to the orchestrator in its final report**, and let the orchestrator decide. It must NOT silently fix it, commit it, or otherwise act on it.

- **Never act beyond the dispatched scope.** A reviewer reviews; it does not also fix. An implementer for task N does not also do task N+1, refactor adjacent code, or address a separate reviewer's findings. Out-of-scope work returns as a *recommendation*, not a *commit*.
- **The orchestrator owns all merge/commit/scope decisions.** Surfacing preserves the orchestrator's view of what changed and why; self-deciding fragments authorship, hides changes from review, and can land unreviewed code.
- **A subagent must exit when its task is done** — it does not stay alive watching the tree for more work to pick up.
- When dispatching, state this explicitly: *"Do ONLY this task. If you find anything else worth doing, report it in your final message — do not act on it."*

## Dead-agent recovery

If an implementation subagent dies mid-task (API error, timeout), do NOT relaunch its original prompt. First inspect the working tree (`git status` / `git diff --stat`) for partial work, then dispatch a **continuation agent** whose prompt:

1. States that the previous agent died and its diff is **unverified**.
2. Requires reading the inherited diff with suspicion before extending it.
3. Carries the original acceptance criteria and verification checklist.

**Why:** Relaunching from scratch wastes the partial work and risks conflicting double-implementation; trusting the partial work blindly ships unverified code. Validated twice in one session (liquid_glass_ui Phases 4 and 5) — the Phase 4 continuation agent caught a real bug the original would have shipped.

## Pre-Spawn Checklist

Before spawning parallel implementation agents:

1. **Declare file targets** — List which files/directories each agent will modify
2. **Check for overlap** — If any two agents might touch the same file, run them sequentially
3. **Use worktrees for writers** — Any agent that creates or edits files MUST use `isolation: "worktree"` when running in parallel with other writers
4. **Cap parallel writers at 3** — More than 3 concurrent worktree agents causes merge complexity; batch the rest sequentially

## Worktree Protocol

When using `isolation: "worktree"`:
- The agent works on an isolated branch — zero collision with other agents or the main tree
- On completion, the worktree path and branch are returned — merge back explicitly
- If the agent makes no changes, the worktree is auto-cleaned
- After all agents finish, merge branches sequentially and resolve any conflicts before proceeding
- **Never symlink or move `node_modules`** (or any gitignored dependency dir) between the main checkout and a worktree — run `npm ci` in the worktree, or skip node-dependent verification and let the orchestrator verify after merge. Worktree cleanup (`git worktree remove --force`) follows symlinks' parent dirs and can destroy the main checkout's real dependencies.
- Before any agent or task mutates frontend dependencies, confirm the dev server is stopped

## Committing from Subagents

Subagents that commit MUST stage only their own explicit file paths (`git add <path> …`), NEVER `git add -A` / `git add .` / `git commit -a`. On a shared working tree those sweep concurrent agents' in-progress edits into one mixed commit. For atomic isolation of parallel writers, use `isolation: "worktree"`. Also: verify any "a hook did X" diagnosis against the actual hook script before acting on it (e.g. the PostToolUse checkpoint hook prints a banner — it does not commit).

## Sequential Fallback

Default to sequential execution when:
- Tasks modify a shared config file (e.g., `pyproject.toml`, `package.json`, `__init__.py`)
- Tasks involve database migrations or schema changes
- The output of one task informs the input of another
- You are uncertain about file overlap — sequential is always safe

## Applying to `claude-mem:do`

When `claude-mem:do` executes a plan with multiple phases or tasks:
- **Research tasks** within a phase → parallel, no isolation
- **Implementation tasks in different modules** → parallel with worktree isolation
- **Implementation tasks in the same module** → sequential
- **Review/test tasks** → sequential after all implementation is complete

## Cost control: never burn tokens on an unbounded fan-out

Derived from a real incident (kika, 2026-08-05): a six-agent review workflow ran
for 36 minutes, consumed **2.2M subagent tokens, and produced ZERO results** —
every agent stalled (no progress for 180s, six retries each) — yet the run still
returned the plausible-sounding string *"No findings survived adversarial
verification."* Nothing was reviewed. The cause was the prompt: each agent was
told to *"sweep every view under `apps/rentals/views/` and `apps/vendors/views/`"*.

**1. Bound the reading scope in the prompt.** Never write "sweep every X",
"review all Y under `<dir>`", or "audit the whole Z". Enumerate the specific
files the agent must open. If the file list isn't known yet, run one cheap
discovery step first (a grep, a `find`) and pass the resulting list in. An
unbounded reading task is the most common cause of a stalled agent.

**2. Cap the work explicitly.** State a maximum number of files to open and a
maximum number of findings, and say that returning early with fewer results is a
valid, useful answer. Agents stall when they believe exhaustiveness is required.

**3. Start with one agent, then fan out.** Run a single agent on a single
dimension first. Only scale to N once one has completed in reasonable time on
this codebase. A fan-out multiplies the cost of a bad prompt by N.

**4. NEVER report a multi-agent result without checking that the agents ran.**
Before believing any workflow output, check `agents_done` / `agents_error` in the
usage block, and grep the run's `journal.jsonl` for `"type":"result"` lines. Zero
results means the run FAILED. A summary like "no findings" is then an artifact of
emptiness, not a clean bill of health — presenting it as reassurance is a serious
error, because it converts a total failure into false confidence in the code.

**5. Cost is a first-class constraint, not an afterthought.** Before launching a
fan-out, state the expected agent count and rough budget. If a run can plausibly
exceed ~1M tokens, scope it down or ask first.
