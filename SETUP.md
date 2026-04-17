# Claude Code Setup Guide

Welcome! This guide will help you set up this Claude Code configuration on your machine. You can follow it manually or — even better — paste it into a Claude Code session and let Claude walk you through it.

> **To get Claude's help:** Start a `claude` session anywhere and say:
> "Help me set up my Claude Code config using the SETUP.md guide at `~/.claude/SETUP.md`"

---

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed (`npm install -g @anthropic-ai/claude-code`)
- Git configured with SSH access to GitHub
- macOS or Linux (Windows WSL works too)

## Step 1: Clone the Config

```bash
# Option A: Fresh machine (no existing ~/.claude)
git clone git@github.com:jmmas123/cc_setup.git ~/.claude

# Option B: ~/.claude already exists (Claude Code was already used)
# Back up existing files, then merge:
cp -r ~/.claude ~/.claude.bak
cd ~/.claude
git init
git remote add origin git@github.com:jmmas123/cc_setup.git
git fetch origin
git checkout -b main origin/main
# Restore any personal files from backup (credentials, settings.local.json)
cp ~/.claude.bak/.credentials.json ~/.claude/ 2>/dev/null
cp ~/.claude.bak/settings.local.json ~/.claude/ 2>/dev/null
```

## Step 2: Install Dependencies

```bash
cd ~/.claude
./install.sh
```

Installs `terminal-notifier` (used by `hooks/notify.sh`) and marks hook scripts executable.

## Step 3: Authenticate

```bash
claude
# Follow the auth flow — this creates .credentials.json (gitignored)
```

## Step 4: Create Local Permissions

Create `~/.claude/settings.local.json` with your machine-specific permission overrides. This file is gitignored — it won't be shared.

```json
{
  "permissions": {
    "allow": [
      "Bash(git:*)",
      "Bash(python3:*)",
      "Bash(tmux:*)",
      "Bash(uv:*)",
      "Bash(brew:*)",
      "Bash(gh:*)",
      "Bash(ls:*)",
      "Bash(cat:*)",
      "Bash(head:*)",
      "Bash(tail:*)",
      "Bash(wc:*)",
      "Bash(mkdir:*)",
      "Bash(cp:*)",
      "Bash(mv:*)",
      "Bash(chmod:*)",
      "WebSearch"
    ],
    "deny": []
  }
}
```

Adjust to your comfort level — add more tools as you use them. Claude will prompt for anything not on the allow list.

## Step 5: Set Up Credentials (Optional)

If the DWH MCP server is relevant to you, create `~/.claude/.env`:

```bash
cp ~/.claude/.env.example ~/.claude/.env
# Edit with your actual database credentials
```

## Step 6: Verify

Start a new `claude` session and check:

- [ ] **Session start hook fires** — you should see git branch info and STATE.md injection
- [ ] **Rules load** — ask Claude "what rules are loaded?" — should list workflow.md, coding-standards.md, context-hygiene.md, continuous-improvement.md
- [ ] **Commands available** — type `/` and look for: status, wrap-up, review, retro, meta-review, adversarial-analysis
- [ ] **Notification hook works** — when Claude pauses for permission, you should hear a sound

## Step 7: Customize

Things you'll likely want to personalize:

| What | Where | Why |
|------|-------|-----|
| Permission allow list | `settings.local.json` | Add tools you use frequently to skip prompts |
| Communication style | `CLAUDE.md` | Change "Communication Style" section to match your preferences |
| Code standards | `rules/coding-standards.md` | Adjust for your language/framework preferences |
| Database credentials | `.env` | Point to your databases |

## What You Get

### Automatic (no action needed)
- **Session continuity** — STATE.md auto-saved before compaction, auto-loaded on start
- **Safety guards** — dangerous commands (rm -rf /, force push to main) are blocked
- **Command logging** — all Bash commands logged to `command-history.log`
- **Desktop notifications** — sound alert when Claude needs attention

### On-Demand Commands
| Command | What it does |
|---------|-------------|
| `/status` | Quick project orientation (git, STATE.md, blockers) |
| `/wrap-up` | End-of-session protocol (summarize, update STATE.md) |
| `/review` | Code review on recent changes |
| `/retro` | Session retrospective — capture learnings |
| `/meta-review` | Audit the config itself (run monthly) |
| `/adversarial-analysis` | Multi-agent red-team review for designs/architectures |

### Workflow Rules (always active)
- Event-based compaction suggestions at safe checkpoints
- Context hygiene — prevents error propagation across turns
- Continuous improvement — watches for automation opportunities

---

## Keeping in Sync

```bash
# After making config changes
cd ~/.claude && git add -A && git commit -m "Update [what]" && git push

# On another machine
cd ~/.claude && git pull
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Hooks don't fire | Check `settings.json` hook paths point to `~/.claude/hooks/` |
| Permission denied on hooks | `chmod +x ~/.claude/hooks/*.sh` |
| MCP server fails | Check `.env` credentials, verify DB driver is installed |
| Plugins not loading | Run `/plugins` in a Claude session to enable them |
| "PreCompact undefined" error | Ensure `settings.json` PreCompact hook has a `"prompt"` field |

## Questions?

Start a Claude session and ask — the config is self-documenting. Claude can read any file in `~/.claude/` to explain what it does.
