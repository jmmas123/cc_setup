# State — ~/.claude config repo

**Date**: 2026-06-26
**Branch**: main (at `2ff9541`, pushed, in sync with origin)

## What Changed This Session

- **Fixed the WindowServer/launchservicesd reboot crash (2026-06-23).** Root
  cause: `hooks/notify.sh` spawned a resident `terminal-notifier` per Notification
  event; ~468 accumulated over 8 days → launchservicesd 512-thread deadlock →
  WindowServer watchdog crash loop → reboot. Confirmed via WindowServer `.spin`
  stackshots (406/512 stuck queues = terminal-notifier).
- **Rewrote `hooks/notify.sh`** to deliver via `osascript display notification`
  (posts and exits, zero resident processes); kept window-title subtitle; dropped
  click-to-focus + vestigial badge. Deleted `hooks/ghostty-focus.sh`. Added
  regression test `hooks/tests/test-notify-no-residency.sh`.
- **4 commits, merged to main + pushed** (`a424ca5` spec, `d53d519` fix+test,
  `5ff8d2d` cleanup, `2ff9541` hardening). Spec at
  `docs/superpowers/specs/2026-06-23-notify-sh-rewrite-design.md`.
- **Removed `clawdbot`** (system, not this repo): the WhatsApp/Slack→Claude
  gateway driving ~70 notifications/hr. Booted out LaunchAgents, removed plists,
  `npm uninstall -g clawdbot`, rm /tmp/clawdbot. **`~/.clawdbot` (26MB creds) KEPT.**
- **Saved memory** `project_clawdbot_removed.md` (+ MEMORY.md pointer).
- Live-verified: hook leaves 0 resident processes; launchservicesd ~9 threads.

## Pending

- 13 [PENDING] proposals in `feedback/claude-md-proposals.md` (2 new this session:
  `#2026-06-26-jm-ms-a` /usr/bin/log shadowing, `#2026-06-26-jm-ms-b` scope
  guard-test grep to executable lines) — review with `/improve`.
- Pre-existing uncommitted (NOT from this session's feature work):
  `settings.json`, `rules/workflow.md` — present at session start, untouched.

## Next Steps

- Optional: `/improve` to triage the 13 pending proposals.
- Unrelated: Sentinel P1 — see `~/sentinel/docs/STATE.md`.

## Blockers

None
