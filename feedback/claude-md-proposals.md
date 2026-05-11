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

### [PENDING] #002 Verify cross-browser support BEFORE committing to a CSS feature for production UI
- **Source**: wrap-up
- **Date**: 2026-04-25
- **Signal**: Spent 4–5 message turns building/iterating a "Liquid Glass" effect using `backdrop-filter: url(#svgFilter)` before discovering Safari and Firefox don't support it (WebKit bug #245510 still open). The user is shipping a mobile-first wedding-planning app launching in El Salvador where iOS Safari is ~30–40% of users. The lib's own README warned about this; I should have surfaced and weighed the limitation before the third iteration.
- **Proposal**: Add to the "Frontend / UI" section: "When picking a modern CSS feature for production UI (`backdrop-filter: url()`, `feDisplacementMap`, `paint-order` on text, container queries, `:has()`, etc.), verify Safari + Firefox + iOS support with WebSearch or caniuse before committing. State the cross-browser story in your first response, not after iteration. If the feature is Chromium-only, name it explicitly and ask whether graceful degradation is acceptable for the user's audience."
- **Section**: New subsection under "Coding Standards" → "Frontend / UI"
- **Rationale**: Browser-support gaps are a high-cost class of bug because they only surface during in-browser testing, not type-checking or unit tests. Catching them in the planning phase (one WebSearch) saves the entire iterate-debug-pivot cycle.

### [PENDING] #003 Test third-party libs inside the existing project's dev server, not isolated CDN/file:// demos
- **Source**: wrap-up
- **Date**: 2026-04-25
- **Signal**: Built a single-file HTML playground (`/tmp/kika-liquid-glass.html`) loading React + `liquid-glass-react` from esm.sh CDN to evaluate a library. Spent ~3 message rounds debugging file:// security errors, esm.sh resolution failures, and a manual HTTP server permission denial. After pivoting to install the lib in the actual Next.js project and adding a test page, integration worked in one shot — module resolution, peer deps, HTTP serving, and dev tools all "just worked" because the project already had them.
- **Proposal**: Add to the "Workflow" section: "When evaluating a new library or framework feature, integrate it into the existing project's dev server first rather than building an isolated CDN/file:// demo. Isolated demos invent failure modes (CORS, file:// origin restrictions, esm.sh peer-dep resolution, dual-React-instance bugs) that obscure the library's actual behavior. The marginal cost of a throwaway test route in the real project is ~5 minutes; the cost of debugging a CDN demo failing for environmental reasons can be 30+ minutes per iteration."
- **Section**: "Personal Workflow Principles" → near the existing "Plan before execute" rule
- **Rationale**: This is a high-leverage time-saver for any session that involves library evaluation. The pattern repeats: web devs reach for jsfiddle/codepen-style isolated demos but they're a worse signal than testing in the real env when the real env is already running.
