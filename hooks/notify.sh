#!/usr/bin/env bash
# Claude Code notification hook — sends a macOS notification that raises
# the correct Ghostty window when clicked.
#
# Identifies the current window by fuzzy-matching $PWD against Ghostty
# window titles (set by shell integration).

FOCUS_SCRIPT="$HOME/.claude/hooks/ghostty-focus.sh"

# --- Identify the window ---
DIR_NAME="${PWD##*/}"
# Normalize for comparison: lowercase, underscores/hyphens → spaces
NORMALIZED_DIR=$(echo "$DIR_NAME" | tr '[:upper:]' '[:lower:]' | tr '_-' '  ')

MATCHED_TITLE=""

# Query visible Ghostty window titles via System Events
WINDOW_LIST=$(osascript -e '
tell application "System Events" to tell application process "Ghostty"
    get name of every window
end tell' 2>/dev/null)

if [ -n "$WINDOW_LIST" ]; then
    IFS=',' read -ra TITLES <<< "$WINDOW_LIST"
    for title in "${TITLES[@]}"; do
        title=$(echo "$title" | sed 's/^ *//;s/ *$//')  # trim whitespace
        normalized_title=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr '_-' '  ')
        if [ "$normalized_title" = "$NORMALIZED_DIR" ]; then
            MATCHED_TITLE="$title"
            break
        fi
    done

    # Fallback: partial match (directory name contained in title)
    if [ -z "$MATCHED_TITLE" ]; then
        for title in "${TITLES[@]}"; do
            title=$(echo "$title" | sed 's/^ *//;s/ *$//')
            normalized_title=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr '_-' '  ')
            if echo "$normalized_title" | grep -q "$NORMALIZED_DIR"; then
                MATCHED_TITLE="$title"
                break
            fi
        done
    fi
fi

# --- Badge count ---
BADGE_FILE="/tmp/ghostty-claude-badge"
COUNT=$(cat "$BADGE_FILE" 2>/dev/null || echo 0)
COUNT=$((COUNT + 1))
echo "$COUNT" > "$BADGE_FILE"

# --- Send notification (backgrounded — terminal-notifier blocks until dismissed) ---
SUBTITLE="${MATCHED_TITLE:-Ghostty}"

if [ -n "$MATCHED_TITLE" ]; then
    terminal-notifier \
        -title "Claude Code" \
        -subtitle "$SUBTITLE" \
        -message "Needs your attention" \
        -sound Ping \
        -sender com.mitchellh.ghostty \
        -execute "$FOCUS_SCRIPT '$MATCHED_TITLE'" &
else
    terminal-notifier \
        -title "Claude Code" \
        -message "Needs your attention" \
        -sound Ping \
        -sender com.mitchellh.ghostty \
        -activate com.mitchellh.ghostty &
fi
disown 2>/dev/null
