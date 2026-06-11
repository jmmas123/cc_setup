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

---

### [PENDING] #013 Fix or suppress the recurring SRI warning on `landing/index.html`
- **Source**: wrap-up
- **Date**: 2026-05-15
- **Signal**: Semgrep `missing-integrity` warning fired on EVERY edit to `landing/index.html` this session (5+ times), pointing at the same two lines: GSAP `gsap.min.js` and `ScrollTrigger.min.js` on lines 20-21 of index.html. The warning is real (CWE-353) but pre-existing and unrelated to ongoing copy/visual edits. It adds noise to every reply and risks training me to ignore Semgrep output globally.
- **Proposal**: This is an action item, not a CLAUDE.md change. Either (a) add `integrity="sha384-..." crossorigin="anonymous"` to both GSAP `<script>` tags using the published hashes from cdnjs, or (b) add a `.semgrepignore` / nosem inline annotation scoped to those two lines if SRI is intentionally deferred until self-hosting GSAP. Option (a) is the right long-term fix.
- **Section**: N/A (operational action item against caas-platform repo)
- **Rationale**: Eliminates a recurring false-positive hook output so the next real Semgrep finding actually gets noticed.

---

### [PENDING] #014 Add "check git diff before diagnosing missing UI elements" to project workflow rules
- **Source**: wrap-up
- **Date**: 2026-05-15
- **Signal**: Earlier in this session (per pre-compaction summary), I misdiagnosed a "missing hero card" as a ScrollTrigger init timing bug and started applying patches (onRefresh handler, inline styles, console.log, CSS opacity override) before the user redirected me: "no this is not possible, go check the diff vs the repo version of two days ago". The actual cause was that the card the user remembered had been moved to a different chapter in a previous commit. Multiple corrective edits had to be reverted.
- **Proposal**: Add to `~/.claude/rules/workflow.md` under a new section "Diagnosing UI/state regressions": "When the user reports a UI element 'used to be here yesterday' or 'where did X go?', the FIRST step is `git log -p --follow <file>` or `git diff HEAD~N <file>` against the version they remember — BEFORE forming any hypothesis. The element may have been renamed, moved, or relocated to a different DOM tree in a prior commit. Only after confirming the change isn't in version history should you treat it as a fresh bug."
- **Section**: New section in `~/.claude/rules/workflow.md`
- **Rationale**: This is a recurring failure mode for me. The "user says X is missing → I theorize about runtime behavior → user redirects to git history" loop wastes time and produces speculative edits. A standing rule pushes the diff check to the front.

---

### [PENDING] #015 Add "ground copy proposals in concrete artifacts" to communication rules
- **Source**: wrap-up
- **Date**: 2026-05-15
- **Signal**: Mid-session, I proposed a one-word eyebrow set (Substrate / Origin / Scale / Solutions / Marketplace / Tender / Intelligence / Delivery / Network) for the landing page cards. The user rejected it: "no i dont like the proposed eyebrow set. im planning to use the nav bar for something else. it has to be something more descriptive. maybe all the sections being proposed to the users." The rejected eyebrows were abstract narrative beats; the accepted replacement (Global Freight / Port & Yard Operations / Warehousing & Storage / ...) named concrete service categories users can buy.
- **Proposal**: Add to `~/.claude/CLAUDE.md` under "Communication Style": "When proposing copy for headings, taglines, eyebrows, or section labels in customer-facing materials, default to concrete artifacts (a service, a deliverable, a buyable thing) rather than abstract narrative concepts. If the user asks for a 'standardized' set, propose at least one concrete-artifact variant alongside any abstract option, and flag which you recommend."
- **Section**: `~/.claude/CLAUDE.md` → Communication Style
- **Rationale**: Concrete > abstract is a near-universal preference for marketing/landing copy. Anchoring to deliverables also dovetails with the existing rule "Connect technical work to business impact" — business impact is rarely an abstract narrative beat.

---

### [PENDING] #005 Audit existing dashboards before inventing new visual or URL primitives
- **Source**: wrap-up
- **Date**: 2026-05-15
- **Signal**: While building the warehouse_performance dashboard in atlas2, the user redirected me three times for failing to follow existing dashboard conventions: (a) "standardize the cards, they are transparent and blurry" — I had invented `warehouse-performance-card` instead of using the project's standard `card widget-flat kpi-card` (defined once in `static/src/scss/components/_layout.scss`); (b) "standardize the new gauges to be the same as the ones we are currently using" — I had built bespoke rgba color steps instead of reusing the white→lightgreen→dark-green→black scheme used across analysis_and_warehouse_utilization and global_operations_analyst; (c) "the url for this dashboard reads /reports/ and this is not right, this should be under /analytics-modules/" — I followed the older `/reports/<name>/` pattern blindly, missing that NEW dashboards should live under `/analytics-modules/<name>/`. Each correction required a follow-up commit to swap to the standard.
- **Proposal**: Add to `~/.claude/rules/workflow.md` under a new section "Before building a new dashboard or report-style view": "Audit existing peers in `apps/reports/views/`, `templates/reports/`, and `static/js/charts/` for (1) reusable CSS classes (search SCSS for `.kpi-card`, `.widget-flat`, `.help-container`), (2) Plotly gauge/chart step-color palettes used by other dashboards, (3) shared chart-helper renderers (e.g., `render_indicator_gauge`, `renderLineChart`), (4) URL namespace convention (NEW dashboards go under `/analytics-modules/<name>/` via the webpage app; only standalone reports use `/reports/<name>/`). Reuse before inventing. Adding a new dashboard-only visual primitive should be a deliberate, justified choice — not the default."
- **Section**: New section in `~/.claude/rules/workflow.md`
- **Rationale**: Three separate corrections in one session all trace to the same root: I wrote dashboard chrome without first surveying what the project already has. Each correction added a round-trip commit. A standing pre-build audit step would have caught all three before the first commit. The URL convention point is project-specific (different from the established `/reports/` precedent) — encoding it explicitly is the only way I'll learn it without re-being corrected.

---

### [PENDING] #006 Note this project's eslint blocks setState-in-effect — seed React state via lazy initializers / derived values
- **Source**: wrap-up
- **Date**: 2026-05-30
- **Signal**: Twice this session the frontend eslint rule `react-hooks/set-state-in-effect` fired as a build-blocking ERROR on the WeddingAssistant frontend: (1) my new `vendor-inquiry-settings.tsx` seeded draft state with `useEffect`+`setState` from react-query `data` — which also caused an infinite render loop (4 GB Node heap OOM in vitest) under a non-stable mocked `data`; (2) a pre-existing planner-category-preselect `useEffect` in `vendor-onboarding-form.tsx`. Both had to be refactored to a non-effect pattern before lint passed.
- **Proposal**: Add to `frontend/AGENTS.md`: "This project's eslint enforces `react-hooks/set-state-in-effect` as an ERROR. Do NOT seed component state from fetched data or props via `useEffect`+`setState` — it fails lint and risks infinite-render loops when the source ref isn't stable. Instead: initialize editable state with a lazy `useState(() => deriveFromProps())` inside a child that mounts only once the data is loaded, or compute a derived value at render. In tests, mirror react-query's referential stability by hoisting the mocked `data` to a stable ref inside the `vi.mock` factory."
- **Section**: `frontend/AGENTS.md` (frontend-specific conventions)
- **Rationale**: The same anti-pattern bit me twice in one session and is build-blocking. A standing note stops future sessions from writing useEffect-seeded state and then having to refactor plus debug a vitest OOM.

---

### [PENDING] #007 Record out-of-scope warnings / pre-existing test failures in ROADMAP "Queued/deferred", don't fix inline
- **Source**: wrap-up
- **Date**: 2026-05-30
- **Signal**: When eslint surfaced a pre-existing `@next/next/no-img-element` warning out of scope for the current task, the user said: "lets document this warning to be fixed or reviewd later. ignore if you have fixed it completely." The repo already tracks pre-existing frontend test failures in `docs/ROADMAP.md` (§8B-Marketplace "Queued / deferred"), so there is an established home for deferred items.
- **Proposal**: Add to the project `CLAUDE.md`: "Non-blocking lint warnings and pre-existing test failures that are out of scope for the current task go in `docs/ROADMAP.md` under the relevant phase's 'Queued / deferred' list (and a note in STATE.md for handoff) — not fixed inline, not silently ignored. Build-blocking ERRORS in code you're already touching should still be fixed."
- **Section**: project `CLAUDE.md` (Reference Documents / tech-debt convention)
- **Rationale**: The user prefers a tracked-for-later trail over scope-creep fixes; encoding where deferred items live (ROADMAP) lets the next session file them in the right place without being told.

---

### [PENDING] #008 Read the product-vision docs before brainstorming a new TΣNSOR facet/feature
- **Source**: wrap-up
- **Date**: 2026-06-04
- **Signal**: While brainstorming the Services and (especially) Marketplace facets, the user redirected me to existing documentation I had not consulted: "you can check the documentation there should be a description of this on the documentation." `docs/FOUNDRY_INSPIRATION_AND_SPECS.md` already defined the Tender Marketplace + Rental Marketplace (their assets/uses) and named the ontology entities (Asset, Tender, Rental Capacity, Capacity Slot, Service Node) + actions (open tender, rent asset); `docs/NETWORK_UI_DESIGN.md` lists the same entities + layered UI modes. I had started proposing a model from first principles instead of designing to the documented vision, costing a round-trip.
- **Proposal**: Add to project `CLAUDE.md` (Workflow section): "Before brainstorming a new facet/feature, read the product-vision docs first: `docs/FOUNDRY_INSPIRATION_AND_SPECS.md` (Foundry inspiration, the complementary Tender/Rental marketplace components, the full object+action ontology) and `docs/NETWORK_UI_DESIGN.md` (layered UI modes + entity list). They often already describe the feature — design *to* them, not from scratch."
- **Section**: project `CLAUDE.md` (Workflow / Reference Documents)
- **Rationale**: The marketplace was already specified in the vision docs; not reading them first risked a divergent design and cost a clarification round-trip. A standing pointer makes future design sessions start from documented intent rather than re-deriving it.

---

### [PENDING] #009 Visual consistency is non-negotiable when porting external content into a TΣNSOR facet
- **Source**: wrap-up
- **Date**: 2026-06-04
- **Signal**: Designing the Analytics facet (which reuses atlas2's dashboards), the user stated a hard constraint: "the style and visuals need to be consistent. this is non-negotiable." Intent: bring atlas2's *content* (which KPIs, which chart types, the report structure) but render 100% in TΣNSOR's visual system — no Bootstrap/Plotly default look. Saved to project memory; it also governs every facet (Analytics now, Services/Marketplace, future), so it belongs in the authoritative project instructions, not only memory.
- **Proposal**: Add to project `CLAUDE.md` (Visual system section): "When a facet draws on an external source (e.g. atlas2), port the *content* (which KPIs, which chart types, the structure) but render **100% in TΣNSOR's visual language** — glass/Instrument personalities, the color tokens, mono numerics, charts themed to the palette. No foreign chrome (no Bootstrap, no Plotly default theme). Non-negotiable."
- **Section**: project `CLAUDE.md` (Visual system)
- **Rationale**: The user flagged this as non-negotiable and it governs all facet implementation. Encoding it at instruction level (CLAUDE.md, always in context) — not only in project memory (loaded as background context) — ensures the implementer who builds the dashboards honors it without re-being told.

---

### [PENDING] #010 Read-only/review subagents must inspect history via SHAs, never `git checkout`
- **Source**: wrap-up
- **Date**: 2026-06-05
- **Signal**: A final whole-branch code-review subagent (dispatched with Bash access) ran `git checkout main` to inspect the base, leaving the PARENT session checked out on `main`. Committed files then appeared reverted to old content (a real scare mid-session) — nothing was lost; recovered with `git checkout <branch>`. The current branch + working tree are shared mutable state the orchestrator depends on, and a read-only agent mutated them.
- **Proposal**: Add to `rules/agent-coordination.md` (Read-only class): "Read-only / review agents must inspect history WITHOUT mutating the working tree — use `git show <sha>:<path>`, `git diff A..B`, `git log -p <sha>` against explicit SHAs. NEVER `git checkout` / `switch` / `stash` / `reset` / `restore` in a subagent: the parent's current branch + working tree are shared state, and switching them silently corrupts the parent's view (committed work can look reverted). When dispatching a review agent, pass BASE_SHA/HEAD_SHA and tell it to use SHA-based inspection only."
- **Section**: rules/agent-coordination.md (Agent Classification / Read-only)
- **Rationale**: A review agent switching branches made committed work appear lost. Pinning read-only agents to SHA-based inspection keeps the orchestrator's branch/worktree from being mutated out from under it.

### [PENDING] #011 Worktree agents must not share node_modules with the main checkout
- **Source**: wrap-up
- **Date**: 2026-06-10
- **Signal**: A frontend worktree agent symlinked node_modules from the main checkout to run tooling; the later `git worktree remove --force` cleanup destroyed the main checkout's real node_modules while the user's dev server was running, causing module-not-found cascades and a Turbopack panic. Separately, frontend dependency bumps (next/axios) under a live dev server produced the same class of breakage.
- **Proposal**: Add to the Worktree Protocol section: "Worktree agents must never symlink or move `node_modules` (or any gitignored dependency dir) between the main checkout and a worktree — run `npm ci` in the worktree or skip node-dependent verification and let the orchestrator verify after merge. Before any agent or task mutates frontend dependencies, confirm the dev server is stopped."
- **Section**: ~/.claude/rules/agent-coordination.md → Worktree Protocol
- **Rationale**: Prevents destroying the main checkout's installed dependencies during worktree cleanup and avoids breaking a live dev server during dependency changes.

### [PENDING] #012 WeddingAssistant: worktree setup needs .env copy and isolated test DBs
- **Source**: wrap-up
- **Date**: 2026-06-10
- **Signal**: Both backend worktree agents independently discovered that a fresh worktree lacks the gitignored `.env` (Django fails to boot: AI provider slot not registered) and that parallel pytest runs collide on the shared `test_weddingassistant` database (one agent had to invent a custom DATABASE_URL).
- **Proposal**: Add to project CLAUDE.md (Local dev orchestration section): "Git worktrees: copy `.env` from the main checkout before running Django (`cp <main>/.env .env`). Parallel test runs against the same Postgres must use distinct databases — set `DATABASE_URL` with a unique db name per worktree (pytest derives `test_<name>`)."
- **Section**: WeddingAssistant CLAUDE.md → Local dev orchestration
- **Rationale**: Every future worktree agent hits both issues; documenting saves repeated rediscovery and avoids cross-agent test-DB interference.
