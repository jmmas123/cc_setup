# NASA Power of 10 — Translated

**Source:** Holzmann, G. J. (2006). "The Power of 10: Rules for Developing Safety-Critical Code." *IEEE Computer*, 39(6), 95-97. JPL Laboratory for Reliable Software.

**Citation tag for findings:** `NASA-P10-#N` where `N` is the rule number (1-10).

**Translation philosophy:** Rules 1-3 transfer almost literally. Rules 4-6 transfer with minor adaptation. Rules 7-10 are C-specific (memory, preprocessor, pointers, compiler warnings) — for Python/JS we apply the *spirit* (boundedness, no metaprogramming abuse, no late binding tricks, all linter warnings as errors).

---

## Rule table

| ID | Original rule (one-line) | Python/Django translation | JS/TS translation | HTML/template translation |
|----|--------------------------|---------------------------|-------------------|---------------------------|
| #1 | Restrict all code to very simple control-flow constructs — no `goto`, `setjmp`/`longjmp`, no recursion. | No recursion (use iteration with a bounded stack); no `sys.settrace` games; no exceptions used as control flow across module boundaries. | No recursion (or prove tail-bounded); no `eval`, no `with` statement; no exceptions across `await` boundaries as flow. | Avoid template recursion (e.g., Django `{% include %}` self-include or Jinja recursive macros) without a hard depth limit. |
| #2 | All loops must have a fixed upper bound, statically provable. | Every `for` over an iterator has a known max length, or wrap with `itertools.islice(it, MAX)`; never `while True:` without an explicit counter `for _ in range(MAX_ITERS)`. | Every `for`/`while` has a literal/constant bound; reject `while(true)` without a `break` driven by a bounded counter. | Loops in templates (`{% for %}`, `{#each}`) must iterate over server-bounded collections; no client-side loops over user-supplied counts without a cap. |
| #3 | Do not use dynamic memory allocation after initialization. | Spirit: avoid unbounded growth at runtime — no `list.append` in hot loops without a `maxlen`; prefer `collections.deque(maxlen=N)`; pre-size buffers; cap LRU caches. | Spirit: avoid unbounded `Array.push`/`Map.set` in hot paths; pre-allocate typed arrays; cap caches/queues with explicit eviction. | Spirit: do not dynamically inject unbounded numbers of DOM nodes; use virtualized lists (`react-window`, etc.) for collections > N. |
| #4 | No function should be longer than what fits on a single sheet (~60 lines). | Functions ≤ 60 lines (excluding docstring); split otherwise. | Functions ≤ 60 lines; split otherwise. React components ≤ 60 lines of JSX body. | Template partials/components ≤ 60 lines; extract sub-templates. |
| #5 | The assertion density of code should average ≥ 2 assertions per function. Assertions must be side-effect-free and used for anomaly detection, not normal control flow. | ≥ 2 `assert` per non-trivial function (or explicit `if not X: raise`); side-effect free; not used for input validation in production paths (use explicit raises). | ≥ 2 invariant checks per non-trivial function (use `console.assert` in dev, explicit `throw` in prod); never `assert(sideEffect())`. | n/a for static markup. For template logic, every `{% if %}` guard on a security-sensitive branch should have a paired explicit branch (no implicit else fall-through). |
| #6 | Data objects must be declared at the smallest possible scope. | No module-level mutable globals; declare variables at narrowest scope; avoid Django `request._cache` smuggling. | `let`/`const` (never `var`); declare at narrowest block scope; no module-level mutable singletons. | Template variables scoped to the smallest block (`{% with %}` over module-level context pollution). |
| #7 | The return value of non-void functions must be checked, and the validity of parameters must be checked inside each function. | Every function call whose return signals failure must be checked (no bare `subprocess.call`; use `check=True` or inspect `returncode`); validate every parameter at function entry (type + range + invariants). | Check every Promise (`await` or explicit `.catch`); never ignore a returned `Result`/`Error`; validate parameters at function entry (zod/io-ts or explicit guards). | n/a for HTML; for template tags/filters: validate inputs in the tag body, never assume safe HTML without `mark_safe`/`safe` review. |
| #8 | Use of the preprocessor must be limited. (No `#define` macros for control flow, no token pasting, no recursive macros.) | Spirit: limit metaprogramming — no `exec`/`eval` on user data, no dynamic class creation in hot paths, no monkey-patching across module boundaries; decorators must be simple and documented. | Spirit: limit metaprogramming — no `eval`, no `Function()` constructor, no Proxy traps for control flow, no Babel macros that change semantics; TS decorators must be experimental-stage-explicit and documented. | Spirit: limit dynamic template generation — no string-concatenated template source; use the template engine's compile API, not `eval`. |
| #9 | Use of pointers should be restricted. No more than one level of dereferencing. Function pointers are not permitted. | Spirit: avoid deep attribute chains (`a.b.c.d.e`) — destructure or extract intermediate; avoid storing functions in dicts as a control-flow dispatch unless the dispatch table is small and documented. | Spirit: avoid deep optional chains (`a?.b?.c?.d?.e`) — flatten; avoid dynamic function dispatch via string keys without a typed registry. | Spirit: avoid deeply nested template variable lookups (`{{ a.b.c.d.e }}`); flatten in the view/controller. |
| #10 | All code must be compiled with all warnings enabled at the most pedantic setting. All warnings must be addressed before release. | All linters at strict mode: `ruff --select=ALL` (or curated max set), `mypy --strict`, `pyright --strict`; zero warnings; `python -W error`. | `tsc --strict`, `eslint` with `eslint:all` curated max, zero warnings; `--noUncheckedIndexedAccess`, `--exactOptionalPropertyTypes`. | `htmlhint`/`html-validate` at strictest config; CSS via `stylelint` strict; zero warnings. |

---

## Notes on translation choices

- **Rule 1 (recursion):** Python/JS allow recursion but the standard forbids it because stack-depth bounds are hard to prove. Translation: forbid recursion *unless* the developer documents the maximum depth and the depth is bounded by input data with a known cap.
- **Rule 3 (dynamic memory):** Literal C rule is "no `malloc` after init." In garbage-collected languages this is impossible to enforce literally, so the translation enforces the *intent*: bounded memory growth per request/iteration.
- **Rule 5 (assertions):** Python's `assert` is disabled with `-O`. For production safety-critical paths, prefer explicit `if not X: raise InvariantError(...)` over `assert`. The "≥ 2 per function" density holds either way.
- **Rule 8 (preprocessor):** No direct equivalent in Python/JS. The spirit is "no language extensions that change semantics opaquely." Decorators, metaclasses, Proxies, and dynamic class creation are the closest analogues.
- **Rule 9 (pointers):** Python/JS have no raw pointers. The spirit is "minimize indirection." Deep attribute chains and dynamic dispatch tables are the analogues.

## How the reviewer agent uses this file

For each function in scope, walk the table top-to-bottom and ask "does this function violate this rule?" Tag findings as `NASA-P10-#N` with the rule number and a one-line description. Severity guidance:

- **High:** Rules 1, 2, 3, 7 violations (control flow / boundedness / unchecked errors) → can cause crashes or unbounded resource use.
- **Medium:** Rules 4, 5, 6, 9, 10 violations → maintainability and correctness risk.
- **Low:** Rule 8 violations in non-hot paths → style/clarity.
