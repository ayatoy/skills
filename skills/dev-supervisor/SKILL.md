---
name: dev-supervisor
description: Orchestrate an end-to-end repository workflow by supervising the local skills in this repo. Usually start with `dev-investigator`, then optionally run `dev-resolver` and `dev-specifier`, use `dev-planner` to create and execute an ExecPlan, run a `dev-reviewer`-driven fix loop until blocking issues are resolved, then run `dev-pathfinder`, and finish with `dev-recapper`. When the workspace already shows in-progress dev-supervisor artifacts or repository changes, infer the current phase and resume or interrupt from there. Support `execution_mode=auto|local|subagents` so the same workflow can run either with phase subagents or entirely in the main thread.
---

# dev-supervisor

Supervise a full repository workstream from investigation through implementation review and session recap.

A complete dev-supervisor cycle always ends with exactly one `dev-pathfinder` run followed by exactly one `dev-recapper` run.
For a completed cycle, each of those phases must produce exactly one main artifact for that cycle.

Keep the AI assistant in the main thread as the orchestrator.
Resolve an execution mode before dispatching any phase work.

## Inputs

- No explicit input, in which case inspect the workspace and infer whether a dev-supervisor cycle is already in progress
- A free-form request describing a problem, goal, bug, feature, or investigation topic
- Or an existing artifact path to resume from:
  - `$PWD/docs/investigations/...`
  - `$PWD/docs/reviews/...`
  - `$PWD/docs/walkthroughs/...`
  - `$PWD/docs/recaps/...`
  - `$PWD/docs/specs/...`
  - `$PWD/docs/plans/...`
- Or an already-dirty repository state, including manual user edits, staged changes, or partially completed dev-supervisor artifacts
- Optional constraints:
  - stop after a named phase
  - resume from a named phase
  - execution mode
  - language
  - timebox

When the user provides a `.md` file path or pasted markdown as source material for the workflow, pass that markdown artifact through to the next phase as the primary input instead of paraphrasing it into a shorter surrogate.

## Execution Mode Selection

`dev-supervisor` supports `execution_mode` values:

- `auto`: default behavior; use phase subagents when available, otherwise run locally in the main thread
- `local`: do not use `spawn_agent`; run each phase locally in the main thread in the same workflow order
- `subagents`: use a separate subagent for each phase unless a real platform limitation prevents it

Users may specify the mode either with an exact token such as `execution_mode=local` or natural language such as:

- `no subagents`
- `run locally`
- `main thread only`
- `use subagents`

Document canonical execution-mode intents in English, but interpret the user's actual language semantically.

Treat intents like these as valid signals for `local`:

- `no subagents`
- `run locally`
- `main thread only`
- `do this without delegation`

Treat intents like these as valid signals for `subagents`:

- `use subagents`
- `delegate each phase`
- `run this with subagents`
- `use the normal delegated flow`

Treat vague phrases like these as insufficient on their own:

- `keep it simple`
- `just do it`
- `go ahead`
- `use the usual approach`

Interpret the user's wording by intent rather than exact phrase matching.
Treat the English examples above as representative phrases, not the only accepted wording.
Interpret equivalent phrasing in the user's language semantically rather than requiring exact trigger phrases.
Minor wording differences, tense differences, and polite phrasing should not matter.
Ambiguous phrasing should still be treated as ambiguous even if it contains words like `local`, `delegate`, `subagent`, or `main thread`.
When the user's wording suggests a preference about execution style but does not clearly resolve to `local` or `subagents`, ask one short clarification question before switching modes.
If multiple explicit mode directives conflict, honor the last explicit one.
If no explicit mode is given, default to `auto`.
Briefly state the resolved execution mode near the start of the run, for example `Execution mode: local`.

## Default Workflow

1. `dev-investigator`
2. optional `dev-resolver` when major unresolved questions would destabilize later decisions
3. `dev-specifier` when a separable spec would materially improve execution
4. `dev-planner` to create or update an ExecPlan
5. `dev-planner` again to execute the ExecPlan
6. `dev-reviewer`
7. implementation fix pass when the review finds blocking issues that should be fixed now
8. repeat `dev-reviewer` and implementation until blocking issues are resolved or a real blocker remains
9. `dev-pathfinder`
10. `dev-recapper`

## Resume And Interrupt Rules

Infer the starting phase from the strongest available evidence, not only from the current prompt.

Use this precedence order:

1. explicit user override such as `resume from dev-reviewer` or `stop after dev-planner`
2. strongest workspace evidence from the current repository state
3. strongest artifact the user provides directly
4. free-form request intent

When there is no explicit input, or when the repository already has relevant uncommitted changes, inspect the workspace before defaulting to `dev-investigator`.
Treat pre-existing repository changes as a likely interrupted or manually advanced workflow and resume from the inferred current phase instead of restarting the pipeline from scratch.

### Workspace State Inspection

Inspect the repository for:

- uncommitted changes in tracked or untracked files
- the newest artifacts under `$PWD/docs/investigations`, `$PWD/docs/reviews`, `$PWD/docs/walkthroughs`, `$PWD/docs/recaps`, `$PWD/docs/specs`, and `$PWD/docs/plans`
- when needed for resume compatibility, the newest legacy artifacts under `$PWD/docs/notes`
- whether the newest plan file looks created-only versus partially executed
- whether a recent review note series exists
- whether recent `dev-pathfinder` or `dev-recapper` notes already exist for the same workstream
- whether the changed files are mostly workflow artifacts, implementation files, or both

Use modification recency, artifact linkage, filenames, and content cues together.
Do not rely on timestamps alone when filenames or note contents indicate a clearer ordering.

### Dirty Repository Heuristic

If the repository is dirty before the dev-supervisor starts, assume one of these first:

- an earlier dev-supervisor run stopped after or during implementation
- the user manually continued the work outside `dev-supervisor`
- the user is intentionally interrupting the normal flow with manual edits

In those cases, prefer continuing from the furthest defensible phase already reached.

- If code or test files changed and no review note exists yet, resume at `dev-reviewer`.
- If code or test files changed and the newest review note contains blocking findings that match the current diff, resume with a narrow implementation pass, then rerun `dev-reviewer`.
- If only workflow artifacts changed and the newest artifact is an investigation note, resume from `dev-resolver`, `dev-specifier`, or `dev-planner` as appropriate.
- If the newest artifact is a spec and there is no newer plan, resume at `dev-planner` plan creation.
- If the newest artifact is an ExecPlan and repository changes suggest implementation has not started, resume at `dev-planner` execution.
- If implementation changes and a clean post-review reading path already exist, resume at `dev-recapper`.
- If implementation changes exist but both a final `dev-pathfinder` note and a final recap note already exist for the same workstream, treat that cycle as complete and do not automatically start a new one unless the user asks.

Manual user edits are an interrupt, not noise.
Preserve them, treat them as the latest implementation state, and route the workflow to the next missing supervisory phase.

- If the input is mainly a free-form request and there is no stronger workspace evidence, start with `dev-investigator`.
- If the input is a note under `$PWD/docs/investigations`, `$PWD/docs/reviews`, `$PWD/docs/walkthroughs`, `$PWD/docs/recaps`, or legacy `$PWD/docs/notes`, classify it before resuming:
  - treat it as an investigation note when it matches `dev-investigator`-style sections such as `Topic and scope`, `Findings`, or `Open questions and risks`
  - treat it as a reviewer note when it matches `dev-reviewer`-style sections such as `Findings`, `Open questions / assumptions`, or `Residual risks`
  - treat it as a pathfinder note when it matches `dev-pathfinder`-style sections such as `Target`, `Mode`, `Start here`, or `Path`
  - treat it as a recap note when it matches `dev-recapper`-style sections such as `Session chronology`, `Current status`, or `Repeated work patterns`
  - do not automatically resume the main workflow from dev-reviewer, dev-pathfinder, or recap notes; use them as downstream context only unless the user explicitly names the next phase
- If the input is an investigation note, start from `dev-resolver` or `dev-specifier`, then continue forward.
- If the input is a spec under `$PWD/docs/specs`, start from `dev-planner`.
- If the input is an ExecPlan under `$PWD/docs/plans`, start from `dev-planner` execution.
- If the user explicitly names a phase, respect that unless it would skip required upstream context.

### Phase Inference Checklist

Choose the next phase by finding the latest reliable completed milestone:

1. If no relevant artifacts or changes exist, start with `dev-investigator`.
2. If an investigation artifact exists but no plan-driving artifact exists after it, continue with `dev-resolver`, `dev-specifier`, or `dev-planner`.
3. If a spec exists and no newer ExecPlan exists, continue with `dev-planner` plan creation.
4. If an ExecPlan exists but there is no evidence of implementation changes after it, continue with `dev-planner` execution.
5. If implementation changes exist but no review artifact exists after those changes, continue with `dev-reviewer`.
6. If a review artifact exists after the latest implementation changes:
   - continue with a fix pass when the review has blocking findings
   - otherwise continue with `dev-pathfinder`
7. If a `dev-pathfinder` artifact exists after the final implementation and review state, continue with `dev-recapper`.
8. If a recap artifact exists after the final `dev-pathfinder` artifact, treat the cycle as complete unless the user asks to extend it.

When evidence conflicts, prefer the interpretation that preserves user work and requires the fewest repeated phases.
If two interpretations are equally plausible and choosing the wrong one would risk overwriting or misreviewing user changes, ask one concise question.

## Supervisor Responsibilities

The AI assistant in the main thread is responsible for:

- deciding the current phase
- resolving the execution mode
- inferring whether the workspace reflects a fresh request, a paused dev-supervisor cycle, or a manual interrupt
- spawning and coordinating subagents when the resolved execution mode uses them
- performing the phase locally when the resolved execution mode is `local` or when `auto` falls back locally
- passing the minimum necessary context to each phase
- collecting artifact paths and key outcomes
- keeping track of the active ExecPlan path once `dev-planner` has created or selected it
- deciding whether optional phases should run or be skipped
- handling retries or fallbacks
- ensuring implementation work that changes the repository is reflected back into the active ExecPlan
- preserving user-created changes and incorporating them into the inferred workflow state instead of discarding them
- giving the user a concise final summary
- ensuring saved artifacts produced by downstream skills never expose machine-specific filesystem absolute paths and use `$PWD/...` placeholders when a workspace-rooted path must appear in prose

The main thread should not duplicate the deep work already delegated to a subagent unless that delegation clearly failed.
- Ensure every saved artifact and user-facing deliverable produced by downstream skills matches the user's language unless the user asks otherwise.

## Execution Strategy

The workflow phases, artifact contracts, review loop, and completion criteria do not change across execution modes.
Only the phase execution mechanism changes.

### `auto`

Use subagents by default for every phase when `spawn_agent` is available.
If subagents are unavailable or clearly unsuitable for the current phase, run that phase locally in the same order and say so briefly.

### `local`

Do not call `spawn_agent`.
Run each phase directly in the main thread in the same order, using the same upstream artifacts and acceptance criteria that would apply to a delegated phase.
Do not weaken the workflow just because the run is local.

### `subagents`

Use a separate subagent for each work phase unless a real platform limitation prevents it.
If a required phase cannot run in a subagent, say so briefly and fall back to a local run for that phase rather than abandoning the workflow.

### Subagent Dispatch Rules

- Spawn one subagent per phase.
- Use `fork_context=true` unless isolation is clearly better.
- In the subagent prompt, explicitly invoke the target skill by name, for example `Use $dev-investigator ...` or `Use $dev-planner ...`, so the intended skill actually triggers.
- When delegating from a user-provided `.md` document, pass the original document path or pasted markdown through directly and state that it is the primary input; do not replace it with a dev-supervisor-authored summary unless the user explicitly asks for one.
- Give each subagent a narrow task with:
  - the phase name
  - the exact user goal
  - the artifact paths it should use
  - the expected output
- Pass the user's language expectation explicitly when it affects saved artifacts or user-facing deliverables.
- Pass the artifact path redaction rule explicitly when a phase will save or edit markdown: never emit local filesystem absolute paths such as `/Users/...`; use `$PWD/...` placeholders or repo-local relative links instead.
- Keep write phases sequential when they may touch the same artifact.
- `dev-reviewer` is read-only, but the dev-supervisor may schedule a write-capable fix pass between review iterations.
- Run `dev-pathfinder` exactly once after the review and implementation loop is complete.
- Run `dev-recapper` exactly once after `dev-pathfinder`, as the final phase of a completed dev-supervisor cycle.
- Do not create multiple main `dev-pathfinder` artifacts or multiple main `dev-recapper` artifacts for one completed dev-supervisor cycle.

## Phase Selection Rules

### 1. Investigator

This is the default entry point.

- Always run `dev-investigator` first unless the user provided a stronger resume artifact.
- Expect one main report under `$PWD/docs/investigations/yyyy-MM-dd'T'HH-mm-ss'Z'_*.md`.
- Use that report as the canonical source for downstream phases.

### 2. Resolver

`dev-resolver` is optional.
Run it only when leaving the open questions unresolved would materially weaken planning or implementation decisions.

Typical triggers:

- the investigation note has large open questions, unknowns, or risks that could change architecture, scope, or execution order
- the unresolved questions are important enough that plan quality or implementation direction would likely drift without a best-effort answer
- the report contains major decision forks that should be collapsed before planning

Skip `dev-resolver` when the remaining unknowns are minor, clearly non-blocking, or already resolved enough that planning and implementation can proceed without meaningful drift.

### 3. Specifier

`dev-specifier` is optional.

Use it when the work would benefit from an explicit spec, for example:

- new features
- behavior changes with user-facing impact
- API, CLI, schema, workflow, or contract changes
- work with multiple plausible implementations where a crisp requirement boundary helps

Skip it for narrow bug fixes, small local refactors, and execution work that is already well-scoped by the investigation note.

### 4. Planner For Plan Creation

Run `dev-planner` to create or update an ExecPlan using:

- the investigation note
- the resolved note if `dev-resolver` edited it or produced a sibling file
- the spec if one exists

Expect one primary ExecPlan under `$PWD/docs/plans/yyyy-MM-dd'T'HH-mm-ss'Z'_*.md`.

### 5. Planner For Execution

After plan creation, run `dev-planner` again to execute the plan.

Important:

- Pass the exact ExecPlan file path as the primary input to the second `dev-planner` run.
- This satisfies `dev-planner`'s explicit execution rule; do not rely on vague approval text.
- In `subagents` mode, keep the main thread focused on supervision while the dev-planner execution subagent performs the implementation.
- In `local` mode, execute the same plan in the main thread without changing the plan's scope or acceptance bar.
- Treat the ExecPlan selected here as the active plan file for the rest of the dev-supervisor cycle.

### 6. Reviewer

After implementation, run `dev-reviewer` against the implementation diff unless the user specified a narrower target.

- Prefer `change-review`.
- Default review scope to code, tests, and runtime configuration changed by the implementation phase.
- Exclude workflow artifacts such as notes, specs, and plan-file churn unless the user explicitly wants them reviewed or they are the only meaningful changes.
- When invoking `dev-reviewer`, pass an explicit target rooted in the implementation diff; do not ask it to inspect the whole dirty working tree when review artifacts were just created.
- Require `dev-reviewer` to inspect the latest same-target review artifact before each pass and use it as the deduplication baseline.
- Expect one main markdown review note under `$PWD/docs/reviews/yyyy-MM-dd'T'HH-mm-ss'Z'_*.md`.
- Treat findings as primary output.
- Capture any unresolved questions or testing gaps for the final summary.
- Require each rerun to record only net-new findings or material status deltas; unchanged prior findings should remain in the earlier review artifact instead of being repeated.
- If the first post-implementation review has no blocking findings, end the review loop immediately and continue to `dev-pathfinder`; do not rerun `dev-reviewer` just to reconfirm a clean result.
- If the review surfaces blocking, high-confidence findings that should be fixed now, enter a review and implementation loop:
  - extract the concrete findings that require changes
  - run a narrowly scoped implementation pass to fix them
  - rerun `dev-reviewer` only when that fix pass changed code, tests, or runtime configuration inside the review scope
  - if that fix implementation changes the repository, append the work performed to the active ExecPlan before rerunning `dev-reviewer`
  - rerun `dev-reviewer` on the updated implementation diff, not on the full dirty tree
  - continue until no blocking findings remain or a real blocker prevents a safe fix
- If the attempted fix pass is a no-op or touches only workflow artifacts, do not rerun `dev-reviewer`; carry the blocker or remaining risk into the final summary instead.
- Treat correctness, security, data loss, crash, obvious regression, and equivalent P0 or P1 issues as blocking by default.
- Non-blocking findings, residual risks, and speculative questions do not require another implementation pass unless the user asks for it.
- Each rerun of `dev-reviewer` should produce a new review artifact that continues the prior review artifact's filename series.

### 7. Pathfinder

Run `dev-pathfinder` only after the review and implementation loop is complete.

- Prefer `review` mode for diffs.
- Use the final post-fix implementation state as the input scope.
- Optimize for the code-reading path first; include workflow artifacts only when they clarify behavior or user intent.
- Optimize for the user's own follow-up reading and verification path.
- Expect one main markdown reading-path note under `$PWD/docs/walkthroughs/yyyy-MM-dd'T'HH-mm-ss'Z'_*.md`.
- Run this phase exactly once per completed dev-supervisor cycle.

### 8. Recapper

Run `dev-recapper` after `dev-pathfinder` as the final phase of the completed dev-supervisor cycle.

- Use it to create a handoff-quality summary note for the current session.
- This is always the last phase of a completed dev-supervisor cycle.
- Expect exactly one main recap note under `$PWD/docs/recaps/yyyy-MM-dd'T'HH-mm-ss'Z'_*.md` for the cycle; if `dev-recapper` is rerun for the same cycle, it should update that artifact rather than create a second recap note.

## Standard Orchestration Sequence

1. Normalize the input, inspect the workspace when needed, and determine whether this is a new run, a resume, or a manual interrupt.
2. Resolve `execution_mode` and dispatch the next phase accordingly:
   - use a subagent when the resolved mode for that phase is `subagents`
   - otherwise run the phase locally in the main thread
3. Inspect the returned artifact path or summary, not the entire task from scratch.
4. Decide the next phase:
   - continue
   - skip an optional phase
   - retry once with tighter instructions
   - stop on a real blocker
5. After implementation, run `dev-reviewer`.
6. If `dev-reviewer` finds no blocking issues, stop the review loop immediately and continue to `dev-pathfinder`.
7. If `dev-reviewer` finds blocking issues that should be fixed now, run a narrow implementation pass; only rerun `dev-reviewer` when that pass changed code, tests, or runtime configuration in scope, and update the active ExecPlan before the rerun when repository changes were made.
8. Repeat step 7 until no blocking findings remain or a real blocker prevents further safe changes.
9. Run `dev-pathfinder` exactly once on the final post-loop implementation state.
10. Run `dev-recapper` exactly once after `dev-pathfinder`.
11. Return a concise summary with:
   - completed phases
   - skipped phases
   - created or updated artifacts
   - major findings, blockers, and next actions

## Retry And Failure Rules

- If a phase fails because the prompt was too broad, rerun once with tighter scope.
- If a phase fails because a required artifact is missing, inspect the workspace, recover the latest relevant artifact if possible, and continue.
- If the workspace shows strong evidence of a partially completed cycle, prefer resuming from that evidence over restarting earlier phases.
- If a subagent-dispatched phase fails for execution-mechanism reasons rather than task reasons, rerun that phase locally with the same scope before giving up.
- If a phase is blocked by a real ambiguity that the AI assistant cannot responsibly infer, stop and ask the user one concise question.
- Do not silently skip `dev-investigator`, `dev-planner`, or implementation review.

## Guardrails

- Do not jump straight into implementation from a free-form request; `dev-investigator` is the default first step.
- Do not restart from `dev-investigator` when stronger workspace evidence shows the cycle already progressed further.
- Do not force `dev-resolver` or `dev-specifier` when they add ceremony without improving decisions.
- Do not run multiple implementation-capable subagents against overlapping write scopes at the same time.
- Do not change the workflow order, artifact contract, or review rigor based only on `execution_mode`.
- Do not treat a dev-planner-created plan as executed until the second `dev-planner` run finishes.
- Do not end the workflow after implementation without running `dev-reviewer`.
- Do not run `dev-pathfinder` before the review and implementation loop is complete.
- Do not finish a completed dev-supervisor cycle without running `dev-pathfinder` and then `dev-recapper`.
- Do not run `dev-pathfinder` or `dev-recapper` more than once in a single completed dev-supervisor cycle.
- Do not ignore a blocking review finding that the AI assistant can safely fix in the current workflow.
- Do not rerun `dev-reviewer` after a clean review or after a no-op fix pass.
- Do not lose the artifact chain; always know which note, spec, and plan the current phase is based on.

## Quality Bar

- The workflow should feel like a supervised pipeline, not a loose checklist.
- Resume and interrupt decisions should be conservative, artifact-aware, and biased toward preserving already completed work.
- Each downstream phase should consume concrete upstream artifacts whenever possible.
- Optional phases should be skipped deliberately, not forgotten.
- The final summary should let the user see what happened, what was created, and what still needs attention.
