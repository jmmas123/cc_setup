Strict, evidence-backed code review with adversarial verification. Heavy — reserve for production or safety-critical code. For lighter, faster review use `/review`.

1. **Identify scope**: If `$ARGUMENTS` contains a path, review that path. Otherwise run `git diff HEAD` and review the changed files. If neither yields a target, ask the user what to review.

2. **Strict review pass**: Use the `code-reviewer-strict` agent on the scoped files. Capture every finding with its full schema: `id`, `severity`, `standard`, `file:line`, `description`, `suggested_fix`, and `evidence_needed`.

3. **Adversarial verification** (only for H and M findings — skip L findings, debate is too expensive for low-severity issues):
   - For each H/M finding, invoke the `adversarial-reviewer` agent with a prompt asking it to either (a) prove the finding is real by writing a running counter-example or exploit at `[file:line]`, OR (b) refute it with a concrete counter-case. Demand evidence, not argument.
   - Drop any finding the adversarial reviewer refutes with concrete evidence. Keep findings the adversarial reviewer proves OR cannot refute.
   - Parallelize the adversarial calls per `~/.claude/rules/agent-coordination.md` — these are read-only agents and can run freely in parallel; cap at 3 concurrent.

4. **Present synthesized report** organized by severity (H → M → L). For each surviving finding include:
   - Standard violated
   - File:line
   - Description
   - Adversarial verification status (Proven | Cannot-refute | Refuted-and-dropped)
   - Suggested fix

   End with an overall score (1-10) and convergence status against the adversarial-reviewer rubric (target ≥8.5 with no unresolved H findings).

5. **No code modifications**: This command is review-only and must not edit files. If the user wants the findings fixed, suggest invoking `claude-mem:do` afterward with this report as input.
