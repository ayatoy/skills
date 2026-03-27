---
name: supervisor
description: Orchestrate an end-to-end repository workflow by supervising the local skills in this repo. Always start with `investigator`, then optionally run `resolver` and `specifier`, use `planner` to create and execute an ExecPlan, run `reviewer` and `pathfinder` on the result, and finish with `recapper`. Prefer running each phase in a subagent while DEM stays in the main thread as the supervisor.
---

# Workflow Supervisor

Supervise a full repository workstream from investigation through implementation review and session recap.

Keep DEM in the main thread as the orchestrator.
Use a separate subagent for each work phase whenever subagents are available.

## Inputs

- A free-form request describing a problem, goal, bug, feature, or investigation topic
- Or an existing artifact path to resume from:
  - `$PWD/docs/notes/...`
  - `$PWD/docs/specs/...`
  - `$PWD/docs/plans/...`
- Optional constraints:
  - stop after a named phase
  - resume from a named phase
  - skip recap
  - language
  - timebox

## Default Workflow

1. `investigator`
2. optional `resolver` when major unresolved questions would destabilize later decisions
3. `specifier` when a separable spec would materially improve execution
4. `planner` to create or update an ExecPlan
5. `planner` again to execute the ExecPlan
6. `reviewer`
7. `pathfinder`
8. `recapper`

## Resume Rules

Infer the starting phase from the strongest artifact the user provides.

- If the input is mainly a free-form request, start with `investigator`.
- If the input is a note under `$PWD/docs/notes`, classify it before resuming:
  - treat it as an investigation note when it matches `investigator`-style sections such as `Topic and scope`, `Findings`, or `Open questions and risks`
  - treat it as a reviewer note when it matches `reviewer`-style sections such as `Findings`, `Open questions / assumptions`, or `Residual risks`
  - treat it as a pathfinder note when it matches `pathfinder`-style sections such as `Target`, `Mode`, `Start here`, or `Path`
  - treat it as a recap note when it matches `recapper`-style sections such as `Session chronology`, `Current status`, or `Repeated work patterns`
  - do not automatically resume the main workflow from reviewer, pathfinder, or recap notes; use them as downstream context only unless the user explicitly names the next phase
- If the input is an investigation note, start from `resolver` or `specifier`, then continue forward.
- If the input is a spec under `$PWD/docs/specs`, start from `planner`.
- If the input is an ExecPlan under `$PWD/docs/plans`, start from `planner` execution.
- If the user explicitly names a phase, respect that unless it would skip required upstream context.

## Supervisor Responsibilities

DEM in the main thread is responsible for:

- deciding the current phase
- spawning and coordinating subagents
- passing the minimum necessary context to each phase
- collecting artifact paths and key outcomes
- deciding whether optional phases should run or be skipped
- handling retries or fallbacks
- giving the user a concise final summary

The main thread should not duplicate the deep work already delegated to a subagent unless that delegation clearly failed.

## Subagent Rules

Use subagents by default for every phase when `spawn_agent` is available.

- Spawn one subagent per phase.
- Use `fork_context=true` unless isolation is clearly better.
- In the subagent prompt, explicitly invoke the target skill by name, for example `Use $investigator ...` or `Use $planner ...`, so the intended skill actually triggers.
- Give each subagent a narrow task with:
  - the phase name
  - the exact user goal
  - the artifact paths it should use
  - the expected output
- Keep write phases sequential when they may touch the same artifact.
- `reviewer` and `pathfinder` are read-only and may run in parallel after implementation is complete.
- If subagents are unavailable, run the workflow locally in the same order and say so briefly.

## Phase Selection Rules

### 1. Investigator

This is the default entry point.

- Always run `investigator` first unless the user provided a stronger resume artifact.
- Expect one main report under `$PWD/docs/notes/yyyy-MM-dd_*.md`.
- Use that report as the canonical source for downstream phases.

### 2. Resolver

`resolver` is optional.
Run it only when leaving the open questions unresolved would materially weaken planning or implementation decisions.

Typical triggers:

- the investigation note has large open questions, unknowns, or risks that could change architecture, scope, or execution order
- the unresolved questions are important enough that plan quality or implementation direction would likely drift without a best-effort answer
- the report contains major decision forks that should be collapsed before planning

Skip `resolver` when the remaining unknowns are minor, clearly non-blocking, or already resolved enough that planning and implementation can proceed without meaningful drift.

### 3. Specifier

`specifier` is optional.

Use it when the work would benefit from an explicit spec, for example:

- new features
- behavior changes with user-facing impact
- API, CLI, schema, workflow, or contract changes
- work with multiple plausible implementations where a crisp requirement boundary helps

Skip it for narrow bug fixes, small local refactors, and execution work that is already well-scoped by the investigation note.

### 4. Planner For Plan Creation

Run `planner` to create or update an ExecPlan using:

- the investigation note
- the resolved note if `resolver` edited it or produced a sibling file
- the spec if one exists

Expect one primary ExecPlan under `$PWD/docs/plans/yyyy-MM-dd_*.md`.

### 5. Planner For Execution

After plan creation, run `planner` again to execute the plan.

Important:

- Pass the exact ExecPlan file path as the primary input to the second `planner` run.
- This satisfies `planner`'s explicit execution rule; do not rely on vague approval text.
- Keep the main thread focused on supervision while the planner execution subagent performs the implementation.

### 6. Reviewer

After implementation, run `reviewer` against the implementation diff unless the user specified a narrower target.

- Prefer `change-review`.
- Default review scope to code, tests, and runtime configuration changed by the implementation phase.
- Exclude workflow artifacts such as notes, specs, and plan-file churn unless the user explicitly wants them reviewed or they are the only meaningful changes.
- Expect one main markdown review note under `$PWD/docs/notes/yyyy-MM-dd_*.md`.
- Treat findings as primary output.
- Capture any unresolved questions or testing gaps for the final summary.

### 7. Pathfinder

After implementation, run `pathfinder` on the same narrowed reviewed scope.

- Prefer `review` mode for diffs.
- Optimize for the code-reading path first; include workflow artifacts only when they clarify behavior or user intent.
- Optimize for the user's own follow-up reading and verification path.
- Expect one main markdown reading-path note under `$PWD/docs/notes/yyyy-MM-dd_*.md`.

### 8. Recapper

Run `recapper` after the major work is complete unless the user asked to skip it.

- Use it to create a handoff-quality summary note for the current session.
- This is normally the last phase.

## Standard Orchestration Sequence

1. Normalize the input and determine the starting phase.
2. Spawn the phase subagent and wait for its main artifact or final result.
3. Inspect the returned artifact path or summary, not the entire task from scratch.
4. Decide the next phase:
   - continue
   - skip an optional phase
   - retry once with tighter instructions
   - stop on a real blocker
5. After implementation, run `reviewer` and `pathfinder`.
6. Run `recapper` unless skipped.
7. Return a concise summary with:
   - completed phases
   - skipped phases
   - created or updated artifacts
   - major findings, blockers, and next actions

## Retry And Failure Rules

- If a phase fails because the prompt was too broad, rerun once with tighter scope.
- If a phase fails because a required artifact is missing, inspect the workspace, recover the latest relevant artifact if possible, and continue.
- If a phase is blocked by a real ambiguity that DEM cannot responsibly infer, stop and ask the user one concise question.
- Do not silently skip `investigator`, `planner`, or implementation review.

## Guardrails

- Do not jump straight into implementation from a free-form request; `investigator` is the default first step.
- Do not force `resolver` or `specifier` when they add ceremony without improving decisions.
- Do not run multiple implementation-capable subagents against overlapping write scopes at the same time.
- Do not treat a planner-created plan as executed until the second `planner` run finishes.
- Do not end the workflow after implementation without running `reviewer`.
- Do not lose the artifact chain; always know which note, spec, and plan the current phase is based on.

## Quality Bar

- The workflow should feel like a supervised pipeline, not a loose checklist.
- Each downstream phase should consume concrete upstream artifacts whenever possible.
- Optional phases should be skipped deliberately, not forgotten.
- The final summary should let the user see what happened, what was created, and what still needs attention.
