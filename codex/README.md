# Codex preferences

`~/.codex` is not a git repo, and its `config.toml` must **not** be synced wholesale:
Codex writes machine-specific state into it (trusted `[projects."…"]` paths, MCP
server paths pinned to the installed ChatGPT.app version, plugin cache paths).

Only the portable preferences live here, in `config.snippet.toml`.

## Applying on another machine

1. `codex --version`. The snippet was set with 0.160.0. An older Codex does **not**
   reject unknown `status_line` items — it loads fine and silently drops them, so a
   version gap costs you a missing segment, not a broken config. See
   [Per-item version requirements](#per-item-version-requirements).
2. Open `~/.codex/config.toml` and merge the `[tui]` block. Three cases, not two:
   - **A literal `[tui]` header already exists** — add the `status_line` line
     *inside* it. A second `[tui]` header is a TOML duplicate-table error and Codex
     won't load (`exit 1`, `duplicate key`).
   - **Only a `[tui.<sub>]` sub-table exists and no `[tui]` header** — e.g.
     `[tui.model_availability_nux]`, which Codex writes itself. This is *not* a
     duplicate: add a real `[tui]` header. TOML permits a super-table either before
     or after its own sub-table and both parse, but put the parent first — it reads
     better and survives Codex rewriting the file.
   - **No `tui` table at all** — append the block from the snippet.
3. Restart Codex.

When you change a Codex preference on one machine, update the snippet here too.

## Per-item version requirements

Verified 2026-10-01 on JM-MBP against two builds. Note that ChatGPT.app ships its
own binary at `/Applications/ChatGPT.app/Contents/Resources/codex` — it is a
different version from the homebrew CLI, so check both.

| `status_line` item | homebrew 0.153.4 | ChatGPT.app 0.155.0-alpha.9.2 |
|---|---|---|
| `current-dir`, `git-branch`, `context-used`, `model-with-reasoning`, `used-tokens` | yes | yes |
| `context-window-size` | **no** | **no** |

`context-window-size` needs a newer build (present on 0.160.0, where the snippet was
authored). Until then it is silently ignored. `context-remaining` is the closest
supported substitute for a context-capacity readout.

Full `status_line` enum as of 0.153.4:

```
project-name  current-dir  run-state  thread-title  git-branch  context-remaining
context-used  five-hour-limit  weekly-limit  thread-credits  estimated-thread-cost
codex-version  used-tokens  total-input-tokens  total-output-tokens  thread-id
fast-mode  model-with-reasoning  reasoning  task-progress
```

## Verifying before you trust it

**`codex doctor` validates TOML syntax only, not `status_line` item names.** It
reports `config.toml parse ok` for `status_line = ["totally-bogus-item-xyz"]`, so a
green doctor is not evidence that a segment works.

Test a candidate config without touching the real one:

```sh
d=$(mktemp -d) && cp codex/config.snippet.toml "$d/config.toml"
CODEX_HOME="$d" codex debug prompt-input >/dev/null && echo loads   # exit 0 = config loads
```

To get the authoritative item list for an installed build, read the enum out of the
binary. Rust concatenates string literals with no separator, so `grep -x 'git-branch'`
finds **nothing** — match a substring instead:

```sh
BIN=/opt/homebrew/lib/node_modules/@openai/codex/node_modules/@openai/codex-darwin-arm64/vendor/aarch64-apple-darwin/bin/codex
python3 -c "import re,sys;d=open(sys.argv[1],'rb').read();m=re.search(rb'current-dirrun-state',d);print(d[m.start()-20:m.start()+430].decode('ascii','replace'))" "$BIN"
```

Beware lookalikes in unrelated blobs: `context-window-size` *is* in the 0.153.4
binary — sitting next to `hostname`, `approval-mode` and `raw-output` — but not in
the status_line enum. The string being present is not proof; check which blob.

Failure modes by severity:

| Mistake | Result |
|---|---|
| Malformed TOML | `exit 1`, parse error — Codex won't start |
| Duplicate `[tui]` header | `exit 1`, `duplicate key` |
| Unknown enum item | Silent — loads, segment just never renders |
