Periodic audit of the Claude Code configuration. Run this monthly or when things feel off.

Systematically check each area and produce a structured report:

## 1. Rules health
Read all files in `~/.claude/rules/`. For each:
- Is it still relevant?
- Does it contradict any other rule or CLAUDE.md?
- Is it too verbose (could be trimmed)?

## 2. Memory health
Read `~/.claude/projects/*/memory/MEMORY.md` files. For each:
- Any stale lessons that no longer apply?
- Any lessons that should be promoted to a global rule?
- Is it within the 200-line limit?

## 2.5. Agent memory synthesis

Read all `~/.claude/agent-memory/*/MEMORY.md` files (distinct from project memories in step 2).

**Cross-cutting pattern detection**:
- Identify patterns appearing in 2+ agent memories
- Cross-reference with current `~/.claude/CLAUDE.md` and `~/.claude/rules/`
- Stage proposals in `~/.claude/feedback/claude-md-proposals.md` for patterns not already codified

**Recurring rejection check**:
- Read `~/.claude/feedback/claude-md-proposals.md`
- Find `[REJECTED]` proposals where the same signal resurfaced (different date, same pattern)
- Flag these: "Proposal #NNN was rejected on [date] but the same pattern surfaced again — worth reconsidering?"

Use the standard proposal format with `**Source**: meta-review`.

## 3. Commands audit
List all files in `~/.claude/commands/`. For each:
- Is it still useful?
- Are there gaps — common workflows that lack a command?

## 4. Permissions check
Read `~/.claude/settings.local.json`. Check:
- Has cruft accumulated (one-off approvals)?
- Are there patterns that could be consolidated?
- Any permissions that seem too broad?

## 5. Hooks health
Read `~/.claude/settings.json` hooks section. For each hook:
- Is it working correctly?
- Any hooks that should be added or removed?
- Are timeouts appropriate?

## 6. Feedback log review
Read `~/.claude/feedback/retro-log.md` if it exists. Look for:
- Recurring friction themes not yet addressed
- Improvements that were deferred and should now be done

Also check `~/.claude/feedback/claude-md-proposals.md` for:
- Stale `[DEFERRED]` proposals that should be reconsidered
- High volume of `[REJECTED]` proposals (suggests detection is too noisy)
- `[APPROVED]` patterns (confirms what kinds of proposals are valuable)

## 7. Report
Present findings as a structured report with:
- **Status**: healthy / needs attention / broken
- **Action items**: Specific changes ranked by impact
- **Proposals staged**: How many new CLAUDE.md proposals were generated
- Offer to implement the top 3 immediately
