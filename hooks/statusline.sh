#!/usr/bin/env bash
# Claude Code status line script
# Reads JSON from stdin and outputs a concise one-line status

input=$(cat)

# Get current working directory from the JSON input
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // empty')
[ -z "$cwd" ] && cwd=$(pwd)

# Get git branch (skip optional locks to avoid conflicts)
branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
[ -z "$branch" ] && branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
[ -z "$branch" ] && branch="no git"

# Check for STATE.md
if [ -f "$cwd/docs/STATE.md" ] || [ -f "$cwd/STATE.md" ]; then
    state_status="STATE.md ✓"
else
    state_status="no STATE.md"
fi

echo "${branch} | ${state_status}"
