Review and apply pending CLAUDE.md improvement proposals.

## Process

1. **Read proposals**: Read `~/.claude/feedback/claude-md-proposals.md` and filter to `[PENDING]` entries.

2. **Handle empty queue**: If no pending proposals exist, say:
   > "No pending proposals. Run `/wrap-up` or `/retro` to generate some."
   Then stop.

3. **Show summary**: Present a numbered list of all pending proposals:
   ```
   Pending CLAUDE.md proposals:
   1. #001 — Brief title (source: wrap-up, 2026-03-16)
   2. #003 — Brief title (source: retro, 2026-03-17)
   ```

4. **Review each sequentially**: For each pending proposal, show:
   - The full proposal (signal, proposed change, section, rationale)
   - If the proposal **modifies or removes** existing CLAUDE.md content, show a before/after diff
   - Ask: **Approve / Reject / Defer / Edit?**

   Actions:
   - **Approve**: Apply the proposed edit to `~/.claude/CLAUDE.md`. Update the proposal status to `[APPROVED] (YYYY-MM-DD)`.
   - **Reject**: Update the proposal status to `[REJECTED] (YYYY-MM-DD)`. Leave in file as history.
   - **Defer**: Update the proposal status to `[DEFERRED] (YYYY-MM-DD)`. Will be flagged for reconsideration during next `/meta-review`.
   - **Edit**: Let the user modify the proposal text, then apply the edited version and mark `[APPROVED]`.

   No batch "approve all" — each proposal deserves individual consideration.

5. **Section size check**: After applying each approval, check if the target CLAUDE.md section now exceeds ~20 lines. If so, suggest extracting detail to a dedicated rule file in `~/.claude/rules/`.

6. **Commit**: After all proposals are reviewed:
   - Show a summary of CLAUDE.md changes (what was added/modified/removed)
   - Commit both `~/.claude/CLAUDE.md` and `~/.claude/feedback/claude-md-proposals.md`
   - Report: "Applied N improvements to CLAUDE.md. N rejected, N deferred."

$ARGUMENTS
