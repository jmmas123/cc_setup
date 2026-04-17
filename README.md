# Claude Code Setup

Personal configuration for [Claude Code](https://claude.com/claude-code) — Anthropic's CLI agent for software engineering. This repo tracks the portable, non-sensitive parts of `~/.claude/` to replicate the setup across machines.

## Quick Start

**See [`SETUP.md`](SETUP.md)** for a step-by-step guide to set this up on a new machine.

## What's Included

```
~/.claude/
├── CLAUDE.md                          # Global instructions (loaded in every project)
├── settings.json                      # Hooks, MCP servers, enabled plugins
├── hooks/
│   ├── session-start.sh               # Injects STATE.md + git info on session start
│   ├── bash-guard.sh                  # PreToolUse safety guard (blocks dangerous commands)
│   ├── log-commands.sh                # PostToolUse command audit logger
│   └── statusline.sh                  # Status bar info (git branch, STATE.md)
├── rules/
│   ├── workflow.md                    # Session protocol + compaction triggers
│   ├── coding-standards.md            # Language/tool standards (Python, uv, pytest)
│   ├── context-hygiene.md             # Anti-pollution rules (based on MIT research)
│   └── continuous-improvement.md      # Proactive improvement detection
├── commands/
│   ├── status.md                      # /status — project orientation
│   ├── wrap-up.md                     # /wrap-up — session end protocol
│   ├── review.md                      # /review — code review on recent changes
│   ├── retro.md                       # /retro — session retrospective
│   ├── meta-review.md                 # /meta-review — config audit
│   └── adversarial-analysis.md        # /adversarial-analysis — multi-agent review
├── agents/
│   ├── adversarial-reviewer.md        # Multi-round adversarial review agent
│   ├── code-reviewer.md              # Code review specialist agent
│   ├── data-analyst.md               # Data analysis & metrics agent
│   ├── debugger.md                    # Systematic root cause debugger
│   ├── security-auditor.md            # Deep security review + threat modeling
│   ├── sql-analyst.md                 # Database exploration & query building
│   └── test-writer.md                 # Test generation (pytest-style)
├── mcp/
│   └── sql_server_mcp.py             # DWH MCP server (PostgreSQL/SQL Server)
├── feedback/
│   ├── retro-log.md                   # Append-only retrospective log
│   └── friction-patterns.md           # Recurring friction themes
├── .env.example                       # Database credential template
├── .gitignore                         # Excludes sensitive/auto-generated files
├── SETUP.md                           # Setup guide for new machines
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
- **Context Management** — event-based `/compact` suggestions at safe checkpoints, automated state capture via hooks
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
│  │  session-start.sh    │──▶ Injects STATE.md + git branch +    │
│  │  (command hook)      │    last 3 commits + change warnings   │
│  └──────────────────────┘                                       │
│                                                                 │
│  ... working session ...                                        │
│                                                                 │
│  ┌──────────────────────┐                                       │
│  │  bash-guard.sh       │──▶ Blocks dangerous commands          │
│  │  (PreToolUse)        │    (rm -rf /, force push main, etc.)  │
│  └──────────────────────┘                                       │
│  ┌──────────────────────┐                                       │
│  │  log-commands.sh     │──▶ Logs all Bash commands with        │
│  │  (PostToolUse)       │    timestamps (7-day rotation)        │
│  └──────────────────────┘                                       │
│                                                                 │
│  SAFE CHECKPOINT REACHED (commit, task done, topic switch)      │
│  Claude suggests: "Good checkpoint to /compact"                 │
│                                                                 │
│  PRE-COMPACT                                                    │
│  ┌──────────────────────┐                                       │
│  │  PreCompact agent    │──▶ Captures facts-only STATE.md:      │
│  │  (agent hook, 120s)  │    branch, changes, decisions,        │
│  └──────────────────────┘    outcomes, blockers (no reasoning)   │
│                                                                 │
│  SESSION RESUMES (or new session)                               │
│  ┌──────────────────────┐                                       │
│  │  session-start.sh    │──▶ Re-injects STATE.md for            │
│  │  fires again         │    seamless continuity                │
│  └──────────────────────┘                                       │
└─────────────────────────────────────────────────────────────────┘
```

#### `SessionStart` — Command Hook
- **Script:** `hooks/session-start.sh`
- **Behavior:** Injects STATE.md content, shows git branch + last 3 commits, warns about uncommitted changes, checks for CLAUDE.md existence

#### `PreCompact` — Agent Hook
- **Timeout:** 120 seconds
- **Behavior:** Captures facts-only STATE.md — branch, changes, user decisions, outcomes, blockers. No reasoning or analysis (anti-pollution).

#### `PreToolUse` — Command Hook (bash-guard.sh)
- **Behavior:** Blocks dangerous Bash commands: `rm -rf /`, `rm -rf ~`, `git push --force` to main/master, `DROP TABLE/DATABASE`

#### `PostToolUse` — Command Hook (log-commands.sh)
- **Behavior:** Logs all Bash commands to `command-history.log` with timestamps. Auto-rotates after 7 days.

#### `Notification` — Command Hook
- **Behavior:** macOS notification with sound when Claude needs attention

### 3. Rules (`rules/`)

Auto-loaded into every session. Four rule files:

| Rule | Purpose |
|------|---------|
| `workflow.md` | Session protocol, event-based compaction triggers, STATE.md format |
| `coding-standards.md` | Python type hints, NumPy docstrings, tool preferences (uv, rg, gh) |
| `context-hygiene.md` | Anti-pollution rules based on MIT research (arXiv:2602.24287) |
| `continuous-improvement.md` | Watches for automation opportunities, stale config, missing conventions |

### 4. Custom Agents (`agents/`)

Specialized subagents spawned via the `Task` tool for focused work.

| Agent | Model | Purpose | When to Use |
|-------|-------|---------|-------------|
| **code-reviewer** | Sonnet | Reviews for correctness, security (OWASP), performance, project standards | After writing or modifying code |
| **adversarial-reviewer** | Opus | Multi-round red-team analysis with convergence scoring (target: 8.5/10) | Validating designs, architectures, models, formulas |
| **data-analyst** | Sonnet | Runs scripts, computes metrics, profiles datasets, returns concise summaries | Exploratory analysis, data quality checks, metric computation |
| **debugger** | Sonnet | Systematic root cause analysis — isolates verbose debugging from main context | Bugs, test failures, crashes, unexpected behavior |
| **sql-analyst** | Sonnet | Database exploration, query building, schema discovery, data profiling | Schema questions, complex queries, data profiling |
| **test-writer** | Sonnet | Generates pytest-style tests with edge cases and error paths | After writing new code or modifying existing code |
| **security-auditor** | Sonnet | Deep security review, dependency scanning, secret detection, threat modeling | Security audits, pre-deployment review, new attack surface |

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
| `/status` | Quick project orientation — git state, STATE.md, blockers |
| `/wrap-up` | Session end protocol — summarize, update STATE.md, note next steps |
| `/review` | Code review on recent changes (git diff) |
| `/retro` | Session retrospective — capture what worked, what didn't, improve config |
| `/meta-review` | Periodic config audit — rules, memory, commands, permissions health check |
| `/adversarial-analysis` | Multi-agent red-team review for designs, architectures, complex decisions |

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

See **[`SETUP.md`](SETUP.md)** for detailed step-by-step instructions, including troubleshooting.

**Quick version:**

```bash
git clone git@github.com:jmmas123/cc_setup.git ~/.claude
cd ~/.claude && ./install.sh   # installs terminal-notifier, marks hooks executable
claude  # authenticate
# Create settings.local.json with your permission overrides
# Create .env with your database credentials (optional)
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
