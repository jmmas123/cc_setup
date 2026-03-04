# Continuous Improvement (Auto-Loaded)

Watch for improvement opportunities during normal work. Surface as brief suggestions at natural breakpoints (task completion, session end), not as interruptions mid-task.

## Patterns to Watch

- **Repetition**: If something is done manually 3+ times → suggest a slash command or automation
- **Permission friction**: If a permission is asked repeatedly → suggest adding to allow list
- **Context waste**: If heavy research consumed >30% of context → suggest subagent pattern for next time
- **Missing conventions**: If a project has no CLAUDE.md → gently suggest creating one at session end
- **Stale config**: If a rule or memory entry hasn't been relevant in multiple sessions → suggest pruning during next `/meta-review`

## How to Surface

- Keep suggestions to 1-2 sentences
- Frame as "I noticed..." not "You should..."
- Only suggest at natural breakpoints, never mid-task
- Max 1 suggestion per session (don't nag)
- If the user agrees, implement immediately
