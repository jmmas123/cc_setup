## Adversarial Analysis

Run an adversarial (GAN-style) multi-agent review of a complex decision, design, or architecture. Two agents — a Proposer and a Critic — debate iteratively until consensus. Applicable to any domain: software architecture, ML models, system design, API design, database schemas, infrastructure, refactoring strategies, etc.

### Protocol

1. **Read project context**: Check `docs/STATE.md`, relevant architecture/design docs, configs, source code, evaluation results, and domain docs. Understand the scope of the review from $ARGUMENTS (if not specified, review the primary architecture or design of the current project).
2. **Round 1 — Proposer**: Launch an opus-level agent that analyzes the full context and proposes the optimal design, structure, and implementation strategy for the subject under review. The proposer follows the simplicity principle: start with the simplest thing that works, add complexity only with evidence.
3. **Round 1 — Critic (Adversary)**: Launch an opus-level agent that receives the proposal plus all context. The critic finds every flaw, gap, incorrect assumption, and missed opportunity. Issues are rated H (critical) / M (significant) / L (minor).
4. **Round 2 — Proposer Revises**: The proposer addresses every H and M issue — accepting, rejecting with evidence, or modifying. Produces a revised design.
5. **Round 2 — Critic Converges**: The critic scores the revision 1-10 and issues a YES/NO verdict for implementation readiness. Lists any remaining issues.
6. **Additional rounds** if score < 7.0 or critical issues remain (max 4 rounds total).
7. **Document results**: Update or create an adversarial log document (e.g., `docs/ADVERSARIAL_LOG.md` or phase-specific) with the full interaction history, key discoveries, and consensus.

### Agent Instructions (shared context for both roles)

Both agents receive:
- Full domain context (project goals, constraints, requirements)
- Current design/architecture and relevant source code
- Current configs, schemas, or specifications
- Known issues, metrics, or evaluation results (if applicable)
- Available but unused options (tools, libraries, patterns, data sources)
- Implementation or deployment strategy

### Simplicity Principles (enforced for both agents)

- Start with the simplest viable approach
- Only add complexity when you have measured evidence it helps
- Diagnose before treating — understand root causes before proposing fixes
- Every component must justify its existence
- Prefer removing complexity over adding it
- Three similar lines of code > one premature abstraction

### Convergence Criteria

- Final critic score >= 8.5
- No unresolved H-level issues
- Clear priority queue with specific deliverables per step
- Design document ready for implementation

### Output

The review produces:
1. A design/architecture document with exact specifications
2. A prioritized implementation queue (P0-P9)
3. An adversarial log entry for future reference

$ARGUMENTS
