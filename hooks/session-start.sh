#!/bin/bash
# Session start hook - checks for and injects project state as context

STATE_FILE=""
if [ -f "docs/STATE.md" ]; then
  STATE_FILE="docs/STATE.md"
elif [ -f "STATE.md" ]; then
  STATE_FILE="STATE.md"
elif [ -f ".claude/STATE.md" ]; then
  STATE_FILE=".claude/STATE.md"
fi

if [ -n "$STATE_FILE" ]; then
  echo "Found $STATE_FILE - loading previous session state:"
  echo "---"
  cat "$STATE_FILE"
  echo "---"
else
  echo "No STATE.md found - consider creating docs/STATE.md for state tracking"
fi

exit 0
