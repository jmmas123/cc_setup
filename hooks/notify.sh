#!/usr/bin/env bash
# Claude Code Notification hook — posts a macOS notification when a session
# needs attention. Identifies the originating Ghostty window by fuzzy-matching
# $PWD against window titles and shows it as the subtitle, so the right session
# is obvious among many.
#
# Delivery uses `osascript display notification`, which posts through the system
# NotificationCenter agent and EXITS IMMEDIATELY. This approach avoids resident
# notifier processes that would accumulate and exhaust launchservicesd's
# 512-thread pool, hanging WindowServer and forcing a reboot (2026-06-23).
# See docs/superpowers/specs/2026-06-23-notify-sh-rewrite-design.md.
#
# DO NOT reintroduce terminal-notifier here: it stays resident until dismissed,
# accumulated instances exhausted launchservicesd's thread pool and forced a
# reboot (2026-06-23). Regression-tested by hooks/tests/test-notify-no-residency.sh.

# Drain stdin (hook JSON; currently unused) so the writer never blocks.
cat >/dev/null 2>&1

# --- Identify the originating Ghostty window (for the subtitle) ---
DIR_NAME="${PWD##*/}"
NORMALIZED_DIR=$(echo "$DIR_NAME" | tr '[:upper:]' '[:lower:]' | tr '_-' '  ')

MATCHED_TITLE=""
WINDOW_LIST=$(osascript -e '
tell application "System Events" to tell application process "Ghostty"
    get name of every window
end tell' 2>/dev/null)

if [ -n "$WINDOW_LIST" ]; then
    IFS=',' read -ra TITLES <<< "$WINDOW_LIST"
    # Exact normalized match first.
    for title in "${TITLES[@]}"; do
        title=$(echo "$title" | sed 's/^ *//;s/ *$//')
        normalized_title=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr '_-' '  ')
        if [ "$normalized_title" = "$NORMALIZED_DIR" ]; then
            MATCHED_TITLE="$title"
            break
        fi
    done
    # Fallback: partial match (directory name contained in title).
    if [ -z "$MATCHED_TITLE" ]; then
        for title in "${TITLES[@]}"; do
            title=$(echo "$title" | sed 's/^ *//;s/ *$//')
            normalized_title=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr '_-' '  ')
            if echo "$normalized_title" | grep -qF -- "$NORMALIZED_DIR"; then
                MATCHED_TITLE="$title"
                break
            fi
        done
    fi
fi

SUBTITLE="${MATCHED_TITLE:-Ghostty}"

# --- Deliver the notification (synchronous; process exits immediately) ---
# Strings are passed as argv (on run argv) so window titles containing quotes
# or special characters cannot break or inject into the AppleScript.
osascript - "Claude Code" "$SUBTITLE" "Needs your attention" <<'APPLESCRIPT' 2>/dev/null
on run argv
    display notification (item 3 of argv) with title (item 1 of argv) subtitle (item 2 of argv) sound name "Ping"
end run
APPLESCRIPT

exit 0
