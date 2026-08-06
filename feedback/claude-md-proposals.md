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

### [DEFERRED] (2026-06-11) #013 Fix or suppress the recurring SRI warning on `landing/index.html`
**Status note:** Deferred at /improve review — reconsider at next /meta-review or next caas-platform session. Repo confirmed at `~/source/caas-platform`.

- **Source**: wrap-up
- **Date**: 2026-05-15
- **Signal**: Semgrep `missing-integrity` warning fired on EVERY edit to `landing/index.html` this session (5+ times), pointing at the same two lines: GSAP `gsap.min.js` and `ScrollTrigger.min.js` on lines 20-21 of index.html. The warning is real (CWE-353) but pre-existing and unrelated to ongoing copy/visual edits. It adds noise to every reply and risks training me to ignore Semgrep output globally.
- **Proposal**: This is an action item, not a CLAUDE.md change. Either (a) add `integrity="sha384-..." crossorigin="anonymous"` to both GSAP `<script>` tags using the published hashes from cdnjs, or (b) add a `.semgrepignore` / nosem inline annotation scoped to those two lines if SRI is intentionally deferred until self-hosting GSAP. Option (a) is the right long-term fix.
- **Section**: N/A (operational action item against caas-platform repo)
- **Rationale**: Eliminates a recurring false-positive hook output so the next real Semgrep finding actually gets noticed.

---

### [APPROVED] (2026-06-11) #014 Add "check git diff before diagnosing missing UI elements" to project workflow rules
**Resolution:** Added "Diagnosing UI/state regressions" subsection to `~/.claude/rules/workflow.md` under "During Work". Text applied verbatim.

- **Source**: wrap-up
- **Date**: 2026-05-15
- **Signal**: Earlier in this session (per pre-compaction summary), I misdiagnosed a "missing hero card" as a ScrollTrigger init timing bug and started applying patches (onRefresh handler, inline styles, console.log, CSS opacity override) before the user redirected me: "no this is not possible, go check the diff vs the repo version of two days ago". The actual cause was that the card the user remembered had been moved to a different chapter in a previous commit. Multiple corrective edits had to be reverted.
- **Proposal**: Add to `~/.claude/rules/workflow.md` under a new section "Diagnosing UI/state regressions": "When the user reports a UI element 'used to be here yesterday' or 'where did X go?', the FIRST step is `git log -p --follow <file>` or `git diff HEAD~N <file>` against the version they remember — BEFORE forming any hypothesis. The element may have been renamed, moved, or relocated to a different DOM tree in a prior commit. Only after confirming the change isn't in version history should you treat it as a fresh bug."
- **Section**: New section in `~/.claude/rules/workflow.md`
- **Rationale**: This is a recurring failure mode for me. The "user says X is missing → I theorize about runtime behavior → user redirects to git history" loop wastes time and produces speculative edits. A standing rule pushes the diff check to the front.

---

### [APPROVED] (2026-06-11) #015 Add "ground copy proposals in concrete artifacts" to communication rules
**Resolution:** Added as a bullet under Communication Style in `~/.claude/CLAUDE.md`.

- **Source**: wrap-up
- **Date**: 2026-05-15
- **Signal**: Mid-session, I proposed a one-word eyebrow set (Substrate / Origin / Scale / Solutions / Marketplace / Tender / Intelligence / Delivery / Network) for the landing page cards. The user rejected it: "no i dont like the proposed eyebrow set. im planning to use the nav bar for something else. it has to be something more descriptive. maybe all the sections being proposed to the users." The rejected eyebrows were abstract narrative beats; the accepted replacement (Global Freight / Port & Yard Operations / Warehousing & Storage / ...) named concrete service categories users can buy.
- **Proposal**: Add to `~/.claude/CLAUDE.md` under "Communication Style": "When proposing copy for headings, taglines, eyebrows, or section labels in customer-facing materials, default to concrete artifacts (a service, a deliverable, a buyable thing) rather than abstract narrative concepts. If the user asks for a 'standardized' set, propose at least one concrete-artifact variant alongside any abstract option, and flag which you recommend."
- **Section**: `~/.claude/CLAUDE.md` → Communication Style
- **Rationale**: Concrete > abstract is a near-universal preference for marketing/landing copy. Anchoring to deliverables also dovetails with the existing rule "Connect technical work to business impact" — business impact is rarely an abstract narrative beat.

---

### [APPROVED] (2026-06-11) #005 Audit existing dashboards before inventing new visual or URL primitives
**Resolution:** Redirected from global `rules/workflow.md` to the project level (user choice — text is atlas2-specific). Added "Building New Dashboards" section to `~/source/atlas_v2/CLAUDE.md` under Architecture. Uncommitted in that repo.

- **Source**: wrap-up
- **Date**: 2026-05-15
- **Signal**: While building the warehouse_performance dashboard in atlas2, the user redirected me three times for failing to follow existing dashboard conventions: (a) "standardize the cards, they are transparent and blurry" — I had invented `warehouse-performance-card` instead of using the project's standard `card widget-flat kpi-card` (defined once in `static/src/scss/components/_layout.scss`); (b) "standardize the new gauges to be the same as the ones we are currently using" — I had built bespoke rgba color steps instead of reusing the white→lightgreen→dark-green→black scheme used across analysis_and_warehouse_utilization and global_operations_analyst; (c) "the url for this dashboard reads /reports/ and this is not right, this should be under /analytics-modules/" — I followed the older `/reports/<name>/` pattern blindly, missing that NEW dashboards should live under `/analytics-modules/<name>/`. Each correction required a follow-up commit to swap to the standard.
- **Proposal**: Add to `~/.claude/rules/workflow.md` under a new section "Before building a new dashboard or report-style view": "Audit existing peers in `apps/reports/views/`, `templates/reports/`, and `static/js/charts/` for (1) reusable CSS classes (search SCSS for `.kpi-card`, `.widget-flat`, `.help-container`), (2) Plotly gauge/chart step-color palettes used by other dashboards, (3) shared chart-helper renderers (e.g., `render_indicator_gauge`, `renderLineChart`), (4) URL namespace convention (NEW dashboards go under `/analytics-modules/<name>/` via the webpage app; only standalone reports use `/reports/<name>/`). Reuse before inventing. Adding a new dashboard-only visual primitive should be a deliberate, justified choice — not the default."
- **Section**: New section in `~/.claude/rules/workflow.md`
- **Rationale**: Three separate corrections in one session all trace to the same root: I wrote dashboard chrome without first surveying what the project already has. Each correction added a round-trip commit. A standing pre-build audit step would have caught all three before the first commit. The URL convention point is project-specific (different from the established `/reports/` precedent) — encoding it explicitly is the only way I'll learn it without re-being corrected.

---

### [APPROVED] (2026-06-11) #006 Note this project's eslint blocks setState-in-effect — seed React state via lazy initializers / derived values
**Resolution:** Added "Project conventions" section to `~/source/WeddingAssistant/frontend/AGENTS.md` (also reaches frontend/CLAUDE.md via its `@AGENTS.md` include). Uncommitted in that repo.

- **Source**: wrap-up
- **Date**: 2026-05-30
- **Signal**: Twice this session the frontend eslint rule `react-hooks/set-state-in-effect` fired as a build-blocking ERROR on the WeddingAssistant frontend: (1) my new `vendor-inquiry-settings.tsx` seeded draft state with `useEffect`+`setState` from react-query `data` — which also caused an infinite render loop (4 GB Node heap OOM in vitest) under a non-stable mocked `data`; (2) a pre-existing planner-category-preselect `useEffect` in `vendor-onboarding-form.tsx`. Both had to be refactored to a non-effect pattern before lint passed.
- **Proposal**: Add to `frontend/AGENTS.md`: "This project's eslint enforces `react-hooks/set-state-in-effect` as an ERROR. Do NOT seed component state from fetched data or props via `useEffect`+`setState` — it fails lint and risks infinite-render loops when the source ref isn't stable. Instead: initialize editable state with a lazy `useState(() => deriveFromProps())` inside a child that mounts only once the data is loaded, or compute a derived value at render. In tests, mirror react-query's referential stability by hoisting the mocked `data` to a stable ref inside the `vi.mock` factory."
- **Section**: `frontend/AGENTS.md` (frontend-specific conventions)
- **Rationale**: The same anti-pattern bit me twice in one session and is build-blocking. A standing note stops future sessions from writing useEffect-seeded state and then having to refactor plus debug a vitest OOM.

---

### [APPROVED] (2026-06-11) #007 Record out-of-scope warnings / pre-existing test failures in ROADMAP "Queued/deferred", don't fix inline
**Resolution:** Added "Tech debt / deferred items" subsection to `~/source/WeddingAssistant/CLAUDE.md` under Development Standards. Uncommitted in that repo.

- **Source**: wrap-up
- **Date**: 2026-05-30
- **Signal**: When eslint surfaced a pre-existing `@next/next/no-img-element` warning out of scope for the current task, the user said: "lets document this warning to be fixed or reviewd later. ignore if you have fixed it completely." The repo already tracks pre-existing frontend test failures in `docs/ROADMAP.md` (§8B-Marketplace "Queued / deferred"), so there is an established home for deferred items.
- **Proposal**: Add to the project `CLAUDE.md`: "Non-blocking lint warnings and pre-existing test failures that are out of scope for the current task go in `docs/ROADMAP.md` under the relevant phase's 'Queued / deferred' list (and a note in STATE.md for handoff) — not fixed inline, not silently ignored. Build-blocking ERRORS in code you're already touching should still be fixed."
- **Section**: project `CLAUDE.md` (Reference Documents / tech-debt convention)
- **Rationale**: The user prefers a tracked-for-later trail over scope-creep fixes; encoding where deferred items live (ROADMAP) lets the next session file them in the right place without being told.

---

### [APPROVED] (2026-06-11) #008 Read the product-vision docs before brainstorming a new TΣNSOR facet/feature
**Resolution:** Added as the first bullet of the Workflow section in `~/source/tensor/CLAUDE.md`. Uncommitted in that repo.

- **Source**: wrap-up
- **Date**: 2026-06-04
- **Signal**: While brainstorming the Services and (especially) Marketplace facets, the user redirected me to existing documentation I had not consulted: "you can check the documentation there should be a description of this on the documentation." `docs/FOUNDRY_INSPIRATION_AND_SPECS.md` already defined the Tender Marketplace + Rental Marketplace (their assets/uses) and named the ontology entities (Asset, Tender, Rental Capacity, Capacity Slot, Service Node) + actions (open tender, rent asset); `docs/NETWORK_UI_DESIGN.md` lists the same entities + layered UI modes. I had started proposing a model from first principles instead of designing to the documented vision, costing a round-trip.
- **Proposal**: Add to project `CLAUDE.md` (Workflow section): "Before brainstorming a new facet/feature, read the product-vision docs first: `docs/FOUNDRY_INSPIRATION_AND_SPECS.md` (Foundry inspiration, the complementary Tender/Rental marketplace components, the full object+action ontology) and `docs/NETWORK_UI_DESIGN.md` (layered UI modes + entity list). They often already describe the feature — design *to* them, not from scratch."
- **Section**: project `CLAUDE.md` (Workflow / Reference Documents)
- **Rationale**: The marketplace was already specified in the vision docs; not reading them first risked a divergent design and cost a clarification round-trip. A standing pointer makes future design sessions start from documented intent rather than re-deriving it.

---

### [APPROVED] (2026-06-11) #009 Visual consistency is non-negotiable when porting external content into a TΣNSOR facet
**Resolution:** Added to the Visual system section in `~/source/tensor/CLAUDE.md`. Uncommitted in that repo.

- **Source**: wrap-up
- **Date**: 2026-06-04
- **Signal**: Designing the Analytics facet (which reuses atlas2's dashboards), the user stated a hard constraint: "the style and visuals need to be consistent. this is non-negotiable." Intent: bring atlas2's *content* (which KPIs, which chart types, the report structure) but render 100% in TΣNSOR's visual system — no Bootstrap/Plotly default look. Saved to project memory; it also governs every facet (Analytics now, Services/Marketplace, future), so it belongs in the authoritative project instructions, not only memory.
- **Proposal**: Add to project `CLAUDE.md` (Visual system section): "When a facet draws on an external source (e.g. atlas2), port the *content* (which KPIs, which chart types, the structure) but render **100% in TΣNSOR's visual language** — glass/Instrument personalities, the color tokens, mono numerics, charts themed to the palette. No foreign chrome (no Bootstrap, no Plotly default theme). Non-negotiable."
- **Section**: project `CLAUDE.md` (Visual system)
- **Rationale**: The user flagged this as non-negotiable and it governs all facet implementation. Encoding it at instruction level (CLAUDE.md, always in context) — not only in project memory (loaded as background context) — ensures the implementer who builds the dashboards honors it without re-being told.

---

### [APPROVED] (2026-06-11) #010 Read-only/review subagents must inspect history via SHAs, never `git checkout`
**Resolution:** Added to `~/.claude/rules/agent-coordination.md` directly below the Agent Classification table. Text applied verbatim.

- **Source**: wrap-up
- **Date**: 2026-06-05
- **Signal**: A final whole-branch code-review subagent (dispatched with Bash access) ran `git checkout main` to inspect the base, leaving the PARENT session checked out on `main`. Committed files then appeared reverted to old content (a real scare mid-session) — nothing was lost; recovered with `git checkout <branch>`. The current branch + working tree are shared mutable state the orchestrator depends on, and a read-only agent mutated them.
- **Proposal**: Add to `rules/agent-coordination.md` (Read-only class): "Read-only / review agents must inspect history WITHOUT mutating the working tree — use `git show <sha>:<path>`, `git diff A..B`, `git log -p <sha>` against explicit SHAs. NEVER `git checkout` / `switch` / `stash` / `reset` / `restore` in a subagent: the parent's current branch + working tree are shared state, and switching them silently corrupts the parent's view (committed work can look reverted). When dispatching a review agent, pass BASE_SHA/HEAD_SHA and tell it to use SHA-based inspection only."
- **Section**: rules/agent-coordination.md (Agent Classification / Read-only)
- **Rationale**: A review agent switching branches made committed work appear lost. Pinning read-only agents to SHA-based inspection keeps the orchestrator's branch/worktree from being mutated out from under it.

### [APPROVED] (2026-06-11) #011 Worktree agents must not share node_modules with the main checkout
**Resolution:** Added two bullets to the Worktree Protocol section in `~/.claude/rules/agent-coordination.md` (no-symlink rule + stop-dev-server-before-dependency-mutation).

- **Source**: wrap-up
- **Date**: 2026-06-10
- **Signal**: A frontend worktree agent symlinked node_modules from the main checkout to run tooling; the later `git worktree remove --force` cleanup destroyed the main checkout's real node_modules while the user's dev server was running, causing module-not-found cascades and a Turbopack panic. Separately, frontend dependency bumps (next/axios) under a live dev server produced the same class of breakage.
- **Proposal**: Add to the Worktree Protocol section: "Worktree agents must never symlink or move `node_modules` (or any gitignored dependency dir) between the main checkout and a worktree — run `npm ci` in the worktree or skip node-dependent verification and let the orchestrator verify after merge. Before any agent or task mutates frontend dependencies, confirm the dev server is stopped."
- **Section**: ~/.claude/rules/agent-coordination.md → Worktree Protocol
- **Rationale**: Prevents destroying the main checkout's installed dependencies during worktree cleanup and avoids breaking a live dev server during dependency changes.

### [APPROVED] (2026-06-11) #012 WeddingAssistant: worktree setup needs .env copy and isolated test DBs
**Resolution:** Added as the first bullet of "Local dev orchestration" in `~/source/WeddingAssistant/CLAUDE.md`. Uncommitted in that repo.

- **Source**: wrap-up
- **Date**: 2026-06-10
- **Signal**: Both backend worktree agents independently discovered that a fresh worktree lacks the gitignored `.env` (Django fails to boot: AI provider slot not registered) and that parallel pytest runs collide on the shared `test_weddingassistant` database (one agent had to invent a custom DATABASE_URL).
- **Proposal**: Add to project CLAUDE.md (Local dev orchestration section): "Git worktrees: copy `.env` from the main checkout before running Django (`cp <main>/.env .env`). Parallel test runs against the same Postgres must use distinct databases — set `DATABASE_URL` with a unique db name per worktree (pytest derives `test_<name>`)."
- **Section**: WeddingAssistant CLAUDE.md → Local dev orchestration
- **Rationale**: Every future worktree agent hits both issues; documenting saves repeated rediscovery and avoids cross-agent test-DB interference.

### [APPROVED] (2026-07-03) #2026-06-11-jm-ms-a Plans must cite route/file paths verbatim from the tree
**Resolution:** Added to `~/.claude/CLAUDE.md` → Planning → Execution Workflow ("Plan authoring quality" note).
- **Source**: wrap-up
- **Date**: 2026-06-11
- **Signal**: The card-deep-linking plan wrote frontend routes as `(app)/w/[id]/...` but the real tree is `(dashboard)/w/[weddingId]/...`. The orchestrator had to pre-declare this drift in all three frontend subagent prompts; one subagent also found an anchor cited at settings/page.tsx:216 that actually lives in wedding-form.tsx:216.
- **Proposal**: Add to user CLAUDE.md → Planning → Execution Workflow: "Plans must cite file and route paths verbatim from the tree (verify with `ls`/glob at authoring time, including Next.js route-group segments) — never reconstruct paths from memory. A wrong path in a plan propagates to every executing subagent."
- **Section**: ~/.claude/CLAUDE.md → Planning → Execution Workflow
- **Rationale**: Path drift is the one defect class that recurred across every frontend phase this session; verbatim citation at plan time eliminates per-agent corrections.

### [APPROVED] (2026-07-03) #2026-06-19-jm-ms-a Lead with open-ended questions when diagnosing visual/UI issues
**Resolution:** Added to `~/.claude/rules/coding-standards.md` → Frontend / UI.
- **Source**: wrap-up
- **Date**: 2026-06-19
- **Signal**: During live UI tuning, the user twice rejected an AskUserQuestion (chose "let me clarify") on visual-diagnosis questions, then gave richer observations in their own words than the offered options captured ("two overlapping bubbles", "refraction off to the right"). Those observations pinned the root causes (specular dup, backdrop-filter+transform) faster than the multiple-choice hypotheses.
- **Proposal**: Add to coding-standards.md "Frontend / UI": "When diagnosing a visual/UI issue during live tuning, first ask the user to describe what they observe in their own words (open-ended); only offer structured multiple-choice (AskUserQuestion) once the symptom is pinned down. Prefer making a small change and showing it over asking the user to choose between competing hypotheses."
- **Section**: coding-standards.md → Frontend / UI
- **Rationale**: The user iterates against the real app; open-ended observation surfaced root causes faster and avoided rejected tool calls.

### [APPROVED] (2026-07-03) #2026-06-20-jm-ms-a Subagents must stage explicit paths, never `git add -A`/`commit -a`
**Resolution:** Added "Committing from Subagents" section to `~/.claude/rules/agent-coordination.md`.
- **Source**: wrap-up
- **Date**: 2026-06-20
- **Signal**: During subagent-driven execution (kika Stage 2), two writer subagents had in-progress edits in the shared working tree concurrently; one ran `git add -A`/`git commit -a` and swept the other's uncommitted changes into a single mixed commit (later untangled via soft-reset, verified byte-identical). A subagent also misdiagnosed this as an "auto-commit hook" — the PostToolUse `checkpoint-notify.sh` only prints a banner, it never commits.
- **Proposal**: Add to agent-coordination.md: "Subagents that commit MUST stage only their own explicit file paths (`git add <path> ...`), NEVER `git add -A` / `git add .` / `git commit -a`. On a shared working tree those sweep concurrent agents' in-progress edits into one mixed commit. For atomic isolation of parallel writers, use `isolation: \"worktree\"`. Also: verify any 'a hook did X' diagnosis against the actual hook script before acting on it."
- **Section**: agent-coordination.md (new "Committing from subagents" note, near Worktree Protocol)
- **Rationale**: Prevents the mixed-commit failure mode even when writers briefly overlap — a cheap, deterministic guard complementing the existing worktree-isolation guidance.

### [APPROVED] (2026-07-03) #2026-06-22-jm-ms-a Verify UI animations IN MOTION, not just at rest
**Resolution:** Added to `~/.claude/rules/coding-standards.md` → Frontend / UI.
- **Source**: wrap-up
- **Date**: 2026-06-22
- **Signal**: I verified a drop-icon centering fix with static rest-state checks (DOM-position probe + screenshots of the settled drop) and reported it "centered/fixed" on both engines. The user, watching the live animation, caught that the icon is off-center DURING travel and then snaps to center abruptly on arrival ("as if we just slapped the icon on the center") — a motion→rest discontinuity that rest-state verification structurally cannot detect. The root cause was an approach (resize-on-settle: transform-scale during motion → instant swap to real layout at settle) that is correct at rest but discontinuous in transit.
- **Proposal**: Add to coding-standards.md "Frontend / UI": "When verifying an animation, transition, or morph, check the IN-MOTION behavior, not only the start/end states — capture mid-animation frames (sample a few times during the transition) and watch the settle for discontinuities (snaps/pops). A fix that measures correct at rest can still be visibly wrong in transit; rest-only verification (static screenshots, settled DOM positions) cannot catch it. Be especially wary of approaches that switch mechanisms between motion and rest (e.g. transform during motion vs. real layout at rest) — the switch point is where pops appear."
- **Section**: coding-standards.md → Frontend / UI
- **Rationale**: The defect that slipped through this session was invisible to rest-state checks by construction; mandating in-motion verification closes that gap and would have caught the snap before claiming success.

### [APPROVED] (2026-07-03) #2026-06-23-jm-ms-a Ruff verification (and phase briefs) must cover ALL touched files, including tests
**Resolution:** Generalized (not the WeddingAssistant-specific wording) and added to `~/.claude/rules/coding-standards.md` → Tools.
- **Source**: wrap-up
- **Date**: 2026-06-23
- **Signal**: During Step 5c subagent-driven-development, the Phase 3 verify ran `ruff check apps/guests/loop.py` (primary module only). The new `apps/guests/tests/test_loop.py` had an E501 + a format deviation that ruff would fix — both slipped past the per-phase gate and were only caught at the final whole-branch verify, costing an extra fix+commit (`472fc103`).
- **Proposal**: Add to the project CLAUDE.md "Development Standards → Python/Django" (near the ruff/pytest line): "Ruff verification (`ruff check` / `ruff format --check`) must cover EVERY file a change touches — source AND tests/migrations — not just the primary module. When a phase/subagent brief lists ruff targets, enumerate all touched files (e.g. the test file too), or run `ruff check`/`format --check` on the diff's full file set."
- **Section**: Development Standards → Python/Django (project CLAUDE.md)
- **Rationale**: Test/migration files are real lint surfaces; scoping ruff to the main module lets E501/format errors reach the merge gate where they cost an extra cycle. Enumerating all touched files in the verify step closes the gap cheaply and makes per-phase gates trustworthy.

### [APPROVED] (2026-07-03) #2026-06-23-jm-ms-a Treat plan/sample code as review-grade for security
**Resolution:** Added to `~/.claude/CLAUDE.md` → Planning → Execution Workflow ("Plan authoring quality" note).
- **Source**: wrap-up
- **Date**: 2026-06-23
- **Signal**: During subagent-driven execution, implementers transcribe plan code verbatim. The Argus plan's sample code contained a credential-leaking log line (logged full RTSP URL with user:password), an XSS sink (innerHTML with interpolated event data), and a loose SQLite column type (track_id as REAL). All three shipped as real defects and were caught only by per-task/security review — three separate security/correctness fixes in one session.
- **Proposal**: Add under "Planning → Execution Workflow": "Plan/sample code is transcribed verbatim by implementers, so it must be review-grade. When authoring a plan, never include security anti-patterns in sample code: don't log full URLs/secrets (redact userinfo), don't build DOM via innerHTML with interpolated data (use textContent/createElement), and type persistence columns to match their domain types. Self-review the plan's code for these before handing it off."
- **Section**: Planning → Execution Workflow (CLAUDE.md)
- **Rationale**: In verbatim-transcription workflows, a defect in the plan is a defect in production. Catching these at plan-authoring time is cheaper than a per-task fix + re-review cycle for each.

### [APPROVED] (2026-07-03) #2026-06-26-jm-ms-a `log` is shadowed by a shell function — use `/usr/bin/log` for unified-log queries
**Resolution:** Added to `~/.claude/rules/coding-standards.md` → Tools.
- **Source**: wrap-up
- **Date**: 2026-06-26
- **Signal**: While diagnosing a WindowServer crash, every `log show ...` call returned empty/`(eval):log:1: too many arguments`. The user's shell config defines a `log` function that shadows the `/usr/bin/log` binary. Several diagnostic queries silently produced no output before this was spotted, wasting iterations.
- **Proposal**: Add to coding-standards.md "Tools": "On macOS, `log` is shadowed by a shell function in this user's profile — always call the unified-logging tool by absolute path (`/usr/bin/log show ...`), never bare `log`, or queries silently fail with `too many arguments`."
- **Section**: Coding Standards → Tools (coding-standards.md)
- **Rationale**: Bare `log` fails silently (empty results, not an error), which is easy to misread as "no log data" and send diagnosis down a wrong path. Absolute path is a one-token fix that makes log forensics reliable.

### [APPROVED] (2026-07-03) #2026-06-26-jm-ms-b Scope static-check guard tests to executable lines so hazards can still be named in comments
**Resolution:** Added to `~/.claude/rules/coding-standards.md` → Code Hygiene.
- **Source**: wrap-up
- **Date**: 2026-06-26
- **Signal**: A regression test asserted a hook never references `terminal-notifier` by grepping the WHOLE file. That also banned the literal from the file's own warning comment, forcing the "do not reintroduce terminal-notifier" hazard note to be reworded into something vaguer. Caught in final review; required an extra hardening commit to scope the grep to non-comment lines and restore the explicit name.
- **Proposal**: Add to coding-standards.md "Code Hygiene": "When a guard/regression test forbids a literal token in a file (grep-based static check), scope the grep to executable lines (e.g. `grep -vE '^[[:space:]]*#'` first) — otherwise the file cannot document the very hazard it guards against by name. The comment that names the hazard is a feature, not a violation."
- **Section**: Coding Standards → Code Hygiene (coding-standards.md)
- **Rationale**: A static check that also gags the documentation of its own hazard weakens the human signal in exactly the file most likely to be edited later. Scoping the grep keeps enforcement strict while letting the warning name the offender.

### [APPROVED] (2026-07-03) #2026-07-02-jm-ms-a Clarify NumPy docstring requirement (Parameters/Returns threshold)
**Resolution:** Modified the Python docstring line in `~/.claude/rules/coding-standards.md`.
- **Source**: wrap-up
- **Date**: 2026-07-02
- **Signal**: coding-standards.md says "NumPy-style docstrings for public functions" but does not say whether every function needs full Parameters/Returns sections. During subagent-driven implementation this ambiguity produced a review loop (a 6-parameter function was flagged Important for a prose-only docstring) and forced a mid-execution convention decision that then had to be injected into every subsequent task dispatch.
- **Proposal**: In coding-standards.md under Python, change "NumPy-style docstrings for public functions" to "NumPy-style docstrings on public functions; include Parameters/Returns (Attributes for dataclasses) when the function/class takes 2+ non-obvious parameters, otherwise a concise summary docstring suffices."
- **Section**: coding-standards.md -> Python
- **Rationale**: Removes a recurring ambiguity that generated review churn; sets an unambiguous, proportionate bar so implementers and reviewers agree up front.

### [APPROVED] (2026-07-24) #2026-07-03-jm-ms-a A tracker ticket describing intended work is not proof it shipped — verify against source before documenting
- **Source**: wrap-up
- **Date**: 2026-07-03
- **Signal**: During the kika retrospective, reconciling CLAUDE.md against KIK issue titles nearly wrote a false version into the doc. KIK-4 "Upgrade to Django 6" was Done and `pyproject.toml` confirmed `django>=6.0` (real drift, fixed) — but KIK-14 "Change Postgres version to 18" was stage *Review* and `docker-compose.yml` still ran `postgres:15-alpine`, so "Postgres 18" was NOT yet true. Reading the actual pins/config instead of trusting the ticket titles prevented documenting an unmerged change as done.
- **Proposal**: Add to ~/.claude/CLAUDE.md → Planning → Execution Workflow ("Plan authoring quality"): "When documenting or reconciling project state from a tracker (issues/tickets), a ticket describing intended work is not evidence it merged. Verify each claim against the authoritative source (dependency pins, config files, running code) AND the ticket's resolved/merged state before writing it into docs — never from the ticket title/summary alone."
- **Section**: ~/.claude/CLAUDE.md → Planning → Execution Workflow
- **Rationale**: Retrospective and status-doc work is exactly where ticket-vs-reality drift produces false documentation; this prevented a concrete error this session and generalizes the verbatim-source-citation principle to version/state claims.

### [APPROVED] (2026-07-24) #2026-07-23-jm-ms-a Plan-literal code should pass ruff as-written
- **Source**: wrap-up
- **Date**: 2026-07-23
- **Signal**: In the interior-model plan execution, ~5 of 10 tasks needed the implementer to reformat brief-literal code to satisfy ruff before committing: mid-file `from ... import ...` statements (E402) and `l` loop variables (E741, e.g. `tuple(l.name for l in levels)`). Every reformat is a spec deviation the reviewer must then re-verify as semantics-preserving.
- **Proposal**: Add to the "Plan authoring quality" section of CLAUDE.md: "Write plan-literal code so it passes the project's linter as-written — put all imports in the target file's top import block (never mid-file, even in an append-only task; tell the implementer which import to add to the existing block), and avoid ambiguous single-char names (`l`/`I`/`O`) in sample code. A reformat-before-commit is a spec deviation the reviewer must re-verify."
- **Section**: Plan authoring quality (Planning → Execution Workflow)
- **Rationale**: Removes a recurring per-task reformatting step and the re-verification it forces, keeping brief-literal code byte-identical to what lands.

### [APPROVED] (2026-07-24) #2026-06-11-jm-ms-b Recover dead implementation subagents via continuation agents, not relaunch
- **Source**: wrap-up (recovered from stash@{1}, 2026-07-04)
- **Date**: 2026-06-11
- **Signal**: Two long-running implementation subagents died on server-side API errors mid-phase (liquid_glass_ui Phases 4 and 5). Both times substantial uncommitted work was already on disk; a fresh "continuation agent" instructed to treat the inherited diff as unverified (read it, scrutinize, fix, then run the full verification suite) recovered each phase without redoing implementation. Phase 4's continuation agent caught a real bug (clone typography inheritance) the original would have shipped.
- **Proposal**: Add to agent-coordination.md: "If an implementation subagent dies mid-task (API error, timeout), do NOT relaunch its original prompt. First inspect the working tree (`git status`/`git diff --stat`) for partial work, then dispatch a continuation agent whose prompt: (1) states the previous agent died and its diff is unverified, (2) requires reading the inherited diff with suspicion before extending it, (3) carries the original acceptance criteria and verification checklist."
- **Section**: agent-coordination.md (new subsection "Dead-agent recovery")
- **Rationale**: Relaunching from scratch wastes the partial work and risks conflicting double-implementation; trusting the partial work blindly ships unverified code. The continuation pattern was validated twice in one session.

### [APPROVED] (2026-07-24) #2026-06-28-jm-mbp-2-a Verify the actually-served artifact before re-debugging a "fix that didn't take"
- **Source**: wrap-up (recovered from stash, 2026-07-24)
- **Date**: 2026-06-28
- **Signal**: A correct iOS-Safari hero fix appeared "still broken" for ~6 device-test rounds. Root cause was never the code — `make up-phone-prod` is PROD mode (no hot reload) and the running `next-server` kept serving a frozen pre-fix build. Time was spent re-debugging correct source instead of checking what was being served.
- **Proposal**: Add to the debugging guidance (global CLAUDE.md / rules): "When a fix appears not to take effect (especially on a device, another browser, or any no-hot-reload / cached / CDN context), FIRST verify the actually-served artifact before re-debugging the source — e.g. `curl` the served HTML/CSS/JS chunk and grep for your change, check the server process restarted (PID changed), or load in a private/cacheless window. Treat 'looks unchanged' as 'possibly stale build/cache' until proven otherwise. Do not start a new code hypothesis until the served build is confirmed to contain the change."
- **Section**: Debugging / verification (near systematic-debugging guidance)
- **Rationale**: Stale-build/cache masquerading as a broken fix is a high-cost, recurring failure mode for device/browser-tested frontend work; a one-line server/artifact check converts ~6 wasted rounds into seconds.

### [PENDING] #2026-07-24-jm-ms-a Don't route sudo / password-prompting commands through the `!` prefix or Bash tool
- **Source**: wrap-up
- **Date**: 2026-07-24
- **Signal**: Recommended the user run `! sudo pmset -a sleep 0`; it failed with `sudo: a terminal is required to read the password`. The `!` passthrough (and the non-interactive Bash tool) run without a TTY, so any command that prompts for a password mid-execution (sudo, `ssh` host-key confirmation, etc.) cannot complete. Cost a round-trip. Note this nuances the existing environment guidance that suggests `!` for interactive commands — it works for browser/redirect flows (`gcloud auth login`) but NOT for in-terminal password prompts.
- **Proposal**: Add to global CLAUDE.md (or rules): "Commands that prompt for a password or other interactive input during execution (`sudo …`, first-time `ssh`, etc.) cannot run through the `!` prefix or the Bash tool — both run without a TTY, so the prompt fails with 'a terminal is required.' When a fix needs sudo, give the user the exact command to run in a real terminal window, or use the GUI/computer-use equivalent — do not suggest it via `!`. Read-only sudo-free checks (e.g. `pmset -g`) are fine via `!`."
- **Section**: Global CLAUDE.md — Communication Style / harness usage, or rules/workflow.md
- **Rationale**: Prevents recommending a command that's guaranteed to fail, and directs the user to a path that actually works on the first try.
### [PENDING] #2026-07-24-jm-mbp-2-a Document the dual-remote reality: gitea is authoritative, GitHub is a checkpoint mirror
- **Source**: wrap-up
- **Date**: 2026-07-24
- **Signal**: Project CLAUDE.md's Git section says only "Branch strategy: main > staging > develop > feature/*" and "PR requires tests + review" — it never mentions that the repo has TWO remotes with different roles. This session began by pulling GitHub and treating it as authoritative; `gitea/develop` turned out to be **140 commits ahead** of `origin/develop` (all teammate work: KIK-83/94/98/99/100/105/107/109/111). A stored memory compounded it by asserting the remotes were "kept MIRRORED/in-sync", which is false. The owner also had to state mid-session "we will push via PR, we cant touch develop directly" — a load-bearing constraint absent from the docs.
- **Proposal**: Replace the project CLAUDE.md `### Git` section body with: "- Branch strategy: main > staging > develop > feature/*\n- **TWO remotes, different roles — they are NOT mirrored.** `gitea` = `gitea:plisa/kika.git` (host `10.5.5.103`, web/API `https://git.depotelas.net`, org `plisa`) is the **authoritative** remote: teammate PRs merge into `develop` there. `origin` = `git@github.com:jmmas123/kika.git` is the owner's personal checkpoint mirror; feature branches are freely force-pushed there after rebasing.\n- **`develop` is PR-only** — nobody pushes to it directly. Integrate by rebasing the feature branch onto `gitea/develop`, pushing the branch to `gitea`, and opening a PR.\n- At session start fetch **both** remotes; diff feature branches against `gitea/develop`, never `origin/develop`, or you will misjudge what is already merged.\n- Expect owner branches on `origin` to have been rebased + force-pushed from another machine. Before assuming local commits are unique work, compare commit *subjects* (a rebase preserves messages, changes SHAs) and `git patch-id --stable`; tag `local-backup/<branch>-<date>` before resetting.\n- Atomic commits, clear messages. PR requires tests + review.\n- Never commit secrets or .env files"
- **Section**: project CLAUDE.md → `### Git`
- **Rationale**: The single highest-cost gap this session. Without it, a fresh session diffs against the wrong baseline, concludes work is unmerged when it shipped days ago, and may propose pushing to `develop` — which the owner cannot do. Encoding "gitea authoritative + PR-only + expect force-pushed rebases" turns a 20-minute forensic reconstruction into a read.

### [PENDING] #2026-07-24-jm-mbp-2-b zsh is the shell — avoid bash-only scripting idioms in Bash tool calls
- **Source**: wrap-up
- **Date**: 2026-07-24
- **Signal**: Two Bash calls failed this session on zsh/bash differences, each costing a retry: (1) `status=$(...)` → `(eval):8: read-only variable: status` (zsh reserves `status` as an alias for `$?`); (2) `for m in "app 0028_x"; do set -- $m` silently did NOT word-split, so `$1` got the whole string and `$2` was empty, producing malformed output that looked like a tool failure. zsh does not word-split unquoted parameter expansions by default.
- **Proposal**: Add to `~/.claude/rules/coding-standards.md` under `## Tools`: "The shell is **zsh**, not bash. Avoid bash-only idioms in Bash tool calls: (a) never assign to `status`, `path`, `argv`, or `pipestatus` — zsh reserves them (`status` is read-only and aborts the call); (b) zsh does not word-split unquoted expansions, so `set -- $var` / `for x in $var` will not split on spaces — use an explicit array (`arr=(${=var})`) or `read -A`; (c) unmatched globs abort the command rather than passing through literally — quote patterns like `ls ~/.gitea*` or they fail with 'no matches found'."
- **Section**: `~/.claude/rules/coding-standards.md` → `## Tools`
- **Rationale**: Each of these fails in a way that mimics a real error (read-only abort, empty variable, no-match abort) rather than an obvious syntax problem, so the failure gets debugged as a tool/data issue. Three one-line rules prevent a recurring class of wasted round-trips; the file already carries a macOS-specific `log`-shadowing note, so this is the established home for shell-environment gotchas.

### [PENDING] #2026-07-24-jm-mbp-2-c Flag coupled instructions BEFORE executing, not after
- **Source**: wrap-up
- **Date**: 2026-07-24
- **Signal**: Owner said "merge it and update the PR title/body". Executed literally: merged locally, rewrote PR #64's body to describe 5 tickets / 43 commits — but did not push, since push wasn't asked for and the project convention is push-only-when-asked. Net result was a PR that READ as 43 commits while SHOWING 31. I flagged the mismatch only after creating it; the owner then had to say "push it" as a third turn.
- **Proposal**: Add to CLAUDE.md "Communication Style": "When an instruction's literal execution would leave a shared or outward-facing artifact in a self-inconsistent state (a PR body describing unpushed commits, a doc citing an unmerged branch, a changelog ahead of a release), say so BEFORE executing and name the one extra step that would resolve it. Do not execute-then-flag: an inconsistent public artifact, however briefly, is worse than one clarifying question."
- **Section**: Communication Style
- **Rationale**: The information needed to predict the inconsistency was fully available before acting. Flagging first costs one sentence; flagging after costs a visibly wrong artifact plus an extra round trip. Distinct from the existing conversational-not-questioncards preference — this is about sequencing a warning, not about how to ask.

### [PENDING] #2026-07-24-jm-mbp-2-d Verify file writes by reading back, never by unconditional echo
- **Source**: wrap-up
- **Date**: 2026-07-24
- **Signal**: A ledger append used a relative path while the shell's cwd was still `frontend/` (carried over from an earlier `cd frontend && ...` — cwd persists between Bash calls unless a git command resets it). The heredoc failed with "no such file or directory", but the command ended in a newline-separated `echo ok`, which ran regardless and printed "ok". The failure was invisible until I re-read the output carefully; the ledger entry was silently lost and had to be rewritten.
- **Proposal**: Add to CLAUDE.md "Tools": "Never confirm a file write with a hardcoded `echo ok` — a newline- or `;`-separated echo runs even when the write failed. Confirm by reading back what was written (`tail -3 <file>`, `wc -l <file>`) so the output proves the result. Use ABSOLUTE paths for appends to scratch/ledger/state files: cwd persists across Bash calls (it only resets after a git command), so a relative path silently targets whichever directory the previous command left you in."
- **Section**: Tools (coding-standards.md)
- **Rationale**: Silent write failures are the worst class of tool error — they look like success and are only caught by chance. Both halves (read-back verification, absolute paths) are one-token changes that make the failure mode impossible. The cwd-persistence half extends an existing note in the project CLAUDE.md that currently only covers the git-resets-cwd direction.

### [PENDING] #2026-08-04-jm-mbp-2-a When results don't reproduce, hunt the hidden variable before rebuilding the artifact
- **Source**: wrap-up
- **Date**: 2026-08-04
- **Signal**: Debugging a custom macOS aerial wallpaper, the SAME video file produced different unlock behaviour on different attempts ("ramps down" once, "frozen" the next, "black" a third time). I treated each single lock/unlock observation as a verdict on the hypothesis under test and rebuilt the video ~15 times around those readings — varying resolution, colour range, PAR, GOP, frame rate, bit depth, B-frames, encoder and splicing. The actual cause was environmental: the desktop was configured `shuffleFrequency: shuffle_on_wakeup` in `~/Library/Application Support/com.apple.wallpaper/Store/Index.plist`, which fires a random rotation on every unlock. One `plutil -p` of the consuming app's config, available from minute one, would have shown it. Hours lost.
- **Proposal**: Add to `~/.claude/rules/workflow.md` under "During Work": "### Non-reproducible results mean a hidden variable, not a stubborn bug\n\nIf the same input produces different outcomes across attempts, STOP changing the artifact. Non-determinism is evidence that something outside your model is varying — read the consuming system's configuration (plists, env, feature flags, scheduler/rotation settings, caches) before forming another hypothesis about the artifact itself. Also: never accept or reject a hypothesis on a single observation from a process you have not established is deterministic. Establish determinism first — same input, same output, twice — then test."
- **Section**: `~/.claude/rules/workflow.md` → During Work
- **Rationale**: This is the highest-cost failure mode of the session by an order of magnitude, and it is fully generalizable — a randomised consumer will make any artifact look intermittently broken. The existing "Verifying a fix took effect" rule covers stale artifacts (is the new thing running?) but not stale *reasoning* (is my test even repeatable?). The two are complementary and belong together.

### [PENDING] #2026-08-04-jm-mbp-2-b Never combine `nohup ... &` with the Bash tool's own backgrounding
- **Source**: wrap-up
- **Date**: 2026-08-04
- **Signal**: Two long ffmpeg encodes were launched as `nohup ffmpeg ... &` inside a Bash call that ALSO had `run_in_background: true`. Both were orphaned and killed mid-write, and both reported **exit code 0** while leaving a truncated file (`moov atom not found`, 13 MB and 154 MB of an expected ~180 MB). The success exit code made the first failure look like a valid result until the output was probed.
- **Proposal**: Add to `~/.claude/rules/coding-standards.md` under `## Tools`: "When using the Bash tool's `run_in_background`, do NOT also background inside the command (`&`, `nohup`, `disown`) — the harness already detaches it, and doubling up orphans the process, which is then killed mid-write while the call reports exit 0. A truncated output plus a success code is the signature. For long jobs: use `run_in_background` alone, or run in the foreground with an explicit `timeout`, and always verify the artifact (parse it, check its duration/size) rather than trusting the exit code."
- **Section**: `~/.claude/rules/coding-standards.md` → Tools
- **Rationale**: Silent-success-with-corrupt-output is the same failure class as the existing `echo ok` proposal (#2026-07-24-jm-mbp-2-d) and belongs beside it. It cost two ~10-minute encodes plus the debugging time to notice the files were invalid.
