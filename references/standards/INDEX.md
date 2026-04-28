# Standards Reference Index

**Purpose:** Translation tables for four code-quality / safety / security standards, mapped from their original (often C-centric) form into Python/Django, JS/TS, and HTML/template signals that a code reviewer can scan against. The `code-reviewer-strict` agent reads this index first, then loads the standard files relevant to the languages of the code under review.

Each standard lives in its own file in this directory. Every row of every table is traceable to a cited source rule — no invented rules.

---

## The four standards

| Standard | File | One-line summary |
|----------|------|------------------|
| NASA Power of 10 | [`nasa-power-of-10.md`](nasa-power-of-10.md) | Holzmann (2006) — 10 rules for safety-critical code: simple control flow, bounded loops, bounded memory, ≤60-line functions, ≥2 assertions per function, narrowest scope, checked return values, limited preprocessor, restricted pointers/indirection, zero-warning compile. |
| OWASP Top 10 (2021) | [`owasp-top-10.md`](owasp-top-10.md) | OWASP Foundation (2021) — A01 Broken Access Control, A02 Cryptographic Failures, A03 Injection, A04 Insecure Design, A05 Security Misconfiguration, A06 Vulnerable Components, A07 Auth Failures, A08 Data Integrity Failures, A09 Logging/Monitoring Failures, A10 SSRF. |
| IEC 61508 | [`iec-61508.md`](iec-61508.md) | IEC 61508:2010 functional safety — 7 code-actionable principles: fault detection, fail-safe defaults, separation of concerns, fault-injection testing, traceability, bounded execution, structured error handling. |
| CERT C/C++ (spirit) | [`cert-c-spirit.md`](cert-c-spirit.md) | SEI CERT C/C++ — six categories with their *spirit* translated to Python/JS: INT (integer correctness), STR (string handling), MEM (resource lifetime), ERR (error handling), CON (concurrency), MSC (miscellaneous correctness). |

---

## Recommended reading order for the reviewer agent

1. **This index** (you are reading it). Confirms which standards are available and what each covers.
2. **`owasp-top-10.md`** — load whenever the code under review handles user input, auth, or external services (i.e., almost always for web code). Highest exploit-impact density.
3. **`nasa-power-of-10.md`** — load for any non-trivial code review. Catches structural/control-flow bugs that survive security review.
4. **`cert-c-spirit.md`** — load when the code touches integers near boundaries (large IDs in JS, money), strings near encoding boundaries, resource lifetime (file handles, sockets, locks), or concurrency.
5. **`iec-61508.md`** — load when the code is in a safety-critical path (auth, payment, infrastructure, anything where silent failure is unacceptable). Adds the design-level lens.

For a casual review, OWASP + NASA P10 alone are usually sufficient. For a strict / production / safety-critical review (the use case for which this directory exists), load all four.

---

## Citation tag conventions for findings

When the strict reviewer agent reports a finding, it cites the standard using these tags:

- `NASA-P10-#N` — Power of 10 rule number N (1-10).
- `OWASP-A##-21` — OWASP 2021 category, two-digit (`A01-21` through `A10-21`).
- `IEC-61508-<key>` — IEC 61508 principle key from the table in that file (e.g., `IEC-61508-fail-safe-defaults`).
- `CERT-<CAT>-spirit` for category-level applications (e.g., `CERT-INT-spirit`); or `CERT-<CAT-NN>` (e.g., `CERT-ERR33-C`) when a specific CERT rule applies literally.

The adversarial reviewer agent (invoked separately by `/strict-review`) uses these same tags when proving or refuting findings.

---

## What this directory does NOT cover

- **Process/lifecycle requirements** from IEC 61508 (FMEA, SIL determination, configuration management) — those belong in design/architecture review, not code review.
- **Project-specific conventions** — those live in the project's own `CLAUDE.md`, not here.
- **Language idioms** (PEP 8, Airbnb JS style, etc.) — those are stylistic; the strict reviewer focuses on correctness/security/safety.
- **Performance** — covered tangentially via NASA P10-#2 (bounded loops) and IEC-61508 `bounded-execution`, but not as a first-class concern.

---

## File structure conventions (for future updates)

- Each standard file starts with a `**Source:**` citation.
- Each rule/category lives in one row of a markdown table.
- Columns: `ID | Original rule (one-line) | Python translation | JS/TS translation | HTML/template translation`. (CERT and IEC tables include an extra source-reference column.)
- "n/a" with a one-line reason where a column does not apply.
- Each file ends with a "How the reviewer agent uses this file" section giving severity guidance.
- Each file is kept under 400 lines so the reviewer can load it in full without consuming significant context.
