# YouTrack ⇄ Git Hierarchy Methodology

Companion to `SKILL.md`. The skill's "loop" covers the **day-to-day CLI**
(anchor → take → move → comment → log). This doc covers the **structure**: how
milestones, issues, sub-issues, and types map onto git history and onto
reporting. It is the model eNSŌ LABS adopts across all tracked repos
(MIN, KIK, DM, ATL).

Status: adopted 2026-07-03. Refine as we learn.

---

## 1. The structural model — one object, different Type + depth

The four "levels" (milestone / issue / sub-issue / type) are **not four
different objects**. They are *one object — a YouTrack issue — at a different
`Type` and a different depth in a parent→child tree*, wired by the native
**`Subtask`** link (`parent for` / `subtask of`, aggregation on). The
**`Depend`** link (`is required for` / `depends on`) expresses sequencing
between siblings.

| Term | YouTrack reality | Git mapping |
|---|---|---|
| **Milestone** | an issue with `Type = Milestone` | a merge / PR boundary — never a single commit |
| **Issue** | a child issue, `Type = Feature/Task/Bug/…` | a logical group of commits, *or* 1 commit if small |
| **Sub-issue** | a grandchild issue, usually `Type = Task` | **1 commit** (the ~80% default) |
| **Type** | the `enum` classifying *every* node | not git — the semantic tag |

Real reference tree (live in MIN):

```
MILESTONE MIN-28  "Add collection management module"   [Type=Milestone · Module=Customers]
   ├─ MIN-24  [Bug]   Allow to delete collection drafts
   ├─ MIN-25  [Bug]   Add send statement by email
   ├─ MIN-26  [Bug]   Account for NCE, NDE and invalidation
   └─ MIN-30  [Bug]   Add collection notice registration
```

---

## 2. Ground rules for granularity (decided on the fly)

Granularity is **contextual** — aim for *medium* granularity that gives the best
logical compression of work into reviewable units. The default is
**commit = sub-issue ~80% of the time**; the rest is judgment, governed by:

1. **Leaf = one logical commit.** The *lowest* node in a tree maps to exactly
   one (squashed) commit. Whether that leaf is a *sub-issue* (80%) or an *issue*
   (when the issue is already commit-sized) depends only on size.
2. **Don't invent a lone child.** If an issue would have only one commit, the
   *issue* is the leaf — never create a single sub-issue just to have one. Add
   sub-issues only when a leaf splits into 2–5 independently-reviewable commits.
3. **Milestones never map to a commit.** A `Type=Milestone` issue is an
   aggregate; its Stage / estimate roll up from children. It corresponds to a
   merge or PR, not a commit.
4. **Commit subject = `<LEAF-ID>: <imperative summary>`** — the leaf's ID
   (sub-issue if 3-level, issue if 2-level). The parent milestone is referenced
   at the merge / PR, not on every commit.
5. **One `Type=Milestone` per tree.** Children carry a *real* work type
   (Feature/Task/Bug/…), applied meaningfully — not defaulted.
6. **`Module` is orthogonal.** It tags *which part of the app*, independent of
   tree depth or Type.

---

## 3. Standardized field schema (the config generalization)

**Shared canonical fields — identical bundles in every project → these are the
cross-project report axes:**

- **`Type`** (enum): `Bug, Cosmetics, Exception, Feature, Task, Usability
  Problem, Performance Problem, Milestone`
- **`Priority`** (enum): `Show-stopper, Critical, Major, Normal, Minor`
- **`Estimation`** (period), **`Spent time`** (period), **`Due Date`** (date),
  **`Assignee`** (user)

**Project-specific field — the drill-down axis:**

- **`Module`** (enum): values differ per project.
  - MIN: `Customers, Invoicing, Core, Project-wide, Depocard, Facilities,
    Tickets, Companies, HR`
  - KIK: `Hero, Difference, Intelligent Planning, Everything-You-Need,
    Venues & Vendors, CMS, Platform/Infra, App/Backend, i18n`
  - DM / ATL: to be defined.

**`Stage` — per-project workflow (see §4).**

Config status (2026-07-03): Type / Module-field / Due Date generalized to
MIN, KIK, DM. **ATL** custom fields still pending. **KIK / DM `Module`
bundles** created but values not yet authored.

---

## 4. Stage — OPEN DECISION (owned by Head of Dev)

`Stage` is the one shared field whose bundle **legitimately differs by
project**, because mobile and web ship differently:

- **Web** (MIN, KIK): `Backlog · Develop · Review · Done · Deployed`
- **Mobile** (DM): `Backlog · Develop · Review · Test · Staging · Done`

Two options:

- **(A) Per-project stages, unified by report buckets** *(recommended)* — each
  project keeps its real workflow; the dashboard maps every native stage into
  shared buckets (`Todo → Active → Review → Shipping → Done`). Preserves
  mobile-vs-web reality *and* gives comparable columns. Cost: a stage→bucket
  mapping table in the reporting layer.
- **(B) One forced canonical Stage** — simplest to report on, but drops DM's
  `Test · Staging` (losing mobile-QA visibility) or bolts meaningless columns
  onto mobile.

Either way the dashboard needs a stage→bucket map to reconcile `Deployed` vs
`Staging/Test`. **Decision pending Head of Dev.**

---

## 5. Reporting / roll-up semantics (the dashboard contract)

The hierarchy *is* the reporting data model. A dashboard can only show
dimensions the issues carry, so every standardized field is a report axis and
every `Type=Milestone` tree is a roll-up unit:

- **Milestone progress** = resolved children ÷ total children.
- **Burn** = Σ `Spent time` vs Σ `Estimation` across the tree.
- **Report axes**: `Type`, `Module`, `Stage`-bucket, `Priority`, `Assignee`.
- **Cross-project roll-up** uses only the shared canonical fields; `Module`
  and native `Stage` are drill-down within a project.

When authoring the tree, ask "what will the dashboard need to answer?" —
`{ what's Active?, spent vs estimate per milestone?, load per Module?,
open bugs by Priority? }` — and make sure the fields carry it.

---

## 6. Two tiers: `yt` CLI vs the web UI

- **`yt` CLI (day-to-day loop):** `new` (sets `--type`, `--desc`), `take`
  (assign to me + optional stage), `move` (stage), `comment`, `log`. Plus the
  issue-ID in commit subjects.
- **Web UI / raw REST (planning-time structure):** parent↔sub-issue links, the
  Milestone tree, `Module`, `Priority`, `Estimation`, `Due Date`. The CLI
  cannot set these — author them when you lay out a milestone, then run the
  CLI loop against the leaves.

---

## 7. Commit / branch conventions

- **Commit subject:** `<LEAF-ID>: <imperative summary>`
  (e.g. `KIK-30: build hero section`).
- **Branch:** one branch per milestone (`feature/<slug>`), or per issue when an
  issue is large enough to warrant its own review.
- **Merge / PR:** references the milestone ID; the body lists the leaf issues it
  closes.
- **Co-author trailer:** per repo convention.
- Issues and commit-visible text stay factual and company-visible — no AI
  boilerplate (see `SKILL.md` hard rules).
