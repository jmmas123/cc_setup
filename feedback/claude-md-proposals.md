# CLAUDE.md Improvement Proposals

Proposals are staged by `/wrap-up`, `/retro`, and `/meta-review`.
Review and apply with `/improve`.

---

### [PENDING] #001 Note: authenticate Semgrep plugin or disable its PostToolUse hook
- **Source**: wrap-up
- **Date**: 2026-03-16
- **Signal**: Semgrep PostToolUse hook fired "No SEMGREP_APP_TOKEN found" on every Edit/Write (~8 times this session). Not blocking but pollutes logs.
- **Proposal**: This is not a CLAUDE.md change — it's an action item. Either run `/semgrep-plugin:setup-semgrep-plugin` to authenticate, or disable the semgrep plugin's PostToolUse hook in settings.json until authenticated.
- **Section**: N/A (operational action item)
- **Rationale**: Noisy hooks degrade signal quality of PostToolUse output and add latency to every edit.
