#!/bin/bash
# PostToolUse hook — logs Bash commands to ~/.claude/command-history.log
# Reads tool input from stdin (JSON with tool_input.command)
# Auto-rotates: keeps last 7 days

LOG_FILE="$HOME/.claude/command-history.log"

# Auto-rotate: delete entries older than 7 days (check once per hour)
ROTATE_MARKER="$HOME/.claude/.log-rotated"
if [ ! -f "$ROTATE_MARKER" ] || [ "$(find "$ROTATE_MARKER" -mmin +60 2>/dev/null)" ]; then
  if [ -f "$LOG_FILE" ]; then
    CUTOFF=$(date -v-7d +%Y-%m-%d 2>/dev/null || date -d "7 days ago" +%Y-%m-%d 2>/dev/null)
    if [ -n "$CUTOFF" ]; then
      # Keep only lines with dates >= cutoff
      awk -v cutoff="$CUTOFF" '/^\[/ { if (substr($0,2,10) >= cutoff) print; next } { print }' "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
    fi
  fi
  touch "$ROTATE_MARKER"
fi

# Extract command from stdin JSON
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/"command"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')

# Only log if we got a command
if [ -n "$COMMAND" ]; then
  TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
  PWD_NOW=$(pwd)
  echo "[$TIMESTAMP] [$PWD_NOW] $COMMAND" >> "$LOG_FILE"
fi

exit 0
