# CLAUDE.md Improvement Proposals

Proposals are staged by `/wrap-up`, `/retro`, and `/meta-review`.
Review and apply with `/improve`.

---

### [APPROVED] (2026-05-26) #001 Note: authenticate Semgrep plugin or disable its PostToolUse hook
**Resolution:** Disabled `semgrep@claude-plugins-official` in `~/.claude/settings.json` (line 164: `true → false`). All three semgrep hooks (PostToolUse, UserPromptSubmit, SessionStart) stop firing at next session start. Re-enable after running `/semgrep:setup-semgrep-plugin` if cloud-backed scans become desirable.

#### Original proposal
- **Source**: wrap-up
- **Date**: 2026-03-16
- **Signal**: Semgrep PostToolUse hook fired "No SEMGREP_APP_TOKEN found" on every Edit/Write (~8 times this session). Not blocking but pollutes logs.
- **Proposal**: This is not a CLAUDE.md change — it's an action item. Either run `/semgrep-plugin:setup-semgrep-plugin` to authenticate, or disable the semgrep plugin's PostToolUse hook in settings.json until authenticated.
- **Section**: N/A (operational action item)
- **Rationale**: Noisy hooks degrade signal quality of PostToolUse output and add latency to every edit.

### [APPROVED] (2026-05-26) #002 Verify cross-browser support BEFORE committing to a CSS feature for production UI
**Resolution:** Added "Frontend / UI" subsection to `~/.claude/rules/coding-standards.md` (auto-loaded). Text applied verbatim per proposal.

#### Original proposal
- **Source**: wrap-up
- **Date**: 2026-04-25
- **Signal**: Spent 4–5 message turns building/iterating a "Liquid Glass" effect using `backdrop-filter: url(#svgFilter)` before discovering Safari and Firefox don't support it (WebKit bug #245510 still open). The user is shipping a mobile-first wedding-planning app launching in El Salvador where iOS Safari is ~30–40% of users. The lib's own README warned about this; I should have surfaced and weighed the limitation before the third iteration.
- **Proposal**: Add to the "Frontend / UI" section: "When picking a modern CSS feature for production UI (`backdrop-filter: url()`, `feDisplacementMap`, `paint-order` on text, container queries, `:has()`, etc.), verify Safari + Firefox + iOS support with WebSearch or caniuse before committing. State the cross-browser story in your first response, not after iteration. If the feature is Chromium-only, name it explicitly and ask whether graceful degradation is acceptable for the user's audience."
- **Section**: New subsection under "Coding Standards" → "Frontend / UI"
- **Rationale**: Browser-support gaps are a high-cost class of bug because they only surface during in-browser testing, not type-checking or unit tests. Catching them in the planning phase (one WebSearch) saves the entire iterate-debug-pivot cycle.

### [APPROVED] (2026-05-26) #003 Test third-party libs inside the existing project's dev server, not isolated CDN/file:// demos
**Resolution:** Added as Golden Rule #7 in `~/.claude/CLAUDE.md`. Compressed from the original two-paragraph proposal into a single dense rule paragraph to keep parity with rules #1–6.

#### Original proposal
- **Source**: wrap-up
- **Date**: 2026-04-25
- **Signal**: Built a single-file HTML playground (`/tmp/kika-liquid-glass.html`) loading React + `liquid-glass-react` from esm.sh CDN to evaluate a library. Spent ~3 message rounds debugging file:// security errors, esm.sh resolution failures, and a manual HTTP server permission denial. After pivoting to install the lib in the actual Next.js project and adding a test page, integration worked in one shot — module resolution, peer deps, HTTP serving, and dev tools all "just worked" because the project already had them.
- **Proposal**: Add to the "Workflow" section: "When evaluating a new library or framework feature, integrate it into the existing project's dev server first rather than building an isolated CDN/file:// demo. Isolated demos invent failure modes (CORS, file:// origin restrictions, esm.sh peer-dep resolution, dual-React-instance bugs) that obscure the library's actual behavior. The marginal cost of a throwaway test route in the real project is ~5 minutes; the cost of debugging a CDN demo failing for environmental reasons can be 30+ minutes per iteration."
- **Section**: "Personal Workflow Principles" → near the existing "Plan before execute" rule
- **Rationale**: This is a high-leverage time-saver for any session that involves library evaluation. The pattern repeats: web devs reach for jsfiddle/codepen-style isolated demos but they're a worse signal than testing in the real env when the real env is already running.

### [APPROVED] (2026-05-26) #004 Trim or condition the "Secure-by-Default Libraries" UserPromptSubmit injection
**Resolution:** Resolved by the same fix as #001 — the noisy UserPromptSubmit injection comes from the semgrep plugin (`semgrep mcp -k inject-secure-defaults-short` per `~/.claude/plugins/cache/claude-plugins-official/semgrep/0.5.3/hooks/hooks.json`). Disabling the plugin in `~/.claude/settings.json` removes this hook too.

#### Original proposal
- **Source**: wrap-up
- **Date**: 2026-05-26
- **Signal**: A ~50-line "Security Guidance: Secure-by-Default Libraries" block was injected by a UserPromptSubmit hook on every user message this session (4+ firings). Today's session was Django state machine + chat events + DRF endpoints — zero relevance to Helmet.js, DOMPurify, SerialKiller, etc. The block also includes the same paragraph twice ("When writing code, consider using these security-focused libraries..." appears verbatim 2x within a single injection), suggesting the hook is double-rendering. None of the libs are Python/Django/Next.js native; the dominant project stack doesn't even use most of these (Ruby/Java/Node).
- **Proposal**: This is not a CLAUDE.md change — it's an action item. Either (a) gate the UserPromptSubmit hook to fire only when the prompt mentions security-sensitive keywords (xss/csrf/ssrf/crypto/sanitize), or (b) shrink the injection to a one-liner reference link, or (c) disable it entirely if it isn't paying its way. The duplicate-paragraph bug should be fixed regardless.
- **Section**: N/A (operational action item — hook configuration in settings.json)
- **Rationale**: ~50 lines × 4 messages = 200 lines of irrelevant context per session. Compounds with the prompt-cache TTL (5 min) — every cold restart re-pays the token cost on injected content that didn't apply. Same friction class as #001 (semgrep hook noise).
