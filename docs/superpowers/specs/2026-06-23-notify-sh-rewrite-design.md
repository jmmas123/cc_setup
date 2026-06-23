# Design: `notify.sh` rewrite — eliminate `launchservicesd` thread-exhaustion crash

**Date:** 2026-06-23
**Component:** `~/.claude/hooks/notify.sh` (Claude Code `Notification` event hook)
**Repo:** `cc_setup` (`~/.claude`)

## Problem

The Mac fully rebooted on 2026-06-23 ~13:31. Forensics (WindowServer `.spin`
stackshots + unified log) established the cause:

- `launchservicesd` (PID 142) hit its hard limit of **512 libdispatch threads**
  and deadlocked (every thread waiting for a thread that can never be allocated).
- **406 of 512 (79%)** stuck client-queue threads belonged to `terminal-notifier`;
  **468 instances** were alive, all blocked in a synchronous LaunchServices XPC call.
- WindowServer made an init-time synchronous LaunchServices call, blocked forever
  on the deadlocked daemon → userspace watchdog killed it (40s), the restart hung
  too (80s) → crash loop → forced reboot.

Root cause of the accumulation: `notify.sh` fires on every Claude Code
`Notification` event and spawns a **resident** `terminal-notifier` (`& ; disown`)
to deliver an actionable (click-to-focus) notification. `terminal-notifier` stays
alive until the notification is dismissed. Across ~17 concurrent sessions over an
8-day uptime, instances accumulated until the pool was exhausted.

### Why prior mitigation failed

A 2026-04-01 mitigation added `terminal-notifier -remove` and
`pkill -xf "terminal-notifier.*-group com.mitchellh.ghostty.claude"`. The `-x`
(exact full-command-line match) flag means the pattern can never match the real
argv (which begins with the full Homebrew path and ends with `-activate …`), so
the reaper was a **silent no-op**. The crash recurred.

### Empirical findings (verified this session)

- `terminal-notifier` stays resident **even without** `-execute`/`-activate`
  (tested: a no-action instance was still alive seconds later). There is no way to
  use `terminal-notifier` without risking accumulation.
- `osascript -e 'display notification …'` delivers via the system NotificationCenter
  agent and **exits immediately** — zero resident processes (verified: osascript
  process count returned to baseline).
- The badge file `/tmp/ghostty-claude-badge` has **no reader anywhere**
  (`~/.claude`, `~/.config`, Ghostty config, shell rc, menubar tooling all checked).
  It is write-only vestigial state (incremented by `notify.sh`, decremented by
  `ghostty-focus.sh`, displayed by nothing).
- `ghostty-focus.sh` is referenced **only** by `notify.sh`.

## Goals

- Eliminate resident notifier processes so `launchservicesd` thread exhaustion
  cannot recur (structural fix, not a bounded mitigation).
- Preserve a macOS notification when Claude Code needs attention.
- Preserve the indication of **which** session/window needs attention (subtitle),
  which is the high-value part with many concurrent sessions.

## Non-goals (dropped, per decision)

- **Click-to-focus** the correct Ghostty window. User switches windows manually.
- **Badge count.** Vestigial; removed entirely. (A *visible* badge would be a
  separate future feature, out of scope here.)
- Ghostty notification **icon** via `-sender`. Pure `osascript` notifications are
  attributed to the script runner; accepted cosmetic regression.

## Design

### `notify.sh` (rewritten)

1. Read hook JSON from stdin (unchanged interface; content currently unused).
2. Identify the current Ghostty window by fuzzy-matching `$PWD` against Ghostty
   window titles via System Events — **keep the existing logic**, repurposed to
   produce a subtitle string (`MATCHED_TITLE`, fallback `"Ghostty"`). This
   `osascript` query runs and exits; no accumulation.
3. Deliver the notification via `osascript` using `on run argv` so the title and
   subtitle are passed as arguments (injection-safe against quotes/specials in
   window titles):

   ```bash
   osascript - "Claude Code" "$SUBTITLE" "Needs your attention" <<'APPLESCRIPT'
   on run argv
       display notification (item 3 of argv) ¬
           with title (item 1 of argv) ¬
           subtitle (item 2 of argv) ¬
           sound name "Ping"
   end run
   APPLESCRIPT
   ```
4. Exit 0. No background process, no `disown`, no badge writes, no `pkill`/`-remove`.

### Deletions

- Delete `~/.claude/hooks/ghostty-focus.sh` (dead code).
- Remove all badge logic from `notify.sh`; delete `/tmp/ghostty-claude-badge`
  as one-time cleanup.

### Settings

- `settings.json` `Notification` hook already points at `~/.claude/hooks/notify.sh`.
  No wiring change. `ghostty-focus.sh` is not referenced in settings.

## Error handling

- If the System Events window query fails or returns empty, subtitle falls back to
  `"Ghostty"`; the notification still fires.
- `osascript` delivery failure is non-fatal; hook exits 0 regardless so it never
  blocks Claude Code.

## Verification

1. **Functional:** invoke `echo '{}' | ~/.claude/hooks/notify.sh` from a directory
   matching a Ghostty window title → a NotificationCenter banner appears with
   title "Claude Code" and the matched subtitle.
2. **No residency (the core fix):** immediately after, `ps aux | grep
   terminal-notifier` shows no new Claude-group instances; `pgrep -x osascript`
   returns to baseline (no lingering osascript).
3. **Soak:** fire the hook ~20× in a loop → resident process count stays flat at
   baseline; `launchservicesd` thread count (`ps -M -p $(pgrep -x launchservicesd)
   | wc -l`) stays low (< ~50).
4. **Cleanup confirmed:** `/tmp/ghostty-claude-badge` is gone;
   `~/.claude/hooks/ghostty-focus.sh` is gone.

## One-time remediation (alongside deploy)

- `pkill -x terminal-notifier` to clear any remaining accumulated instances.
- `rm -f /tmp/ghostty-claude-badge`.

## Rollback

Single-file behavioral change in a git repo. Revert the `notify.sh` commit (and
restore `ghostty-focus.sh`) to return to prior behavior.
