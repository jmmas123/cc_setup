# Claude Code Setup

Personal configuration for [Claude Code](https://claude.com/claude-code) — Anthropic's CLI agent for software engineering. This repo tracks the portable, non-sensitive parts of `~/.claude/` to replicate the setup across machines.

## What's Included

```
~/.claude/
├── CLAUDE.md                          # Global instructions (loaded in every project)
├── settings.json                      # Hooks, enabled plugins
├── hooks/
│   └── session-start.sh               # Injects STATE.md on session start
├── rules/
│   └── workflow.md                    # Auto-loaded workflow discipline rules
├── commands/
│   └── adversarial-analysis.md        # /adversarial-analysis slash command
├── agents/
│   ├── adversarial-reviewer.md        # Multi-round adversarial review agent
│   ├── code-reviewer.md              # Code review specialist agent
│   └── data-analyst.md               # Data analysis & metrics agent
├── .gitignore                         # Excludes sensitive/auto-generated files
└── README.md                          # This file
```

### What's Excluded (and why)

| Excluded | Reason |
|----------|--------|
| `.credentials.json` | Auth tokens — sensitive |
| `settings.local.json` | Machine-specific permission overrides |
| `projects/` | Per-project session history and conversations |
| `plugins/` | Managed by the plugin system, auto-installed |
| `history.jsonl` | Conversation log |
| `debug/`, `cache/`, `telemetry/`, `todos/`, `tasks/` | Auto-generated runtime data |

---

## Components

### 1. Global Instructions (`CLAUDE.md`)

Loaded into **every** Claude Code session regardless of project. Defines:

- **Golden Rules** — discuss before plan, plan before execute, verify before moving on, atomic commits
- **Context Management** — proactive `/compact` suggestion at ~100k output tokens, automated state capture via hooks
- **Session Discipline** — check for `STATE.md` on start, summarize and document on end
- **Project Structure Expectation** — every project should have `CLAUDE.md`, `docs/STATE.md`, `docs/ROADMAP.md`
- **Code Standards** — type hints (PEP 484), NumPy docstrings, no hardcoded secrets, `logging` over `print`
- **Tool Preferences** — `uv` over pip, `rg` for search, `gh` for GitHub, `pytest -xvs` for debugging

### 2. Hooks (`settings.json` + `hooks/`)

Hooks are shell scripts or agent prompts that fire at specific lifecycle events.

#### Session Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│  SESSION START                                                  │
│  ┌──────────────────────┐                                       │
│  │  session-start.sh    │──▶ Finds STATE.md, injects content    │
│  │  (command hook)      │    as context so Claude has prior      │
│  └──────────────────────┘    session state immediately           │
│                                                                 │
│  ... working session ...                                        │
│                                                                 │
│  CONTEXT FILLS UP (~100k tokens)                                │
│  Claude suggests: "Want to /compact?"                           │
│                                                                 │
│  PRE-COMPACT                                                    │
│  ┌──────────────────────┐                                       │
│  │  PreCompact agent    │──▶ Spawns subagent that:              │
│  │  (agent hook, 120s)  │    • Reads git status + recent log    │
│  └──────────────────────┘    • Writes docs/STATE.md with:       │
│                                - Accomplished                   │
│                                - In Progress                    │
│                                - Pending items                  │
│                                - Key Context                    │
│                                                                 │
│  COMPACTION RUNS                                                │
│  Context compressed, prior messages summarized                  │
│                                                                 │
│  SESSION RESUMES (or new session)                               │
│  ┌──────────────────────┐                                       │
│  │  session-start.sh    │──▶ Re-injects STATE.md content        │
│  │  fires again         │    for seamless continuity            │
│  └──────────────────────┘                                       │
└─────────────────────────────────────────────────────────────────┘
```

#### `SessionStart` — Command Hook

- **Fires:** Every session start, resume, `/clear`, or `/compact`
- **Script:** `hooks/session-start.sh`
- **Behavior:** Searches for `docs/STATE.md`, `STATE.md`, or `.claude/STATE.md` and outputs its content as context. If none found, suggests creating one.

#### `PreCompact` — Agent Hook

- **Fires:** Before context compaction (manual `/compact` or automatic)
- **Type:** Agent (subagent with full tool access: Read, Write, Bash, Glob, Grep)
- **Timeout:** 120 seconds
- **Behavior:** Analyzes git state, recent commits, and uncommitted changes. Writes a structured state snapshot to `docs/STATE.md` (or project root if `docs/` doesn't exist). Overwrites prior content — it's a snapshot, not an append log.

### 3. Workflow Rules (`rules/workflow.md`)

Auto-loaded into every session (rules are always injected). Enforces:

- **Session Start Protocol** — look for state files, confirm understanding
- **Context Awareness** — monitor usage, suggest `/compact` proactively
- **State Documentation** — summarize after significant work, update state docs
- **Phase Transitions** — verify deliverables, update roadmap, suggest fresh session
- **Quality Checks** — code runs, changes are atomic, docs are current, no secrets exposed

### 4. Custom Agents (`agents/`)

Specialized subagents spawned via the `Task` tool for focused work.

| Agent | Model | Purpose | When to Use |
|-------|-------|---------|-------------|
| **code-reviewer** | Sonnet | Reviews for correctness, security (OWASP), performance, project standards | After writing or modifying code |
| **adversarial-reviewer** | Opus | Multi-round red-team analysis with convergence scoring (target: 8.5/10) | Validating designs, architectures, models, formulas |
| **data-analyst** | Sonnet | Runs scripts, computes metrics, profiles datasets, returns concise summaries | Exploratory analysis, data quality checks, metric computation |

#### Adversarial Reviewer Protocol

Runs up to 4 rounds of structured debate:

1. **Red Team Attack** — challenges assumptions, classifies issues (H/M/L)
2. **Defense & Remediation** — addresses H/M issues with evidence
3. **Targeted Testing** — writes and runs code to test remaining hypotheses
4. **Final Assessment** — if score still < 8.5, documents what remains unresolved

Convergence: score >= 8.5/10 with no unresolved high-severity issues.

### 5. Custom Commands (`commands/`)

Slash commands available in any session.

| Command | Description |
|---------|-------------|
| `/adversarial-analysis` | Launches a full GAN-style multi-agent review (Proposer vs Critic) for any design, architecture, or complex decision. Produces a design document + prioritized implementation queue. |

### 6. Enabled Plugins (`settings.json`)

| Plugin | Category |
|--------|----------|
| `superpowers` | Workflow skills (TDD, debugging, brainstorming, planning, code review) |
| `github` | GitHub integration via `gh` CLI |
| `supabase` | Supabase project management and database operations |
| `frontend-design` | Production-grade UI component generation |
| `feature-dev` | Guided feature development with architecture focus |
| `code-simplifier` | Code clarity and maintainability refactoring |
| `security-guidance` | Security best practices and vulnerability scanning |
| `claude-md-management` | CLAUDE.md auditing and improvement |
| `skill-creator` | Creating and evaluating custom skills |
| `explanatory-output-style` | Educational insights during coding |
| `playground` | Interactive HTML playground generation |
| `huggingface-skills` | HuggingFace Hub operations (models, datasets, training) |
| `ralph-loop` | Iterative agent loop management |
| `linear` | Linear issue tracking integration |
| `firecrawl` | Web scraping, search, and research |
| `semgrep` | Static analysis and code scanning |

---

## Installation

### Fresh Machine Setup

```bash
# Clone into ~/.claude (must be empty or non-existent)
git clone git@github.com:jmmas123/cc_setup.git ~/.claude

# Or if ~/.claude already exists with other files:
cd ~/.claude
git init
git remote add origin git@github.com:jmmas123/cc_setup.git
git fetch origin
git checkout -b main origin/main
```

### After Installing Claude Code

1. **Authenticate:** Run `claude` and follow the auth flow — creates `.credentials.json` (gitignored)
2. **Local settings:** Create `settings.local.json` for machine-specific permission overrides (gitignored)
3. **Plugins:** Plugins listed in `settings.json` will be auto-resolved; some may need manual enabling via `/plugins`
4. **Hook permissions:** On first trigger, Claude Code will prompt to approve each hook

### Keeping in Sync

```bash
# After making changes to config
cd ~/.claude
git add -A && git commit -m "Update [what changed]"
git push

# On another machine
cd ~/.claude && git pull
```

---

## Recommendations

### For New Projects

1. **Create a project `CLAUDE.md`** at the repo root with project-specific context (architecture, commands, conventions)
2. **Create `docs/STATE.md`** — the hooks will maintain it, but seeding it with initial project context helps
3. **Create `docs/ROADMAP.md`** — phase overview for multi-session projects
4. **Add `.claude/settings.json`** to the project for project-specific hooks or permissions (team-shared)
5. **Add `.claude/settings.local.json`** to `.gitignore` for personal overrides

### Context Management

- **Delegate research** to subagents (`Task` tool) to preserve main context window
- **One major task per session** — compact or start fresh between unrelated tasks
- **Trust the hooks** — `PreCompact` captures state automatically, no need to manually document before compacting
- **Use `/compact` with instructions** — e.g., `/compact preserve the database schema decisions` to guide what gets prioritized during compression

### Agent Usage

- **Code reviewer**: Use after every non-trivial code change, before committing
- **Adversarial reviewer**: Use before finalizing any architecture, design, or model — the multi-round protocol catches issues that single-pass review misses
- **Data analyst**: Use when analysis output would clutter the main conversation — the agent isolates verbose computation and returns a summary

### Hook Customization

The hook system supports three types with increasing capability:

| Type | Speed | Tool Access | Best For |
|------|-------|-------------|----------|
| `command` | Fast (~1s) | Shell only | File checks, env setup, notifications |
| `prompt` | Medium (~5s) | None (single-turn LLM) | Judgment decisions, content validation |
| `agent` | Slow (~30-120s) | Full (Read, Write, Bash, etc.) | Complex analysis, file generation |

Available hook events: `SessionStart`, `PreCompact`, `Stop`, `PreToolUse`, `PostToolUse`, `UserPromptSubmit`, `Notification`, `SessionEnd`, and more. See [Claude Code hooks documentation](https://docs.anthropic.com/en/docs/claude-code/hooks) for the full reference.

### Security

- **Never track** `.credentials.json` or `settings.local.json`
- **Review hooks** before running on a new machine — they execute with your shell permissions
- **Use `PreToolUse` hooks** to block dangerous operations (e.g., protect production configs, `.env` files)
- **Audit plugins** — enabled plugins have tool access within Claude Code sessions
