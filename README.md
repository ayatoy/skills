# My Skills Repository

This repository is my collection of agent skills.

## Overview

This repository contains a set of focused agent skills that can be used independently or combined into a larger workflow.

- `investigator`: repository research and technical analysis
- `resolver`: best-effort inferred answers for open questions in documents and free-form text
- `planner`: creation and management of ExecPlans
- `pathfinder`: prioritized human reading paths for code and changes
- `reviewer`: two-pass review of changes or existing code
- `specifier`: software requirements and specification drafting
- `recapper`: detailed session recap and repeated work pattern analysis
- `brainstormer`: free-form ideation backed by a living inbox note under `docs/inbox`
- `supervisor`: orchestration across the full workflow from investigation through recap, including resume and interrupt handling from existing workspace state

Each skill lives in its own directory and includes a `SKILL.md`, agent config, and supporting references. See `Skill Relationships` for how the workflow connects, and `Skills` for per-skill details.

## Skill Relationships

The repository is designed around a supervised end-to-end workflow, while still allowing each skill to be used independently. You can use `supervisor` to orchestrate the full flow, or invoke individual skills directly when you only need a specific step. The diagram below shows how skills and their main artifacts connect.

```mermaid
%%{init: {'flowchart': {'nodeSpacing': 24, 'rankSpacing': 14}}}%%
flowchart TB
    subgraph S["supervisor"]
        direction TB

        subgraph Q["current session"]
            direction TB

            A["User Request or Issue"] -. optional .-> R("brainstormer") --> T[["docs/inbox/...<br/>brainstorm brief"]]
            A["User Request or Issue"] --> B("investigator") --> C[["docs/notes/...<br/>investigation note"]]
            T -. optional input .-> B

            C -.-> D("resolver<br/>(optional)")
            D -. update .-> C

            C -.-> E("specifier<br/>(optional)")
            E --> G[["docs/specs/...<br/>specification"]] --> F("planner")

            C --> F
            F --> H[["docs/plans/...<br/>ExecPlan"]] --> I("planner execution<br/>(implementation)") --> J[["repository changes"]]

            J --> K("reviewer") --> M[["docs/notes/...<br/>review note series"]] --> X{"blocking<br/>findings?"}
            X -- no --> L("pathfinder") --> N[["docs/notes/...<br/>reading path note"]]
            X -- yes --> Y("fix implementation") --> J
        end
        Q --> O("recapper") --> P[["docs/notes/...<br/>session recap"]]
    end
```

- The usual flow is `investigator` first, optional refinement through `resolver` or `specifier`, then planning and execution through `planner`.
- `reviewer` runs first after implementation; if it finds blocking issues worth fixing immediately, the workflow loops through implementation and review again before `pathfinder` runs.
- In one completed `supervisor` cycle, `pathfinder` and `recapper` are the final two phases, in that order, and each produces exactly one main artifact for that cycle.
- `supervisor` orchestrates the end-to-end flow, while each skill remains independently callable when you only need one step.
- When a prior run stopped halfway or the repository already contains manual edits, `supervisor` should infer the furthest defensible completed phase from artifacts and current changes, then resume from there instead of restarting blindly.
- Notes are primarily emitted under `docs/notes/...`, specs under `docs/specs/...`, and ExecPlans under `docs/plans/...`.
- `recapper` closes the workflow by summarizing the session, the work performed, and the artifacts produced.

## Installation

Install all skills into `~/.agents/skills` from the repository root:

```bash
./install.sh
```

Use a custom destination if needed:

```bash
./install.sh /path/to/destination
```

The script detects each top-level directory that contains a `SKILL.md` and syncs it with `rsync`, excluding `.git/` and `.DS_Store`.

## Skills

### Investigator

`investigator` is focused on repository investigation and analysis.

- Use cases: technical research, deep dives, root-cause analysis, background study
- Role: turns findings into structured investigation reports

### Resolver

`resolver` is focused on resolving open questions with explicit, best-effort inference.

- Use cases: augmenting investigation notes, review outputs, specifications, and arbitrary text that still contains unresolved questions
- Role: preserves the original questions and appends labeled inferred answers with confidence and basis

### Planner

`planner` supports the creation and management of ExecPlans.

- Use cases: complex features, significant refactors, execution planning, plan execution from an existing ExecPlan
- Role: accepts free-form requests, upstream research/specification documents, or an existing ExecPlan, then creates, updates, or executes the target plan without jumping straight into implementation
- Execution model: `Execute the plan` is the only trigger phrase and targets the latest plan implicitly; providing a planner-generated plan file targets that specific plan explicitly
- References:
  - [OpenAI Cookbook](https://cookbook.openai.com/articles/codex_exec_plans)
  - [YouTube](https://www.youtube.com/watch?v=Gr41tYOzE20)

### Pathfinder

`pathfinder` supports efficient human review and code reading preparation.

- Use cases: staged or unstaged changes, commit review, commit range review, PR review, feature reading, subsystem reading
- Role: converts raw diffs or code areas into a short ordered reading path with focus areas and watchpoints, then saves it as a markdown note under `$PWD/docs/notes`
- Artifact links: use repo-local relative Markdown links so VSCode users can click from the note into source files and directories

### Reviewer

`reviewer` supports both change review and existing code review.

- Use cases: staged or unstaged review, commit review, branch review, PR review, feature review, file review, directory review
- Role: uses `change-review` for diffs and `code-review` for existing code areas, then applies a broader second pass for intent, security, regression, testing, operations, and AI readability, and saves the review as a markdown note under `$PWD/docs/notes`
- Review artifact naming: if the same target is reviewed again, continue the existing review note filename as a numbered series instead of inventing a new unrelated name
- Artifact links: use repo-local relative Markdown links so VSCode users can click from the note into source files and directories

### Specifier

`specifier` supports software requirements definition and specification drafting.

- Use cases: requirement definition, spec drafting, assumption and constraint management
- Role: converts requests or research into implementation-ready specifications

### Recapper

`recapper` is focused on preserving the current session as a detailed handoff note.

- Use cases: session recap, handoff note creation, full conversation summary, workflow repetition analysis, Agent Skill opportunity discovery
- Role: reconstructs the session chronologically, records concrete actions and outcomes, appends repeated work pattern analysis, and recommends recurring patterns that should become Agent Skills

### Brainstormer

`brainstormer` is focused on open-ended discussion and idea development while maintaining a canonical inbox note that can feed the next workflow step.

- Use cases: free-form brainstorming, vague request refinement, exploratory discussion, turning loose text or files into a concept-oriented brief
- Role: creates or updates a note under `$PWD/docs/inbox`, extracts topics from explicit input or the current session, and continuously distills the conversation into what the user wants to do next, why it matters, core concepts, constraints, options, tradeoffs, and open questions for `supervisor` or `investigator`; if the user explicitly names code paths to consider, those can be preserved as user-provided anchors

### Supervisor

`supervisor` is focused on orchestrating the full multi-skill workflow.

- Use cases: end-to-end work that should start with investigation, continue through planning and implementation, then end with review, reading guidance, and session recap; also recovery of interrupted runs or manual in-flight work
- Role: keeps the main thread as supervisor, delegates each phase to a subagent when available, preserves the artifact chain across notes, specs, plans, reviews, and recap, infers the current phase from artifacts and repository changes when resuming, loops through review and fix passes until blocking issues are resolved before running `pathfinder`, and guarantees exactly one `pathfinder` artifact and one `recapper` artifact at the end of each completed cycle

## License

MIT
