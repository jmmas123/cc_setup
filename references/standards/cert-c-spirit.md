# CERT C/C++ Coding Standard — Spirit, Translated

**Source:** Carnegie Mellon Software Engineering Institute, "SEI CERT C Coding Standard" (2016 edition with ongoing updates) and "SEI CERT C++ Coding Standard" (2016). https://wiki.sei.cmu.edu/confluence/display/c and /cplusplus. Categories: PRE, DCL, EXP, INT, FLP, ARR, STR, MEM, FIO, ENV, SIG, ERR, CON, MSC, POS, WIN.

**Citation tag for findings:** `CERT-<CAT-NN>` where `<CAT>` is the 3-letter category and `NN` is the rule number, OR `CERT-<CAT>-spirit` if applying the category's intent in a translated form.

**Translation philosophy:** CERT is a C/C++ standard. Many categories (memory management, signed/unsigned integer width, manual string buffer handling) have no literal Python/JS equivalent. We focus on the 6 categories whose *spirit* most directly maps to high-level languages: **INT** (integer correctness), **STR** (string/text handling), **MEM** (resource lifetime), **ERR** (error handling), **CON** (concurrency), **MSC** (miscellaneous correctness). For each, we translate the category-level intent into Python/JS signals.

---

## Category table

| Category | Original intent (CERT one-line) | Representative CERT rule(s) | Python translation | JS/TS translation | HTML/template translation |
|----------|----------------------------------|-----------------------------|--------------------|-------------------|---------------------------|
| **INT** (Integers) | Prevent integer overflow, signed/unsigned conversion errors, and truncation. | INT30-C: Ensure unsigned arithmetic does not wrap. INT31-C: Ensure conversions do not lose data. INT32-C: Ensure signed arithmetic does not overflow. | Python ints are arbitrary-precision (no overflow), but: validate `int(user_input)` against an explicit range; never trust JSON numbers without `min`/`max` bounds; beware silent `int`→`float` precision loss for IDs > 2^53; use `Decimal` for money. | JS numbers are float64 — IDs > `Number.MAX_SAFE_INTEGER` (2^53-1) silently lose precision. Use `bigint` or string IDs; validate ranges with zod `.int().min().max()`; never `parseInt(x)` without radix and bounds check. | n/a — HTML has no integer type. For form inputs: `<input type="number" min max step>` with server-side re-validation. |
| **STR** (Strings) | Handle strings safely — no buffer overflows, no encoding mismatches, no unsafe truncation. | STR30-C: Do not attempt to modify string literals. STR32-C: Do not pass a non-null-terminated character sequence. STR38-C: Do not confuse narrow and wide strings. | No buffer overflow risk in Python, but: always specify encoding explicitly (`open(path, encoding='utf-8')`, never default); validate string length bounds before storage; never `str.encode()` without an `errors=` policy; beware `str` vs `bytes` mixing. | Same: explicit encoding (`TextDecoder('utf-8', {fatal: true})`); enforce max-length on user strings before DB write; beware `String.fromCharCode` on user input creating control characters; UTF-16 surrogate pair handling (use `[...str]` not `str[i]`). | Always specify `<meta charset="utf-8">`; escape user-supplied strings in templates (mirrors OWASP A03); enforce `maxlength` on `<input>` and `<textarea>` plus server check. |
| **MEM** (Memory / Resources) | Allocate and free resources safely — no leaks, no double-free, no use-after-free. | MEM30-C: Do not access freed memory. MEM31-C: Free dynamically allocated memory when no longer needed. MEM34-C: Only free memory allocated dynamically. | Spirit applied to *resources* (file handles, sockets, locks, DB connections): always use `with` (context managers); never leave file handles dangling; close DB cursors; avoid circular refs that delay GC of resource-holding objects; use `weakref` where lifetime is ambiguous. | Same: always `try { ... } finally { resource.close() }` or `using` (TS 5.2+); release event listeners (`removeEventListener`); abort fetch on component unmount; close WebSocket/SSE on cleanup. | Cleanup on page unload: release `MediaStream`, close `EventSource`, revoke `URL.createObjectURL` blobs; avoid `<iframe>` that holds parent references after removal. |
| **ERR** (Error Handling) | Handle errors and exceptions explicitly; do not ignore return codes; preserve `errno`. | ERR30-C: Set `errno` to zero before calling library functions. ERR33-C: Detect and handle standard library errors. ERR50-CPP: Do not abruptly terminate the program. | Never bare `except:` or `except Exception: pass`; always log or re-raise; preserve `__cause__` with `raise ... from e`; check return values of `subprocess.run`, `requests.get`, `os.path.exists` (don't assume success); use `Result`-like patterns for fallible operations. | Never `catch(e) {}`; always `await` Promises or attach `.catch`; preserve `cause` via `new Error(msg, {cause: e})`; check HTTP status (`response.ok`); never swallow rejections in `Promise.all` (use `Promise.allSettled` if needed). | Display error states for every form/AJAX boundary; `<noscript>` fallback for JS-required features; never silently fail (e.g., disabled submit button with no message). |
| **CON** (Concurrency) | Avoid data races, deadlocks, and incorrect memory ordering in concurrent code. | CON40-C: Do not refer to an atomic variable twice in an expression. CON43-C: Do not allow data races. CON53-CPP: Avoid deadlock by locking in a predetermined order. | No GIL-saves-you assumption: `threading.Lock` for shared mutable state; `asyncio` race conditions on shared dicts; Django ORM `select_for_update()` for read-modify-write under concurrency; idempotency keys for retries; never assume task ordering in Celery/RQ. | `Worker`/`SharedArrayBuffer` data races: use `Atomics`; avoid TOCTOU on `localStorage`; ensure React `setState` callbacks for read-modify-write; cancel stale requests on rapid input (debounce + AbortController); avoid global mutable state across `await` boundaries. | Avoid client-side flags as the source of truth for concurrent operations (e.g., a "submitting" boolean that breaks on rapid double-click without server-side idempotency). |
| **MSC** (Miscellaneous) | Catch-all for correctness rules that don't fit other categories: dead code, unreachable branches, undefined behaviour. | MSC12-C: Detect and remove code that has no effect. MSC13-C: Detect and remove unused values. MSC15-C: Do not depend on undefined behaviour. MSC07-C: Detect and remove dead code. | Remove dead code (unused imports, unreachable branches after `return`); remove TODO comments older than N months without owner; reject mutable default arguments (`def f(x=[])`); reject relying on dict insertion order in libraries that pre-date 3.7. | Remove dead code; reject `==` (use `===`); reject relying on object key order in Maps with non-string keys; remove unused exports; reject `void 0` tricks in modern code. | Remove orphan `<div>` wrappers, commented-out blocks, unused CSS classes (use a coverage tool); remove inline styles that duplicate stylesheet rules. |

---

## Categories deliberately omitted (and why)

| Category | Why omitted from translation |
|----------|------------------------------|
| **PRE** (Preprocessor) | Already covered by NASA P10-#8 (limit metaprogramming). |
| **DCL** (Declarations) | C-specific (declaration syntax, identifier scope rules). High-level languages handle most via lexical scope. |
| **EXP** (Expressions) | Largely about evaluation order in C — well-defined in Python/JS. Sub-rules about side-effects in expressions covered by general code review. |
| **FLP** (Floating Point) | Use `Decimal` (Python) / `bigint` (JS) for money is the only universally applicable rule — covered under INT. Other FLP rules are too domain-specific for a general code review. |
| **ARR** (Arrays) | C-specific (no bounds checking). Python/JS arrays bounds-check at runtime. The "don't index past length" intent is enforced by the language. |
| **FIO** (File I/O) | Largely subsumed by MEM (resource lifetime) and OWASP A03 (path injection / TOCTOU). |
| **ENV** (Environment) | Mostly about safely calling `getenv`/`system` in C — covered by OWASP A03 (Injection) and A05 (Misconfiguration). |
| **SIG** (Signals) | Async-signal-safety is C-specific. Python `signal` and Node signal handlers have language-level guarantees. |
| **POS / WIN** (POSIX / Windows) | Platform-specific C APIs. |

---

## Notes on translation choices

- **INT in JS:** The `2^53` precision boundary is the single most underestimated correctness risk in JS web apps that handle large integer IDs from a server. `bigint` exists but isn't JSON-serializable by default; using string IDs is often safer.
- **MEM as resources:** GC handles memory in Python/JS. The CERT MEM intent — "release what you acquired, in deterministic order" — translates directly to file handles, sockets, locks, and event listeners.
- **CON in Python:** The GIL prevents memory races on individual bytecodes but does NOT prevent logical races on read-modify-write across multiple statements. CERT CON's intent applies in full.
- **MSC dead code:** This is also a NASA P10 spirit — every line should be reachable and have an effect. CERT formalizes it as a category.

## How the reviewer agent uses this file

For code under review, walk the categories and look for the translated signals. Tag findings as `CERT-<CAT>-spirit` (e.g., `CERT-INT-spirit` for an unbounded `parseInt` on user input) or cite a specific CERT rule when the literal rule applies (`CERT-ERR33-C`). Severity guidance:

- **High:** INT (silent precision loss), STR (encoding bugs causing data corruption), MEM (resource leaks under load), CON (data races) — runtime correctness risks.
- **Medium:** ERR (swallowed errors) — masks other bugs.
- **Low:** MSC (dead code, style) — maintainability.
