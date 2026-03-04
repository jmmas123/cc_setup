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
