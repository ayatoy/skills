---
name: dev-planner
description: When writing complex features or significant refactors, use an ExecPlan from design to implementation.
---

# ExecPlans

Create an execution plan following `PLANS.md` methodology.

## Inputs

`dev-planner` accepts three primary input patterns. Choose the mode from the input itself instead of asking the user to restate it.

1. Free-form implementation request:
   - Examples: natural-language requests describing desired work, intended outcomes, changes to make, or problems to solve
   - Behavior: inspect the repository as needed and create or update an ExecPlan that covers the requested work
2. Upstream design or research document:
   - Examples: documents produced by `dev-investigator`, `dev-specifier`, or equivalent notes/specs provided as pasted markdown or file paths
   - Behavior: extract the goal, scope, constraints, acceptance criteria, and open questions from the document, then create or update an ExecPlan derived from that material
3. Existing dev-planner-generated plan file:
   - Examples: an ExecPlan file path under `$PWD/docs/plans`, or pasted markdown that is clearly an existing ExecPlan created with `dev-planner`
   - Behavior: treat the provided plan as the target plan and execute it, updating the living-plan sections in that same file as work progresses

When the input is ambiguous, prefer these interpretations:

- A file under `$PWD/docs/plans` that matches ExecPlan structure is an executable plan input
- A file under `$PWD/docs/specs` or `$PWD/docs/notes` is source material for plan creation, not a directly executable plan
- If a pasted document does not clearly match ExecPlan structure, treat it as source material and create or update a plan instead of executing it

## Instructions

1. **Read [PLANS.md](references/PLANS.md) first** - This contains all methodology, requirements, structure, and guidelines
2. Follow the process and skeleton defined in [PLANS.md](references/PLANS.md) to the letter
3. Do not jump straight into implementation. Unless the input is an explicitly executable dev-planner-generated ExecPlan, first produce or update the plan before making code changes.
 
## Manage plan files

Find, read, update, or delete plan files in `$PWD/docs/plans`, always creating a plan file to facilitate collaboration with the user; when creating or updating a plan, always refer to PLANS.md; write the plan file in the user's language unless the user asks otherwise, but switch to English for narrowly scoped passages when higher precision or technical rigor is clearly needed, as plan files are co-edited with the user and updated interactively as needed.
When creating a plan file, prepend the filename with the `yyyy-MM-dd'T'HH-mm-ss'Z'_` UTC prefix.
If the saved plan includes any created or updated timestamp in its content, use the same `UTC` format: `yyyy-MM-dd'T'HH-mm-ss'Z'`.
Do not include local paths or other environment-specific information in plan files; use appropriate placeholders such as `$PWD` instead.
Write the saved plan file as normal Markdown content, not inside an outer fenced code block.
When referencing repository files, tests, configs, docs, notes, specs, or directories in a saved plan, use repo-local relative Markdown links from the plan file so a human can click them in VSCode.
Prefer link labels that preserve the repository-relative path the reader expects to open, such as `[src/api/server.ts](../../src/api/server.ts)`.
If line precision matters, keep the link target as the file and put the line number in visible text such as `[src/api/server.ts](../../src/api/server.ts) line 42`.
Never wrap Markdown links in backticks, inline code, or fenced code blocks in the saved plan; links must render in Markdown preview.
Never emit local filesystem absolute paths such as `/Users/...` in saved plan files. If a workspace-rooted path must appear in prose, rewrite it with a `$PWD/...` placeholder instead.
Interpret `PLANS.md` references to "full path" for saved artifacts as repository-relative paths within the repo, not machine-specific filesystem absolute paths.
When the input is a research/specification document, create a new ExecPlan in `$PWD/docs/plans` or update the user-specified target plan file there.
When the input is an existing ExecPlan, keep working in that same plan file and update its living sections as execution proceeds.

## Authorize plan execution

Only execute an ExecPlan when execution is explicitly authorized.
Treat execution as authorized in exactly these cases:

- The user uses the approved trigger phrase `Execute the plan` (case-insensitive). In this case, interpret the target as the most recently created or updated plan file in `$PWD/docs/plans`, unless the user explicitly names a different plan file.
- The user directly provides an existing dev-planner-generated ExecPlan file, either by file path or pasted content. In this case, treat that file as the explicit execution target.

Do not execute a plan in response to vague approvals such as "OK", "Sounds good", or "Go ahead" unless they also include an approved trigger phrase or an explicit dev-planner-generated plan file.
Do not treat ordinary implementation requests or upstream design/research documents as permission to start coding immediately; they authorize planning first, not implementation.
