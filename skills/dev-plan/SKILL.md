---
name: dev-plan
description: Create, update, and execute heavyweight ExecPlans for extended repository workstreams. Use when the task is multi-milestone, high-risk, contract-changing, migration-heavy, or otherwise needs a self-contained plan that another engineer or agent can resume without rediscovering the repository. Do not use for ordinary small or medium tasks that are better handled by a compact execution brief in `dev-orchestrate`. When an accepted decision changes the architecture of the repository, create or update an ADR under `$PWD/docs/adr/` alongside the ExecPlan work.
---

# dev-plan

Create or execute an ExecPlan only when the extra ceremony is justified.

`dev-plan` is the heavyweight planning path.
It is not the default planning tool for every repository change.

## When To Use

Use `dev-plan` when one or more of these are true:

- the task is clearly multi-milestone
- restartability matters more than token efficiency
- the work changes an API, CLI, schema, workflow, or other contract
- the work includes migrations, broad refactors, or coordinated cross-cutting edits
- architecture or root cause uncertainty is high enough that a self-contained plan materially reduces failure risk
- a human or another agent should be able to continue from the saved plan alone

If the task is just a narrow bug fix, small feature, localized refactor, or other ordinary implementation task, prefer the compact execution-brief flow in `dev-orchestrate` instead.

## Inputs

`dev-plan` accepts three primary input patterns.
Choose the mode from the input itself instead of asking the user to restate it.

1. Free-form extended implementation request
   - Examples: large features, complex migrations, significant refactors, or high-risk technical changes
   - Behavior: inspect the repository as needed and create or update an ExecPlan that covers the extended workstream
2. Upstream design or research document
   - Examples: documents produced by `dev-investigate`, `dev-spec`, or equivalent notes/specs provided as pasted markdown or file paths
   - Behavior: extract the goal, scope, constraints, acceptance criteria, and open questions, then create or update an ExecPlan derived from that material
3. Existing dev-plan-generated plan file
   - Examples: an ExecPlan file path under `$PWD/docs/plans`, or pasted markdown that is clearly an existing ExecPlan created with `dev-plan`
   - Behavior: treat the provided plan as the target plan and execute it, updating the living-plan sections in that same file as work progresses

When the input is ambiguous, prefer these interpretations:

- a file under `$PWD/docs/plans` that matches ExecPlan structure is an executable plan input
- a file under `$PWD/docs/specs`, `$PWD/docs/investigations`, `$PWD/docs/reviews`, `$PWD/docs/walkthroughs`, `$PWD/docs/recaps`, or legacy `$PWD/docs/notes` is source material for plan creation, not a directly executable plan
- if a pasted document does not clearly match ExecPlan structure, treat it as source material and create or update a plan instead of executing it

## Entry Gate

Before creating a new ExecPlan from a free-form request, decide whether the task really deserves heavyweight planning.

If the task does not clearly meet the extended-workstream bar and the user did not explicitly ask for an ExecPlan:

- do not create a heavyweight plan just because planning is possible
- state briefly that a compact execution brief would normally be the better fit
- hand the task back to `dev-orchestrate` or the lighter implementation flow

If the user explicitly asks for an ExecPlan, follow that instruction even when the task looks smaller than ideal.

## Required Method

When creating, updating, or executing an ExecPlan:

1. read [PLANS.md](references/PLANS.md) first
2. follow [PLANS.md](references/PLANS.md) closely
3. keep the plan self-contained enough that another engineer or agent can resume from the plan itself

Do not jump straight into implementation unless the input is an explicitly executable dev-plan-generated ExecPlan.

## Plan File Management

Find, read, update, or delete plan files in `$PWD/docs/plans`.
When creating or updating a plan, always refer to `PLANS.md`.

Rules:

- create plan files under `$PWD/docs/plans`
- prepend new filenames with the UTC prefix `yyyy-MM-dd'T'HH-mm-ss'Z'_`
- if the saved plan includes any created or updated timestamp in its content, use the same UTC format `yyyy-MM-dd'T'HH-mm-ss'Z'`
- write the plan in the user's language unless the user asks otherwise
- switch to English for narrowly scoped passages when higher precision clearly helps
- write the saved plan file as normal Markdown content, not inside an outer fenced code block
- never emit local filesystem absolute paths such as `/Users/...` in saved plans
- when a workspace-rooted path must appear in prose, rewrite it with a `$PWD/...` placeholder instead
- when referencing repository files, tests, configs, docs, notes, specs, or directories in a saved plan, use repo-local relative Markdown links from the plan file
- prefer link labels that preserve the repository-relative path the reader expects to open
- if line precision matters, keep the link target as the file and put the line number in visible text

Interpret `PLANS.md` references to "full path" for saved artifacts as repository-relative paths within the repo, not machine-specific filesystem absolute paths.

When the input is a research or specification document, create a new ExecPlan in `$PWD/docs/plans` or update the user-specified target plan file there.
When the input is an existing ExecPlan, keep working in that same plan file and update its living sections as execution proceeds.

When an ExecPlan becomes the active source of truth for a workstream, do not maintain a competing compact execution brief for the same work.

## ADR Integration

Use ADRs for long-lived architectural decisions, not for routine execution notes.

Create ADRs under:

- `$PWD/docs/adr/yyyy-MM-dd'T'HH-mm-ss'Z'_*.md`

Use the same UTC prefix rule used by the other workflow artifacts.
If the ADR body includes any created or updated timestamp, use the same `UTC` format `yyyy-MM-dd'T'HH-mm-ss'Z'`.
Use [references/ADR_TEMPLATE.md](references/ADR_TEMPLATE.md) as the starting shape.

Create or update an ADR when most of these are true:

- the accepted decision affects multiple files, modules, or workstreams
- the accepted decision changes a long-lived API, CLI, schema, workflow, or architectural boundary
- the alternatives were real and worth preserving
- another engineer will likely need the rationale later
- the decision may be refined, reversed, or superseded later

Before creating a new ADR:

1. search `$PWD/docs/adr` for an existing ADR that already covers the same decision
2. prefer updating or superseding that ADR instead of creating a duplicate
3. keep one ADR file per architecture-level decision

When an ExecPlan contains architecture-level decisions:

- keep the detailed local chronology in the plan's `Decision Log`
- create or update the ADR as the durable cross-workstream record
- cross-link the ExecPlan and ADR so each points to the other

## Authorize Plan Execution

Only execute an ExecPlan when execution is explicitly authorized.
Treat execution as authorized in exactly these cases:

- the user uses the approved trigger phrase `Execute the plan` case-insensitively
- the user directly provides an existing dev-plan-generated ExecPlan file, either by file path or pasted content

If the user says `Execute the plan` without naming a target, interpret the target as the most recently created or updated plan file in `$PWD/docs/plans`, unless the user explicitly names a different plan.

Do not execute a plan in response to vague approvals such as `OK`, `Sounds good`, or `Go ahead` unless they also include an approved trigger phrase or an explicit dev-plan-generated plan file.
Do not treat ordinary implementation requests or upstream design or research documents as permission to start coding immediately.

## Execution Expectations

When executing an ExecPlan:

- treat the provided plan as the single primary source of truth
- keep its living sections current as work progresses
- proceed milestone by milestone without asking for unnecessary intermediate permission
- update the plan whenever discoveries or implementation changes invalidate old statements
- preserve the plan's role as a resume point for later work
- before closing a major milestone or the whole workstream, check whether any accepted decision should be promoted into an ADR

## Guardrails

- Do not create an ExecPlan for every task by habit.
- Do not use `dev-plan` as a replacement for the lighter `dev-orchestrate` execution-brief loop.
- Do not execute a plan without explicit authorization.
- Do not let a saved plan drift away from the current implementation state.
- Do not keep both an active ExecPlan and an active compact execution brief for the same workstream.
- Do not let architectural decisions remain only in the plan when they should be promoted into ADRs.
- Do not create ADRs for routine task-local execution choices.
