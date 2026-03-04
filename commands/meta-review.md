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

## 7. Report
Present findings as a structured report with:
- **Status**: ✅ healthy / ⚠️ needs attention / ❌ broken
- **Action items**: Specific changes ranked by impact
- Offer to implement the top 3 immediately
