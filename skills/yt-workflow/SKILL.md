---
name: yt-workflow
description: Use when starting or wrapping up work in an eNSŌ LABS tracked repo (minerva, kika, depocard-mobile, atlas) — anchors sessions to YouTrack issues via the yt CLI
---

# yt-workflow — issue-driven development

Connects dev sessions to the eNSŌ LABS YouTrack (`https://yt.depotelas.net`)
through the `yt` CLI. Tracked repos and their project codes:

| Repo | Code |
|---|---|
| `~/Coding/Python/minerva` | MIN |
| `~/Coding/Python/kika` | KIK |
| `~/Coding/Python/depocard-mobile` | DM |
| `~/Coding/Python/atlas` | ATL |

## Structure & reporting

The **loop** below is the day-to-day CLI cadence. For how work is *structured* —
the milestone / issue / sub-issue / Type hierarchy, the ground rules for
granularity, the standardized field schema, and the dashboard roll-up contract —
see the companion doc **`hierarchy-methodology.md`** in this skill directory.
Read it when planning a milestone or laying out an issue tree (not needed for a
routine take/move/comment/log pass).

## The loop

**Session start** (in a tracked repo):
1. Run `yt mine --project <CODE>` to list the user's unresolved issues.
2. Propose anchoring the session to ONE issue that matches the planned work
   (`yt view <ID>` for detail). The user picks; don't anchor silently.
3. If the session's work isn't tracked by any issue, offer
   `yt new --project <CODE> "<summary>"` — the user approves before it runs.

**During work:**
- Reference the anchored issue ID in commit messages (e.g. `MIN-12: fix retry backoff`).
- `yt take <ID> [--stage Develop]` when the user starts on an unassigned issue.

**Wrap-up:** propose the update trio, each as a separate, individually
approvable command:
1. `yt move <ID> <Stage>` — only if the stage actually changed
2. `yt comment <ID> "<what was done>"` — factual summary
3. `yt log <ID> <duration>` — time actually spent (e.g. `1h30m`)

## Hard rules

- **Writes are never run without the user seeing the exact command.** Write
  subcommands (`take`, `move`, `comment`, `log`, `new`) are deliberately NOT
  allowlisted — the permission prompt is the approval gate. Do not batch or
  script around it.
- Comments and issues are **company-visible**: plain factual language, no AI
  boilerplate, no self-reference. Write what changed, not how the session went.
- The company is always stylized **eNSŌ LABS**.
- Exit codes: 3 = token problem (fix `~/.config/enso-yt/.env`), 4 = YouTrack
  unreachable, 5 = rejected (message lists valid values).
- After a write, `yt` prints the issue's post-write state — read it; workflows
  can piggyback (e.g. ATL auto-assigns on a move to Develop). Unexpected
  assignee changes there are workflow behavior, not errors.
