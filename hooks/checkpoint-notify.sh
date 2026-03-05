#!/bin/bash
# PostToolUse hook — detects safe checkpoints and outputs a visible reminder
# Fires after Bash, Write, and Edit tool uses
# Reads tool input from stdin (JSON)

INPUT=$(cat)

# Determine which tool was used based on input content
# Bash tools have "command" field, Write/Edit have "file_path" field
COMMAND=$(echo "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/"command"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/"file_path"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')

CHECKPOINT=""

# --- Bash command checkpoints ---
if [ -n "$COMMAND" ]; then
  # Git commit — work saved
  if echo "$COMMAND" | grep -qE "^git commit|&& git commit|; git commit"; then
    CHECKPOINT="Commit saved"
  # Git push — work shared
  elif echo "$COMMAND" | grep -qE "^git push|&& git push|; git push"; then
    CHECKPOINT="Changes pushed"
  # Test run completed
  elif echo "$COMMAND" | grep -qE "^pytest|^python3? -m pytest|^python3? .*test_|^uv run pytest"; then
    CHECKPOINT="Tests completed"
  # Build/install completed
  elif echo "$COMMAND" | grep -qE "^pip install|^uv pip install|^uv sync|^npm install|^make build"; then
    CHECKPOINT="Build completed"
  fi
fi

# --- File write checkpoints ---
if [ -n "$FILE_PATH" ]; then
  # STATE.md written — state documented (signals phase boundary)
  if echo "$FILE_PATH" | grep -qE "STATE\.md$"; then
    CHECKPOINT="State documented"
  fi
fi

# Output the checkpoint banner if triggered
if [ -n "$CHECKPOINT" ]; then
  echo ""
  echo "==========================================="
  echo "  CHECKPOINT: ${CHECKPOINT}"
  echo "  Safe to /compact — state is preserved"
  echo "==========================================="
  echo ""
fi

exit 0