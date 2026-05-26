# Coding Standards (Auto-Loaded)

These apply to ALL projects.

## Python
- Type hints (PEP 484) on all function signatures
- NumPy-style docstrings for public functions
- Use `logging` module, not print statements
- No hardcoded secrets — use environment variables

## Tools
- Use `uv` over pip when available
- Use `rg` (ripgrep) for searching
- Use `gh` CLI for GitHub operations
- Prefer `pytest -xvs` for debugging tests

## Code Hygiene
- Prefer editing existing files over creating new ones
- Atomic commits — one logical change per commit
- No unnecessary abstractions or over-engineering

## Frontend / UI
When picking a modern CSS feature for production UI (`backdrop-filter: url()`, `feDisplacementMap`, `paint-order` on text, container queries, `:has()`, etc.), verify Safari + Firefox + iOS support with WebSearch or caniuse before committing. State the cross-browser story in your first response, not after iteration. If the feature is Chromium-only, name it explicitly and ask whether graceful degradation is acceptable for the user's audience.
