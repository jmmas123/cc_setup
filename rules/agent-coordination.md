# Agent Coordination Protocol (Auto-Loaded)

## Agent Classification

Before spawning agents, classify each by intent:

| Class | Examples | Parallel? | Isolation? |
|-------|----------|-----------|------------|
| **Read-only** | Explore, research, code-explorer, code-reviewer | Yes, freely | None needed |
| **Write — disjoint files** | Agents editing different modules/directories | Yes | `isolation: "worktree"` |
| **Write — overlapping files** | Agents that may touch the same files | **No — sequential only** | N/A |

**Read-only / review agents must inspect history WITHOUT mutating the working tree** — use `git show <sha>:<path>`, `git diff A..B`, `git log -p <sha>` against explicit SHAs. NEVER `git checkout` / `switch` / `stash` / `reset` / `restore` in a subagent: the parent's current branch + working tree are shared state, and switching them silently corrupts the parent's view (committed work can look reverted). When dispatching a review agent, pass BASE_SHA/HEAD_SHA and tell it to use SHA-based inspection only.

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
