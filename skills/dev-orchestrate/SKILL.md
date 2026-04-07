---
name: dev-orchestrate
description: Run an autonomous repository implementation workflow with minimal human intervention. Use when the user wants the agent to take an issue, bug, feature, or change request from intake through focused repository recon, compact planning, implementation, review, validation, and completion with as little user interaction as possible. Default to a lightweight local-first flow and escalate to `dev-investigate`, `dev-spec`, `dev-plan`, `dev-followup`, `dev-walkthrough`, or `dev-recap` only when task risk, ambiguity, or handoff needs justify the extra ceremony. When architecture-level decisions become stable, promote them from local decision notes into ADR artifacts under `$PWD/docs/adr/`.
---

# dev-orchestrate

Run a low-ceremony implementation workflow that optimizes for autonomous completion rate, not for producing every possible artifact.

Keep the agent in the main thread as the orchestrator.
Default to a local-first execution style.
Use downstream skills only when they materially reduce failure risk.

## Primary Goal

Take a repository task from request to completed implementation with the smallest workflow that still protects against:

- solving the wrong problem
- missing an important constraint
- shipping an obvious regression
- stopping in an unrecoverable intermediate state

Treat `dev-orchestrate` as a router plus checkpoint manager, not as a mandatory full documentation pipeline.

## Inputs

- a free-form issue, bug, feature, or implementation request
- an existing artifact path such as:
  - `$PWD/docs/adr/...`
  - `$PWD/docs/investigations/...`
  - `$PWD/docs/specs/...`
  - `$PWD/docs/plans/...`
  - `$PWD/docs/reviews/...`
  - `$PWD/docs/execution-briefs/...`
- a dirty repository state that should be resumed or stabilized
- optional constraints:
  - `execution_mode=auto|local|subagents`
  - stop after a named gate
  - resume from a named phase
  - timebox
  - language

When the user provides a `.md` file path or pasted markdown, treat that artifact as the primary input instead of paraphrasing it into a weaker surrogate.

## Execution Modes

Resolve execution mode before doing substantial work.

- `auto`
  - default mode
  - run the core loop locally in the main thread
  - use subagents only for isolated sidecar work such as independent investigation, narrow validation, or other non-blocking tasks
- `local`
  - do not call `spawn_agent`
  - run everything in the main thread
- `subagents`
  - still keep orchestration decisions in the main thread
  - delegate only well-scoped, non-overlapping phase work or sidecar tasks
  - do not delegate every phase by reflex

Treat intents like these as valid signals for `local`:

- `no subagents`
- `run locally`
- `main thread only`
- `do this without delegation`

Treat intents like these as valid signals for `subagents`:

- `use subagents`
- `delegate this`
- `run this with subagents`

If the user does not specify a mode, default to `auto`.
Briefly state the resolved execution mode near the start of the run.

## Task Classes

Classify the task early. The class decides how much ceremony is justified.

### `fast`

Use for work that is narrow, low-risk, and easy to validate.

Typical signals:

- one small bug fix
- one localized behavior tweak
- obvious target files
- no contract, schema, or interface change

Default flow:

1. focused recon
2. implement
3. review gate
4. validation gate

### `standard`

Use for ordinary engineering work. This is the default.

Typical signals:

- a normal feature or bug that spans a few files
- some uncertainty about the right fix
- non-trivial tests or validation
- moderate regression risk

Default flow:

1. intake
2. focused recon
3. compact execution brief
4. implement
5. review gate
6. fix loop if needed
7. validation gate
8. close

### `extended`

Use only when the work is broad enough that a compact loop is not safe enough.

Typical signals:

- API, CLI, schema, workflow, or user-visible contract changes
- migrations, broad refactors, or multi-milestone work
- high uncertainty about architecture or root cause
- strong need for restartability or handoff-quality artifacts

Extended flow may invoke `dev-investigate`, `dev-spec`, `dev-plan`, or `dev-followup`.
Do not enter `extended` mode just because the task sounds important.

## Core Artifact: Execution Brief

For `standard` work, prefer one compact execution brief under:

- `$PWD/docs/execution-briefs/yyyy-MM-dd'T'HH-mm-ss'Z'_*.md`

Keep it short, usually 10 to 30 lines.
Use it as the state checkpoint for the current run.
When an ExecPlan already exists and should remain the source of truth, do not create a competing execution brief.

Use [references/EXECUTION_BRIEF_TEMPLATE.md](references/EXECUTION_BRIEF_TEMPLATE.md) as the starting shape.

The execution brief should contain only:

- goal
- acceptance
- constraints
- scope
- evidence index
- planned edits
- decisions
- validation plan
- current status
- open risks

Do not turn the execution brief into a long narrative report.

## Architecture Decision Records

Use ADRs only for decisions that outlive the current task.

Create ADRs under:

- `$PWD/docs/adr/yyyy-MM-dd'T'HH-mm-ss'Z'_*.md`

Use the same UTC prefix rule used by the other saved artifacts.
If the ADR body includes any created or updated timestamp, use the same `UTC` format `yyyy-MM-dd'T'HH-mm-ss'Z'`.
Use [references/ADR_TEMPLATE.md](references/ADR_TEMPLATE.md) as the starting shape.

Create or update an ADR only when the decision is architecture-level, meaning most of these are true:

- it affects multiple files, modules, or workstreams
- it changes a long-lived API, CLI, schema, workflow, or boundary
- there were real alternatives worth considering
- future engineers are likely to ask why this path was chosen
- the decision may later be reversed, superseded, or refined

Do not create ADRs for local refactors, obvious bug fixes, naming choices, or one-off implementation details.

ADR workflow:

1. record the active task-local decision first in the execution brief or ExecPlan
2. search `$PWD/docs/adr` for an existing ADR that already covers the same decision space
3. if the decision is new and stable enough, create one ADR file for that single decision
4. if the decision changes or replaces an earlier ADR, update the earlier ADR status and cross-link the replacement
5. link the ADR back from the execution brief or ExecPlan so the task-local artifact and the long-lived record stay connected

## Resume And Source Of Truth Rules

Choose exactly one primary state source for the run using this order:

1. explicit user override such as `resume from review`
2. explicit artifact path from the user
3. active ExecPlan when the task is clearly part of an existing extended workstream
4. active execution brief
5. dirty working tree plus latest relevant review artifact
6. free-form request

If the repository is dirty:

- preserve user changes
- infer the furthest defensible completed gate
- resume from the next missing gate instead of restarting from scratch

Useful defaults:

- code changed and no review after it: resume at the review gate
- code changed and review found blockers: run a narrow fix pass, then rerun review
- only docs or execution brief changed: resume at the next needed planning or close step
- existing execution brief plus narrow same-task changes: continue with the same execution brief as the primary checkpoint
- existing ExecPlan plus narrow same-workstream changes: use follow-up mode

## Evidence Discipline

Prevent repeated broad rereads unless they are justified.

### Focused Recon

Start narrow.
Read the smallest set of files that can establish:

- the likely entry point
- the likely owning module
- the relevant tests or validation command
- the main uncertainty that could still change the fix

Prefer a few anchor files over whole-directory exploration.

### Evidence Index

While reading, keep an `evidence index` in the execution brief or in working notes:

- files already inspected
- facts already established
- unresolved questions
- next candidate files

### Reread Policy

Do not reread code just because a new phase started.
Reread only when one of these is true:

- the agent is about to edit that file
- review findings point back to that area
- validation failure invalidates the current hypothesis
- a newly discovered dependency makes the earlier read incomplete

## Standard Workflow

### 1. Intake

Normalize the request into:

- goal
- acceptance criteria
- constraints
- likely scope
- risk level

Classify the task as `fast`, `standard`, or `extended`.

### 2. Focused Recon

Inspect the narrowest useful repository surface first.

- use `rg` to find concrete anchors
- inspect nearby callers, implementations, and tests only as needed
- stop broad exploration once the next edit set is clear enough

If focused recon still leaves multiple plausible explanations or the failure surface remains unclear, escalate to `dev-investigate`.

### 3. Compact Planning

For `standard` work, create or refresh one compact execution brief.
Do not create an ExecPlan unless the task is truly `extended`.

The execution brief must be actionable enough that the agent can resume after interruption without rediscovering the whole task.

### 4. Implement

Implement the planned changes directly.
Keep the edit scope tight.
Update the execution brief only when reality changed:

- a decision changed
- the scope changed
- new evidence matters for resuming
- the validation plan changed

Do not regenerate the whole plan after each edit batch.

### 5. Review Gate

After repository-changing implementation work, run a review gate.
Use `dev-review` or an equivalent local review mindset against the actual changed scope.

Rules:

- review the implementation diff, not the whole repository
- treat blocking correctness, safety, regression, and data-loss findings as mandatory fix triggers
- if findings are non-blocking, record the risk and continue unless the user asked for more

If blocking findings exist, enter a narrow fix loop:

1. extract the concrete blockers
2. fix only those blockers and directly adjacent issues
3. rerun review only if the fix changed in-scope code, tests, or runtime configuration

### 6. Validation Gate

Run the smallest commands that can prove the change safely.

Prefer this order:

1. targeted tests
2. nearest relevant test suite
3. lint or typecheck only when it covers the changed surface
4. broader integration or app-level checks only when needed

Record only commands actually run and the concise observed result.

### 7. Close

Return a concise summary that states:

- what changed
- what was validated
- what remains risky or unverified
- which artifact, if any, should be used to resume later

### 8. ADR Check

Before closing, ask whether the final accepted design introduced or changed an architecture-level decision.

- if no, do nothing
- if yes, create or update the relevant ADR and link it from the active execution brief or ExecPlan

## Execution Brief Follow-up

When the active source of truth is an execution brief, handle follow-up work by continuing the same lightweight loop.

Do not invoke `dev-followup` for execution-brief work.
That skill exists for ExecPlan-led extended workstreams.

In execution-brief follow-up:

1. reuse the existing execution brief as the primary checkpoint
2. inspect the current diff and latest relevant review artifact
3. infer the next missing gate instead of restarting from intake
4. continue with the narrowest needed step:
   - review gate when code changed and no later review exists
   - narrow fix pass when the latest review found blockers still relevant to the current diff
   - validation gate when implementation is done and review is settled
   - close when only the brief or summary state needs refreshing
5. update only the execution-brief sections that changed:
   - `Evidence Index`
   - `Planned Edits`
   - `Decisions`
   - `Validation Plan`
   - `Current Status`
   - `Open Risks`
6. if the follow-up materially changed an existing architecture-level decision, update the relevant ADR or create a superseding ADR

Treat execution-brief follow-up as checkpoint refresh plus gate resumption, not as a new planning cycle.

## Escalation Rules For Heavy Skills

Use the heavier downstream skills only when they reduce real failure risk.

### Use `dev-investigate` when

- focused recon still leaves multiple credible root causes
- the task depends on deeper repository archaeology
- external facts or unstable upstream behavior matter

### Use `dev-spec` when

- user-visible requirements need to be fixed before coding
- the task changes an API, CLI, schema, workflow, or contract
- multiple valid implementations exist and the boundary needs to be frozen first

### Use `dev-plan` when

- the task is clearly multi-milestone
- restartability matters more than raw speed
- a compact execution brief would be too weak for safe continuation

When an ExecPlan becomes the active source of truth, stop maintaining a parallel execution brief.

### Use `dev-followup` when

- there is an existing active ExecPlan
- the current request is a narrow same-workstream continuation
- the plan and adjacent docs would drift without synchronization

### Use `dev-walkthrough` when

- the user asks for a reading path
- the final change is large enough that a guided reading path materially helps

### Use `dev-recap` when

- the user wants a handoff or session summary
- the run created enough context that a saved recap is worth the extra tokens

Do not make `dev-walkthrough` or `dev-recap` mandatory completion steps.

## ExecPlan Follow-up Mode

Use follow-up mode only for narrow extensions to an existing extended workstream.

In ExecPlan follow-up mode:

1. keep the existing ExecPlan as the primary source of truth
2. perform the narrow implementation, review, and validation loop
3. run `dev-followup` if the plan or downstream artifacts would otherwise become stale
4. update or supersede ADRs when the follow-up changed a previously accepted architecture decision

Do not reopen a completed workstream in ExecPlan follow-up mode when the new request is effectively a new project.

## Subagent Rules

Default to not using subagents for the main implementation loop.

If subagents are used:

- delegate only bounded, non-overlapping tasks
- prefer sidecar investigation or verification over main-path delegation
- do not use `fork_context=true` unless the sidecar task really needs the full thread history
- pass only the minimum task-local context, relevant paths, and expected output

The main thread remains responsible for:

- choosing the task class
- choosing whether to escalate
- deciding when enough recon has happened
- integrating sidecar results
- running or approving the final implementation, review, and validation gates

## Guardrails

- Do not force `dev-investigate` or `dev-plan` for every task.
- Do not create a long artifact chain when a compact memo is enough.
- Do not treat a new phase as a reason to reread the whole same code path.
- Do not run `dev-walkthrough` or `dev-recap` by default.
- Do not skip the review gate after repository-changing implementation work.
- Do not skip validation when a realistic command exists.
- Do not lose track of the current source of truth.
- Do not preserve stale memo or plan statements that contradict the current implementation.
- Do not create ADRs for task-local decisions that belong only in the execution brief or ExecPlan.

## Quality Bar

- The workflow should feel fast on small tasks and disciplined on risky tasks.
- The default path should minimize rereads, repeated artifact churn, and broad context fan-out.
- Heavy phases should be deliberate escalations, not rituals.
- Another engineer should be able to resume from the active execution brief or ExecPlan without redoing the original recon.
