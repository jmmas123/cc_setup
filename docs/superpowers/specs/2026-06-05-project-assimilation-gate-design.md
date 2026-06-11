---
title: Project Assimilation Gate
date: 2026-06-05
status: approved-design
scope: ~/.claude global config (hooks, skills, CLAUDE.md, settings.json)
---

# Project Assimilation Gate — Design

## Problem

When working in projects that already have an established identity — conventions,
classes, style, standards, existing utilities — Claude tends not to familiarize
itself with how things are done before writing. The result: reinvented or
duplicated functionality, divergence from the project's style and methods, and
ignored existing abstractions.

The stack today is rich in **process discipline** (plan → execute → review →
commit) but nearly absent in **codebase assimilation**. The one place it could
live, `~/.claude/hooks/session-start.sh:42-45`, only checks whether `CLAUDE.md`
*exists* — it never reads it, and nothing forces Claude to study the project's
existing patterns before editing. The on-demand tools that *could* help
(`feature-dev:code-explorer`, `feature-dev:code-architect`) only fire when
summoned, which is the exact lapse being fixed.

## Goal

Make project assimilation **non-forgettable** for established projects, without
becoming friction the user will disable. Assimilate four dimensions before the
first write each session: **code conventions**, **style & tooling**,
**domain/architecture**, **docs & state**.

## Non-Goals

- Greenfield / scratch work is explicitly exempt — never interrupt it.
- Not a passive session-start banner (declined in favor of an active gate).
- Not a replacement for `make-plan`; it runs before/independently of it.
- Does not invent new code-analysis machinery — it reuses
  `feature-dev:code-explorer` and mirrors the existing `bash-guard.sh` hook
  pattern. (The design is self-consistent with its own thesis: reuse over
  reinvention.)

## Decisions (locked during brainstorming)

| Axis | Decision |
|---|---|
| Leverage points | A `/familiarize` skill (engine) + a CLAUDE.md rule (mandate) + a PreToolUse hook (enforcement) |
| Scope | All four dimensions (code conventions, style/tooling, architecture, docs/state) |
| Firing trigger | First Write/Edit per established project per session |
| Persistence | Durable `.claude/CONVENTIONS.md`, freshness-checked against git HEAD |
| Engine | Hybrid: cheap signals inline + `feature-dev:code-explorer` for the deep pass |
| Enforcement | PreToolUse Write/Edit hook, **warn-and-allow** (never blocks) |
| Warning cadence | **Warn once per session** (sentinel set when warning fires) |
| Digest location | Project `.claude/CONVENTIONS.md`, **gitignored by default** |

## Architecture

Three cooperating layers, each independently removable:

1. **Instruction layer** — a CLAUDE.md rule ("Assimilation Before Writing").
2. **Enforcement layer** — `~/.claude/hooks/familiarize-gate.sh` (PreToolUse,
   matcher `Write|Edit`), warn-and-allow.
3. **Engine layer** — `~/.claude/skills/familiarize/SKILL.md`, the hybrid
   assimilator that produces the digest.

Primary silencer **across** sessions = digest freshness. Secondary silencer
**within** a session = the session sentinel.

### Control flow

```
Write/Edit about to run
        │
        ▼
[familiarize-gate.sh]  (PreToolUse, matcher "Write|Edit", exit 0 always)
        │
        ├─ cwd an "established" project?           ──no──▶ allow silently
        ├─ already warned this session? (sentinel) ──yes─▶ allow silently
        ├─ .claude/CONVENTIONS.md fresh?           ──yes─▶ allow silently
        │
        ▼ (established · not warned · stale/absent digest)
   allow + inject warning via additionalContext + set session sentinel
        │
        ▼
 Model reads system-reminder warning → runs /familiarize → writes digest
        │
        ▼
 Remaining writes this session: silent (sentinel set; digest now fresh)
```

## Components

### 1. `familiarize-gate.sh` (PreToolUse hook)

**Contract (verified against current Claude Code hooks API):**
- stdin JSON includes `session_id`, `cwd`, `tool_name`, `tool_input.file_path`.
- **Read stdin exactly once** into a variable (stdin is not re-readable; the
  naive `jq … < /dev/stdin` twice pattern is a bug).
- To warn-and-allow: exit 0 with
  ```json
  {
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "allow",
      "additionalContext": "<warning text>"
    }
  }
  ```
  `additionalContext` (max 10,000 chars) is injected into the model's context as
  a system reminder — this is the channel the model actually reads.
  `permissionDecisionReason` is NOT a reliable model-visible channel (human
  dialog only).
- Exit 0 allows; exit 2 would block (we never block).

**Logic:**
1. Slurp stdin → `INPUT`. Extract `cwd`, `session_id`, `file_path`.
2. **Established-project heuristic** (cheap `test`s on `cwd`, OR-of):
   `CLAUDE.md` exists · a manifest/lockfile exists (`pyproject.toml`,
   `package.json`, `go.mod`, `Cargo.toml`, `requirements.txt`, `Gemfile`) ·
   git history > 3 commits · > 15 source files. None → not established → exit 0
   silently.
3. **Session sentinel:** `~/.claude/cache/assimilate/<session_id>-<cwd_hash>`
   (where `cwd_hash` is a short hash of the absolute cwd). Exists → exit 0
   silently. Sentinels live in global cache, **never** in the user's repos.
4. **Freshness check** of `<cwd>/.claude/CONVENTIONS.md` (see §3). Fresh → exit 0
   silently.
5. Otherwise: write the sentinel, then exit 0 with the `additionalContext`
   warning:
   > ⚠ About to Write/Edit in an established project without a fresh conventions
   > digest (`.claude/CONVENTIONS.md`). This write is allowed. Before continuing,
   > run `/familiarize` so you reuse existing patterns, utilities, and style
   > instead of reinventing them. (Greenfield work is exempt; this fires once
   > per session.)

**Safety / robustness:**
- Must never block the user's work: any internal error → exit 0 silently
  (fail-open). The hook is advisory.
- All file tests confined to `cwd`; no writes except the sentinel under
  `~/.claude/cache/assimilate/`.
- Fast (<150ms target): shell + `jq` only, no subprocess fan-out beyond a
  bounded `git`/`find` with limits.

### 2. `/familiarize` skill (`~/.claude/skills/familiarize/SKILL.md`)

Hybrid engine. Steps:

1. **Cheap signals, inline (main agent):** read manifests/lockfiles, lint/format
   configs (`ruff`, `eslint`, `prettier`, `.editorconfig`, `pyproject [tool.*]`),
   `CLAUDE.md`, `README`, `docs/`, `STATE.md`, `ROADMAP.md`. Covers
   *style/tooling* and *docs/state* cheaply.
2. **Expensive pass, delegated:** dispatch `feature-dev:code-explorer`
   (read-only) to map *code conventions* + *architecture*: where utilities live,
   naming patterns, module/class organization, error-handling idioms, key
   abstractions, and a **reuse map** ("need X? it already exists at `path`").
   Keeps heavy reading out of main context.
3. **Synthesize** → write `<cwd>/.claude/CONVENTIONS.md` (~1 page, four labeled
   sections + Reuse Map).
4. **Stamp** freshness frontmatter (§3).
5. **Gitignore:** ensure `.claude/CONVENTIONS.md` is gitignored; offer to add the
   line if absent. Touch the session sentinel so the gate stays silent.
6. Can also be invoked manually at any time to force a refresh.

### 3. `.claude/CONVENTIONS.md` (the digest) + freshness

```markdown
---
generated: 2026-06-05
head: a1b2c3d          # git rev-parse HEAD at generation (empty if non-git)
file_count: 247        # tracked/source file count for drift detection
stale_after_days: 14   # fallback TTL for non-git or long-lived branches
---
# Project Conventions (auto-derived — re-run /familiarize if stale)
## Code conventions
## Style & tooling
## Architecture
## Docs & state
## Reuse Map      # existing helpers to use instead of reinventing
```

**Freshness rule — fresh if:**
- git repo: `head` == current `git rev-parse HEAD`; **or**
- non-git / detached / branch diverged: `generated` within `stale_after_days`
  **and** current source-file count within ±10% of `file_count`.

Otherwise stale → the gate warns and `/familiarize` re-derives.

### 4. CLAUDE.md rule

New section in `~/.claude/CLAUDE.md`, immediately after "Skills — MANDATORY":

```markdown
## Assimilation Before Writing — MANDATORY
Before your FIRST Write/Edit in an established project each session, ensure
`.claude/CONVENTIONS.md` is fresh; if not, invoke `/familiarize` to assimilate
the project's conventions, style, architecture, and existing utilities BEFORE
writing. Reuse what exists; match the project's grain. The familiarize-gate
hook warns you if you forget — treat that warning as a stop-and-assimilate
signal. Greenfield/scratch work is exempt.
```

### 5. `session-start.sh` addition

Add a cleanup pass that removes stale session sentinels from
`~/.claude/cache/assimilate/` (e.g. older than 1 day), keeping the cache tidy.

### 6. `settings.json` addition

Add to `hooks.PreToolUse` a new matcher entry:
```json
{ "matcher": "Write|Edit",
  "hooks": [ { "type": "command", "command": "~/.claude/hooks/familiarize-gate.sh", "timeout": 5000 } ] }
```

## Data flow summary

```
session N:   first Write/Edit → gate warns (once) → /familiarize → CONVENTIONS.md (HEAD=X)
session N:   subsequent writes → silent (sentinel + fresh digest)
session N+1: HEAD still X       → gate silent (digest fresh; no re-assimilation)
session N+2: HEAD moved to Y    → digest stale → gate warns → /familiarize refresh (HEAD=Y)
```

## Failure modes & handling

| Failure | Handling |
|---|---|
| `jq`/git missing, malformed stdin, any hook error | Fail-open: exit 0 silently. Never block the user. |
| Non-git project | Freshness falls back to TTL + file-count. |
| Huge repo, slow explorer | `/familiarize` bounds the explorer's scope to touched area + top-level layout; digest stays ~1 page. |
| User ignores the warning | By design (warn-and-allow). Fires once; not repeated. |
| Digest drift mid-session (large refactor) | Accepted: digest is session-stable; next session's HEAD check catches it. Manual `/familiarize` forces refresh. |
| Sentinel cache growth | `session-start.sh` prunes sentinels > 1 day old. |

## Testing strategy

- **Hook unit tests** (shell, table-driven): feed crafted stdin JSON; assert
  exit 0 always; assert `additionalContext` present/absent across the matrix of
  {established?, sentinel?, fresh digest?}. Assert stdin read once.
- **Heuristic tests:** temp dirs simulating greenfield vs. each established
  signal (CLAUDE.md / lockfile / git>3 commits / >15 files).
- **Freshness tests:** digest with matching vs. drifted HEAD; non-git TTL path;
  ±10% file-count boundary.
- **Skill smoke test:** run `/familiarize` in a sample established project;
  verify a four-section digest + Reuse Map + valid frontmatter, and that the
  gitignore line is added.
- **End-to-end:** fresh session in an established project → first Edit triggers
  exactly one warning; second Edit silent; new session with unchanged HEAD →
  silent.

## Files created / modified

| File | Action |
|---|---|
| `~/.claude/skills/familiarize/SKILL.md` | create |
| `~/.claude/hooks/familiarize-gate.sh` | create (chmod +x) |
| `~/.claude/settings.json` | add PreToolUse `Write|Edit` hook entry |
| `~/.claude/hooks/session-start.sh` | add sentinel cleanup |
| `~/.claude/CLAUDE.md` | add "Assimilation Before Writing" section |

## Open questions

None — all design axes resolved during brainstorming.
