#!/bin/bash
# Session start hook - project state + git orientation
# Kept fast (<1s) — shell commands only

# --- State file ---
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

# --- Git orientation ---
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null)
  echo ""
  echo "Git branch: $BRANCH"
  echo "Recent commits:"
  git log --oneline -3 2>/dev/null | sed 's/^/  /'

  # Warn about uncommitted changes
  CHANGES=$(git status --porcelain 2>/dev/null | head -20)
  if [ -n "$CHANGES" ]; then
    COUNT=$(echo "$CHANGES" | wc -l | tr -d ' ')
    echo ""
    echo "⚠ $COUNT uncommitted change(s) detected"
  fi
fi

# --- CLAUDE.md check ---
if [ ! -f "CLAUDE.md" ]; then
  echo ""
  echo "No CLAUDE.md found in project root - consider creating one for project-specific instructions"
fi

exit 0
