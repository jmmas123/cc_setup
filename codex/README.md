# Codex preferences

`~/.codex` is not a git repo, and its `config.toml` must **not** be synced wholesale:
Codex writes machine-specific state into it (trusted `[projects."…"]` paths, MCP
server paths pinned to the installed ChatGPT.app version, plugin cache paths).

Only the portable preferences live here, in `config.snippet.toml`.

## Applying on another machine

1. `codex --version` — the snippet was set with 0.160.0; older versions may
   reject unknown `status_line` items.
2. Open `~/.codex/config.toml`:
   - If it already has a `[tui]` table, add the `status_line` line **inside it**.
     A second `[tui]` header is a TOML duplicate-table error and Codex won't load.
   - Otherwise, append the `[tui]` block from the snippet.
3. Restart Codex.

When you change a Codex preference on one machine, update the snippet here too.
