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
- On macOS, `log` is shadowed by a shell function in this user's profile — call the unified-logging tool by absolute path (`/usr/bin/log show …`), never bare `log`, or queries silently fail with `too many arguments`

## Code Hygiene
- Prefer editing existing files over creating new ones
- Atomic commits — one logical change per commit
- No unnecessary abstractions or over-engineering
- When a guard/regression test forbids a literal token via a grep-based static check, scope the grep to executable lines (e.g. `grep -vE '^[[:space:]]*#'` first) — otherwise the file cannot document the very hazard it guards against by name

## Frontend / UI
When picking a modern CSS feature for production UI (`backdrop-filter: url()`, `feDisplacementMap`, `paint-order` on text, container queries, `:has()`, etc.), verify Safari + Firefox + iOS support with WebSearch or caniuse before committing. State the cross-browser story in your first response, not after iteration. If the feature is Chromium-only, name it explicitly and ask whether graceful degradation is acceptable for the user's audience.

When diagnosing a visual/UI issue during live tuning, first ask the user to describe what they observe in their own words (open-ended); only offer structured multiple-choice (AskUserQuestion) once the symptom is pinned down. Prefer making a small change and showing it over asking the user to choose between competing hypotheses.

When verifying an animation, transition, or morph, check the IN-MOTION behavior, not only the start/end states — sample a few mid-animation frames and watch the settle for discontinuities (snaps/pops). A fix that measures correct at rest can still be visibly wrong in transit; rest-only verification (static screenshots, settled DOM positions) cannot catch it. Be especially wary of approaches that switch mechanisms between motion and rest (e.g. transform during motion vs. real layout at rest) — the switch point is where pops appear.
