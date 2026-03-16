Session end protocol. Do all of the following:

## 0. Detect improvement signals

Before summarizing, scan this session for CLAUDE.md improvement signals:

**Corrections** — look for moments where the user redirected you:
- Direct corrections: "no", "don't", "stop doing X", "instead of...", "I said..."
- Repeated instructions: same preference stated 2+ times in this session
- Approach rejections: user rejected a proposed plan, tool choice, or approach

**Friction** — look for recurring obstacles:
- Permission prompts for the same tool pattern 3+ times
- Subagent research that could have been a rule or convention
- Repeated command failures suggesting a missing convention

For each signal found, append a structured proposal to `~/.claude/feedback/claude-md-proposals.md`:
```
### [PENDING] #NNN Brief title
- **Source**: wrap-up
- **Date**: YYYY-MM-DD
- **Signal**: What was observed
- **Proposal**: Exact text to add/modify/remove in CLAUDE.md
- **Section**: Which CLAUDE.md section this targets
- **Rationale**: Why this improves future sessions
```
Use the next sequential ID after the highest existing one in the file.

If signals were found, end this step with:
> "Staged N CLAUDE.md proposal(s) — review with `/improve` when ready."

If no signals detected, say nothing about proposals.

## 1. Summarize accomplishments

List what was completed this session with brief descriptions.

## 2. Update STATE.md

Find `docs/STATE.md` (or `STATE.md`). Update it with:
- Current position (what phase/step we're at)
- What was completed this session
- Next steps (what should be done next)
- Any open questions or blockers
- Date of this update

If no STATE.md exists, create `docs/STATE.md` with this information.

## 3. Check for uncommitted work

Run `git status`. If there are uncommitted changes, warn about them and ask if the user wants to commit.

## 4. Context note

If the conversation has been long, suggest starting a fresh session next time.

Be concise. Focus on capturing state for the next session.
