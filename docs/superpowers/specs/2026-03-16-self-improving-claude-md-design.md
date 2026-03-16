# Self-Improving CLAUDE.md

> A closed-loop system that turns session friction, corrections, and accumulated
> agent wisdom into CLAUDE.md improvements — proposed automatically, applied
> with human approval.

## The Problem

CLAUDE.md is the highest-leverage file in the configuration: loaded into every
session, across every project, shaping every response. Yet it only changes when
someone remembers to edit it. Insights from retros go to a log nobody re-reads.
Agent memories accumulate patterns that never propagate upward. Corrections
given in one session are forgotten by the next.

The feedback loop is open. This design closes it.

## Architecture

```
  Session Work
       |
       v
  +-----------+     +-----------+     +-----------+
  | /wrap-up  |     |  /retro   |     |/meta-rev  |
  | detect    |     | discuss + |     | synthesize|
  | correct-  |     | extract   |     | agent     |
  | ions &    |     | findings  |     | memories  |
  | friction  |     |           |     |           |
  +-----+-----+     +-----+-----+     +-----+-----+
        |                  |                 |
        v                  v                 v
  +--------------------------------------------------+
  |     feedback/claude-md-proposals.md               |
  |     [PENDING] proposals with rationale            |
  +----------------------------+---------------------+
                               |
                               v
                        +------+------+
                        |  /improve   |
                        |  review &   |
                        |  apply      |
                        +------+------+
                               |
                               v
                          CLAUDE.md
                          (updated & committed)
```

## Decisions

| Decision | Choice | Why |
|----------|--------|-----|
| Approval model | Propose-then-apply (human approves) | CLAUDE.md is high-leverage; bad auto-edits cascade across all projects |
| Continuous signals | Corrections + friction | Highest signal-to-noise; observable within a single session |
| Periodic signals | Agent memory synthesis | Cross-cutting patterns need batch analysis, not real-time |
| Staging location | `feedback/claude-md-proposals.md` | Keeps CLAUDE.md clean; single review surface; preserves history |
| Detection trigger | Existing commands (`/wrap-up`, `/retro`, `/meta-review`) | Zero overhead during normal work; runs at natural boundaries |

## Components

### 1. Staging File

**Path**: `feedback/claude-md-proposals.md`

Append-only during detection. Updated in-place during review.

```markdown
# CLAUDE.md Improvement Proposals

Proposals are staged by `/wrap-up`, `/retro`, and `/meta-review`.
Review and apply with `/improve`.

---

### [PENDING] #001 Add rule: don't summarize completed work
- **Source**: wrap-up
- **Date**: 2026-03-16
- **Signal**: User said "stop summarizing what you just did" twice in one session
- **Proposal**: Add to Communication Style: "Don't recap completed work unless asked."
- **Section**: Communication Style
- **Rationale**: Redundant summaries waste tokens and annoy the user.
  The diff is visible; narrating it adds no value.
```

Each proposal gets a sequential ID (`#001`, `#002`, ...) for stable cross-referencing.

**Statuses**: `[PENDING]` | `[APPROVED]` (date) | `[REJECTED]` (date) | `[DEFERRED]` (date) | `[SUPERSEDED by #N]`

Rejected and deferred proposals remain as history. `/meta-review` watches for
recurring rejected proposals that keep resurfacing — a signal they should be
reconsidered. A proposal made obsolete by a later one is marked `[SUPERSEDED]`
with a reference to the replacing proposal.

### 2. Enhanced `/wrap-up`

Current behavior preserved. New step added **before** the session summary:

**Correction detection** — scan the conversation for:
- Direct redirects: "no", "don't", "stop", "instead of...", "I said..."
- Repeated instructions: same preference stated 2+ times
- Approach rejections: user rejected a proposed plan or tool choice

**Friction detection** — scan for:
- Permission prompts for the same tool pattern 3+ times
- Subagent spawns for knowledge that could be a rule
- Repeated command failures suggesting a missing convention

For each signal found, stage a structured proposal. End the wrap-up with:

> "Staged N CLAUDE.md proposal(s) — review with `/improve` when ready."

If no signals detected, say nothing — don't announce the absence of proposals.

### 3. Enhanced `/retro`

Current behavior preserved. New step added **after** step 4 (log findings to
`retro-log.md`) and **before** step 5 (implement agreed changes):

For each actionable finding logged in step 4, generate a CLAUDE.md proposal.
This is interactive — proposals come from what we jointly agree on during the
retro discussion, not from unilateral pattern matching.

The retro already identifies friction themes and proposes improvements. Now
those proposals get a durable home instead of just the retro log. Retro-log
entries are not updated when proposals are later approved — the log is
append-only history; the proposals file tracks resolution.

### 4. Enhanced `/meta-review`

Current behavior preserved. New step added as **step 2.5** (between memory
health check and commands audit):

**Agent memory synthesis**:
1. Read all `~/.claude/agent-memory/*/MEMORY.md` files
   (Note: the existing meta-review step 2 references `~/.claude/projects/*/memory/`
   for project memories. Agent memories live at a different path —
   `~/.claude/agent-memory/*/`. This step reads the agent path specifically.)
2. Identify patterns appearing in 2+ agent memories
3. Cross-reference with current CLAUDE.md and `~/.claude/rules/`
4. Stage proposals for cross-cutting patterns not already codified

**Recurring rejection check**:
1. Read `feedback/claude-md-proposals.md`
2. Find `[REJECTED]` proposals that were re-proposed (same signal, different date)
3. Flag these for reconsideration: "This was rejected on [date] but the same
   pattern surfaced again — worth reconsidering?"

**`friction-patterns.md` deprecation**: The existing `feedback/friction-patterns.md`
file tracked recurring friction themes manually. With proposals now accumulating
in `claude-md-proposals.md` with full signal+rationale context, friction-patterns
becomes redundant. During the first `/meta-review` after implementation, migrate
any existing entries to proposals and archive the file.

### 5. New `/improve` Command

The review-and-apply interface.

**Flow**:
1. Read `feedback/claude-md-proposals.md`
2. Filter to `[PENDING]` proposals
3. If none: "No pending proposals. Run `/wrap-up` or `/retro` to generate some."
4. Present a numbered summary of all pending proposals (ID, title, source)
5. Process sequentially, one at a time. For each, show the full proposal
   and ask: **Approve / Reject / Defer / Edit?**
   - **Approve**: Apply the edit to CLAUDE.md
   - **Reject**: Mark `[REJECTED]` with date — stays in history
   - **Defer**: Mark `[DEFERRED]` with date — revisit next `/meta-review`
   - **Edit**: User modifies the proposal text, then approve
   - No batch "approve all" shortcut — each proposal deserves individual review
6. After all proposals reviewed:
   - Show a diff summary of CLAUDE.md changes
   - Commit both CLAUDE.md and the updated proposals file
   - Report: "Applied N improvements to CLAUDE.md. N rejected, N deferred."

**Guard rails**:
- Proposals that delete or modify existing CLAUDE.md content must show a
  before/after diff before applying, even after the user says Approve
- Proposals that add new content are applied directly on Approve
- If any single CLAUDE.md section would exceed ~20 lines after applying a
  proposal, suggest extracting detail to a dedicated rule file in `rules/`

## File Changes Summary

| File | Change |
|------|--------|
| `feedback/claude-md-proposals.md` | **New** — staging file for proposals |
| `commands/wrap-up.md` | **Modify** — add correction + friction detection step |
| `commands/retro.md` | **Modify** — add proposal generation from findings |
| `commands/meta-review.md` | **Modify** — add agent memory synthesis + rejection recurrence check |
| `commands/improve.md` | **New** — review-and-apply command |

## What This Doesn't Do

- **No hooks added** — detection runs only within existing commands
- **No background processes** — zero overhead during normal work
- **No auto-edits** — every change requires human approval
- **No agent memory changes** — agent memories continue to accumulate independently
- **No CLAUDE.md structure changes** — proposals target the existing section layout

## Future Extensions (Not In Scope)

- **PreCompact hook detection**: If corrections are missed because `/wrap-up`
  isn't run, add lightweight detection to the PreCompact hook
- **Cross-project proposals**: If a pattern appears in multiple project CLAUDE.md
  files, propose promoting it to the global `~/.claude/CLAUDE.md`
- **Proposal analytics**: Track accept/reject rates over time to tune detection
  sensitivity
