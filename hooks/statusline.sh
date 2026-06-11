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

# Context window usage (Claude Code >= 2.1.132 provides context_window on stdin;
# fields are null before the first API call and right after /compact)
used=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used" ] && [ -n "$size" ] && [ "$size" -gt 0 ] 2>/dev/null; then
    [ -z "$pct" ] && pct=$((used * 100 / size))
    ctx_status="ctx $((used / 1000))k/$((size / 1000))k (${pct}%)"
else
    ctx_status="ctx –"
fi

echo "${branch} | ${state_status} | ${ctx_status}"
