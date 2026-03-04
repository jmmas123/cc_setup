Session retrospective — capture what worked, what didn't, and improve the config.

Follow these steps:

## 1. Reflect on this session
Review what was asked, what was done, and where friction occurred. Consider:
- Were there repeated permission prompts?
- Did we waste context on heavy research that could have been a subagent?
- Were there misunderstandings or wrong turns?
- Did any tool or command work particularly well?

## 2. Ask targeted questions
Ask the user 2-3 specific questions about their experience:
- "Was there anything that felt slow or frustrating?"
- "Did I take any approaches you'd want me to avoid next time?"
- "Is there a pattern or shortcut you wished existed?"

## 3. Propose improvements
Based on findings, propose concrete changes:
- New permission entries for `settings.local.json`
- New or updated rules in `~/.claude/rules/`
- New slash commands in `~/.claude/commands/`
- Updates to `CLAUDE.md` or `MEMORY.md`
- New hook or automation

## 4. Log findings
Append a timestamped entry to `~/.claude/feedback/retro-log.md` with:
```
## [DATE] — Session Retro
**What worked**: [brief list]
**Friction**: [brief list]
**Actions taken**: [what was changed]
**Deferred**: [improvements to consider later]
```

## 5. Implement agreed changes
If the user agrees to any improvement, implement it immediately — edit the rule, add the command, update the permission. Don't defer.
