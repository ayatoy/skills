---
name: dev-followup
description: Sync an existing ExecPlan-led workstream after post-implementation follow-up changes. Use when a completed or in-flight feature receives narrow fixes or refinements and the active plan and adjacent docs must be brought back in line with the current code, validation, and decisions. Use only for extended workstreams whose source of truth is an ExecPlan, not for lightweight execution-brief follow-up.
---

# dev-followup

Keep a previously planned workstream aligned with reality after follow-up implementation changes.

This skill is for the phase after the main feature implementation already exists. It assumes there is an existing ExecPlan or a clearly identifiable workstream under `$PWD/docs/plans`.

This is the heavyweight follow-up path.
If the workstream is being tracked only by an execution brief, resume it in `dev-orchestrate` instead of invoking `dev-followup`.

## Use Cases

Use `dev-followup` when most of these are true:

- the repository already has an ExecPlan for the relevant workstream
- the main implementation or orchestration cycle already happened, or is clearly in progress
- the user asks for a narrow fix, refinement, behavior tweak, UI adjustment, wording cleanup, or small scope extension
- the active plan or adjacent docs risk drifting from the current implementation

Do not use `dev-followup` for:

- creating the first plan for a new workstream
- broad greenfield implementation from a free-form request
- writing a session recap from scratch when there is no follow-up implementation context
- lightweight execution-brief follow-up that does not have an active ExecPlan

If no valid target ExecPlan exists, stop and hand off to `dev-plan`.

## Inputs

- an explicit plan path under `$PWD/docs/plans/...`
- a free-form follow-up request tied to an already implemented or already planned feature
- a dirty working tree that clearly belongs to an existing planned workstream
- optional adjacent artifact paths:
  - `$PWD/docs/specs/...`
  - `$PWD/docs/walkthroughs/...`
  - `$PWD/docs/recaps/...`

## Output Contract

`dev-followup` must update exactly one primary ExecPlan in place.

The primary output is:

- one updated plan under `$PWD/docs/plans/...`

Optional secondary outputs are allowed only when the propagation rules below say they are necessary:

- one updated spec under `$PWD/docs/specs/...`
- one updated recap under `$PWD/docs/recaps/...`
- one new or explicitly user-requested updated walkthrough under `$PWD/docs/walkthroughs/...`

Keep saved artifacts in the user's language unless the user asks otherwise.
Never emit local absolute filesystem paths inside saved artifacts. Use repo-local relative Markdown links or `$PWD/...` placeholders when prose must mention workspace-rooted paths.

## Primary Target Selection

Choose exactly one primary plan target using this order:

1. an explicit plan path from the user
2. the active plan selected by an upstream workflow such as `dev-orchestrate`
3. the newest relevant ExecPlan under `$PWD/docs/plans/` that matches the changed files, feature area, or nearby artifacts

If multiple plans are plausible, prefer the one whose linked files, feature naming, or recent edits most closely match the current follow-up.
If the ambiguity is still material and choosing wrong would corrupt documentation, ask one concise question.

## Evidence To Inspect

Inspect only what is needed to sync the workstream accurately:

- the current diff and changed files
- the target ExecPlan and its living sections
- recent commands actually run during the follow-up
- observed outputs, failures, or behavior changes that affected implementation choices
- nearby spec, walkthrough, or recap artifacts only if the propagation rules suggest they may now be stale

Do not bulk-rewrite every downstream artifact by default.

## Standard Workflow

1. Resolve the primary plan target.
2. Read the plan sections that can drift:
   - `Progress`
   - `Surprises & Discoveries`
   - `Decision Log`
   - `Outcomes & Retrospective`
   - `Concrete Steps`
   - `Validation and Acceptance`
3. Inspect the follow-up implementation delta and determine what actually changed:
   - behavior
   - rationale
   - validation evidence
   - remaining risks
4. Rewrite stale plan statements so the plan reads coherently at its new current state.
5. Append only the net-new evidence that another engineer would need to understand the follow-up.
6. Apply the propagation rules to decide whether a spec, walkthrough, or recap also needs an update.

Treat the plan as a synchronized source of truth, not an append-only log.

## Plan Update Rules

### Progress

Update `Progress` whenever the follow-up changed code, tests, validation status, or next steps.

- Add a new checkbox item when the follow-up is a distinct work step worth preserving as a separate milestone.
- Rewrite an existing incomplete item when the follow-up merely changes the current state of that already-open step.
- Split an item into completed versus remaining work when the follow-up only partially closes it.
- Use timestamps for new entries.
- Keep the section readable as the current truth, not as a raw historical dump.

### Surprises & Discoveries

Update this section only for information that was genuinely discovered during the follow-up, such as:

- a bug cause that was not understood before
- a framework or browser behavior that constrained the fix
- an unexpected interaction between files, data shapes, or UI elements
- an observation from validation that changed the implementation choice

Do not add routine implementation summaries here.
Each entry should include brief evidence such as a failing scenario, test name, or observed behavior.

### Decision Log

Record every follow-up decision that changes behavior, scope, tradeoffs, or implementation direction.

Each decision entry must state:

- what was decided
- why that path was chosen instead of the nearby alternatives
- the date and author

Use this section for judgments such as UI placement changes, deletion flow changes, flattening or simplification decisions, or scope containment choices.
Do not use it for trivial file edits with no meaningful decision behind them.

### Outcomes & Retrospective

Update this section after each meaningful follow-up batch so a reader can answer:

- what is better now
- what still remains
- what the follow-up taught us about the feature or plan quality

Rewrite stale outcome statements instead of stacking contradictory summaries.

### Concrete Steps

Update `Concrete Steps` when the practical execution recipe changed because of the follow-up.

Examples:

- a command must now be run differently
- a new verification path matters
- a file or function named in the plan is no longer the right place to look

Do not churn this section when the operational recipe is unchanged.

### Validation and Acceptance

Keep this section aligned with what was actually revalidated.

- Add or refresh the exact commands that were run during the follow-up.
- Record only commands that were actually executed.
- Prefer commands that prove behavior, not exploratory searches.
- When a prior validation command was not rerun and the follow-up does not materially affect it, leave it as-is.
- When acceptance expectations changed, rewrite them to match the new behavior.

For each newly recorded validation command, include:

- working directory when it matters
- exact command
- concise observed result

## Propagation Rules

### Update The Spec When

Update a related spec only when the follow-up changed any of these:

- user-visible behavior
- acceptance criteria
- API, CLI, schema, or data contract
- explicit UI or workflow requirements
- constraints or invariants that another engineer must now treat as part of the feature definition

Do not update the spec for implementation-only fixes that preserve the existing requirement boundary.

### Update The Walkthrough When

Update or regenerate a walkthrough only when most of these are true:

- the recommended reading path materially changed
- the important files or flow order changed enough that the old walkthrough is misleading
- the user asked for a refreshed pathfinder or reading path

Prefer creating a new walkthrough note unless the user explicitly asked to update an existing one.
Do not churn walkthrough artifacts for minor fixes that do not change how a reviewer should read the code.

### Update The Recap When

Update the existing recap for the same workstream when the follow-up materially changes:

- current status
- unresolved risks
- handoff notes
- the concrete story of what happened in the session

Prefer updating the existing recap note in place when it is clearly the same workstream.
Do not create a new recap artifact for a small follow-up unless the user explicitly asks for a separate recap.

## Guardrails

- Never invent commands, results, or observations.
- Never leave the plan with stale statements that contradict the current implementation.
- Do not treat every tiny edit as a spec change.
- Do not rewrite unrelated sections just because the plan file is open.
- Preserve the distinction between confirmed facts and inference.
- If the follow-up grows beyond a narrow extension and starts redefining scope broadly, stop and hand off to `dev-plan` or `dev-orchestrate`.

## Quality Bar

- Another engineer should be able to read the updated plan and understand the follow-up without opening the full session transcript.
- The plan should read like one coherent living document, not like a pile of appended notes.
- Validation records should show what was actually rerun and what was observed.
- Downstream artifact updates should be selective and justified, not automatic churn.
