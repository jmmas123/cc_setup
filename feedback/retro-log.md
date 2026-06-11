# Session Retrospective Log

Append-only log of session retrospectives. Entries added by `/retro` command.

---

## 2026-06-11 — Session Retro (studio rig)
**What worked**: claude-code-guide subagent for statusline API facts (context_window fields, no guessing); AskUserQuestion caught duplicate superpowers install before freezing config; declarative plugin freeze via enabledPlugins + extraKnownMarketplaces; atomic commits through two rebase conflicts without losing either machine's intent.
**Friction**: (1) settings.json and claude-md-proposals.md both merge-conflicted — machines edited them independently between syncs; (2) sequential proposal IDs collided across machines, required manual renumbering (#013–#015); (3) rig was 2+ commits behind origin with no signal at session start.
**Actions taken**: session-start.sh now warns when ~/.claude is behind origin (instant check + background fetch); wrap-up/retro staging switched to collision-proof IDs (#YYYY-MM-DD-<host>-<letter>); statusline context-token counter added earlier in session; superpowers deduped to official marketplace.
**Deferred**: nothing — user confirmed no other friction.
