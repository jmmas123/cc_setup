#!/bin/bash
# PreToolUse safety guard — blocks dangerous Bash patterns
# Exit 0 = allow, Exit 2 = block with message
# Reads the command from stdin (JSON with tool_input.command)

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/"command"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')

# If we couldn't extract a command, allow (don't block non-Bash tools)
[ -z "$COMMAND" ] && exit 0

# --- Catastrophic deletion ---
if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+)?(-[a-zA-Z]*r[a-zA-Z]*\s+)?(\/|~|\$HOME)\s*$'; then
  echo "BLOCKED: Catastrophic deletion detected (rm -rf / or ~). This would destroy your filesystem." >&2
  exit 2
fi
if echo "$COMMAND" | grep -qE 'rm\s+-rf\s+(\/|~|\$HOME)\s*$'; then
  echo "BLOCKED: Catastrophic deletion detected (rm -rf / or ~)." >&2
  exit 2
fi

# --- Force push to main/master ---
if echo "$COMMAND" | grep -qE 'git\s+push\s+.*--force.*\s+(main|master)'; then
  echo "BLOCKED: Force push to main/master. Use a feature branch or --force-with-lease." >&2
  exit 2
fi
if echo "$COMMAND" | grep -qE 'git\s+push\s+.*-f\s+.*\s+(main|master)'; then
  echo "BLOCKED: Force push to main/master." >&2
  exit 2
fi

# --- DROP TABLE / DROP DATABASE without safeguards ---
if echo "$COMMAND" | grep -qiE '(DROP\s+TABLE|DROP\s+DATABASE)'; then
  echo "BLOCKED: DROP TABLE/DATABASE detected. Run this manually if intentional." >&2
  exit 2
fi

# Allow everything else
exit 0
