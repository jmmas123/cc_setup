# State — ~/.claude config repo

**Date**: 2026-04-17
**Branch**: main (at `63f3244`)

## What Changed This Session

- **Removed redundant `~/cc_setup/` clone** — `~/.claude/` is the single cc_setup checkout
- **3 new commits on origin/main**:
  - `120336e` — notify.sh: terminal-notifier accumulation crash fix (2026-04-01 incident)
  - `46e1f94` — effortLevel: high → xhigh
  - `63f3244` — Add install.sh to own `terminal-notifier` Homebrew dependency
- **Pulled upstream**: commit `159eafe` (permissions allowlist + superpowers marketplace)
- **Ownership boundary with `terminal_setup`**: cc_setup owns all Claude Code files; terminal_setup drops `claude-code/` and `terminal-notifier` brew install
- **Memory**: added `reference_cc_setup_repo.md` and `reference_terminal_setup_repo.md`

## Pending

- 1 persistent local-only delta in `settings.json` (not on origin, intentional): `skipAutoPermissionPrompt: true`, `permissions.defaultMode: "auto"` — do not commit without user direction
- 1 pending proposal in `feedback/claude-md-proposals.md` (#001, semgrep) — unchanged from last session

## Next Steps

- Unrelated to config repos: resume Sentinel P1 (beaconing detector, ARP monitor, DNS integrity, VPN enforcement) — see `~/sentinel/docs/STATE.md`

## Blockers

None
