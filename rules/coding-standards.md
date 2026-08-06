# Coding Standards (Auto-Loaded)

These apply to ALL projects.

## Python
- Type hints (PEP 484) on all function signatures
- NumPy-style docstrings on public functions; include Parameters/Returns (Attributes for dataclasses) when the function/class takes 2+ non-obvious parameters, otherwise a concise summary docstring suffices
- Use `logging` module, not print statements
- No hardcoded secrets — use environment variables

## Tools
- Use `uv` over pip when available
- Use `rg` (ripgrep) for searching
- Use `gh` CLI for GitHub operations
- Prefer `pytest -xvs` for debugging tests
- Lint/format checks (`ruff check` / `ruff format --check`) must cover EVERY file a change touches — source AND tests/migrations — not just the primary module. Enumerate all touched files, or run against the diff's full file set
- `rg -r` means `--replace`, NOT "recursive". `rg -rn 'foo'` rewrites every match to `n` and prints confident garbage that looks like real file content. Use `rg -n`. (Hit twice in one session, 2026-08-05.)
- On macOS, `log` is shadowed by a shell function in this user's profile — call the unified-logging tool by absolute path (`/usr/bin/log show …`), never bare `log`, or queries silently fail with `too many arguments`

## Code Hygiene
- Prefer editing existing files over creating new ones
- Atomic commits — one logical change per commit
- No unnecessary abstractions or over-engineering
- When a guard/regression test forbids a literal token via a grep-based static check, scope the grep to executable lines (e.g. `grep -vE '^[[:space:]]*#'` first) — otherwise the file cannot document the very hazard it guards against by name

## Naming (legibility over brevity)
Prefer descriptive variable names; a reader should not have to infer what a name holds. (kika reviewer, 2026-07-24.)
- **Avoid generic abbreviations** — especially `obj`, and likewise `o`, `tmp`, `val`, `res`, `data` when something more specific fits. Name a value after what it *is*: a DRF serializer method's instance parameter is `service` / `event` / `guest`, not `obj`; a resolved DB row is `asset`, not `a`.
- **Abbreviate only in the narrow, short-lived scopes the reviewer called out** — lambda / arrow-function parameters and similar one-line callbacks where the binding is obvious and consumed immediately (e.g. `.map((p) => …)`, `key=lambda e: e.starts_at`). Loop counters (`i`, `j`) are fine.
- Applies to Python and JS/TS alike. When editing a file that already uses `obj`-style names, rename them in the parts you touch rather than matching the old habit.

## Reuse & generalization (check before you duplicate)
Before writing code that resembles something already in the codebase, STOP and check whether a shared function / component / class / hook can serve both call sites. **The second occurrence is the trigger to generalize, not a license to copy-paste.**
- Applies most to render blocks and UI shells (a device frame, an overlay, a card wrapper), iteration/mapping/grouping logic, and serialization shapes — the moment the same block is needed a second time, extract it into a named, independently-testable unit and have both sites consume it.
- Balances against "no unnecessary abstractions" above: extract on the **2nd real occurrence** for reuse + testability; do NOT wrap a single caller in a speculative layer. This is about de-duplicating what already recurs, not pre-abstracting what might.
- When you catch yourself re-implementing a prior pattern, surface it: name the existing implementation, propose the shared unit, and prefer maintainability over a fast copy.
- Derived from kika (2026-07-08): two byte-identical hand-rolled phone frames (`guest-phone-card` + `site/phone-preview-card`) should have been one shared `PhoneFrame` from the second one on.

## Correctness & Completeness
Derived from real corrections (kika retrospective, 2026-07-03) — these are recurring AI failure modes; the goal is they never recur on any project.
- **Ship complete vertical slices, not scaffolding.** Don't commit UI wired to nothing, half-implemented flows (tokens minted but no email sent), or unused roles/models/config. Finish the slice end-to-end, or gate/remove the stub and file a tracked issue — never leave half-built work that looks done.
- **Right-size complexity to the app in front of you.** Favor the simplest structure that works; add config layers, env-class hierarchies, or dependency splits only when a concrete present need demands them. (This is about infrastructure/config — distinct from code-reuse extraction.)
- **No aspirational infrastructure.** Never reference, import, or advertise a security/infra feature that isn't actually active. Code and docs describe what *is* implemented, not the intended design — false security claims create unsafe assumptions.
- **Default-deny authorization.** Every server endpoint/view ships with an explicit authorization check; a missing one is review-blocking, not a nit.
- **Validate at the boundary.** Enforce domain/business constraints where input enters (serializers/handlers), not only at the model or UI. Sanitization (XSS/escaping) is not validation.

## Frontend / UI
When picking a modern CSS feature for production UI (`backdrop-filter: url()`, `feDisplacementMap`, `paint-order` on text, container queries, `:has()`, etc.), verify Safari + Firefox + iOS support with WebSearch or caniuse before committing. State the cross-browser story in your first response, not after iteration. If the feature is Chromium-only, name it explicitly and ask whether graceful degradation is acceptable for the user's audience.

When diagnosing a visual/UI issue during live tuning, first ask the user to describe what they observe in their own words (open-ended); only offer structured multiple-choice (AskUserQuestion) once the symptom is pinned down. Prefer making a small change and showing it over asking the user to choose between competing hypotheses.

When verifying an animation, transition, or morph, check the IN-MOTION behavior, not only the start/end states — sample a few mid-animation frames and watch the settle for discontinuities (snaps/pops). A fix that measures correct at rest can still be visibly wrong in transit; rest-only verification (static screenshots, settled DOM positions) cannot catch it. Be especially wary of approaches that switch mechanisms between motion and rest (e.g. transform during motion vs. real layout at rest) — the switch point is where pops appear.
