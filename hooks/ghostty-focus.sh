#!/usr/bin/env bash
# Raise a specific Ghostty window by title and clear the badge
# Usage: ghostty-focus.sh "Window Title"

BADGE_FILE="/tmp/ghostty-claude-badge"

# Decrement badge count (or clear if at 0)
COUNT=$(cat "$BADGE_FILE" 2>/dev/null || echo 0)
COUNT=$((COUNT - 1))
if [ "$COUNT" -le 0 ]; then
    rm -f "$BADGE_FILE"
else
    echo "$COUNT" > "$BADGE_FILE"
fi

TITLE="$1"

if [ -z "$TITLE" ]; then
    osascript -e 'tell application "Ghostty" to activate'
    exit 0
fi

osascript \
    -e 'tell application "Ghostty" to activate' \
    -e "tell application \"System Events\" to tell application process \"Ghostty\" to perform action \"AXRaise\" of window \"$TITLE\""
