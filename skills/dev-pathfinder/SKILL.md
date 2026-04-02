---
name: dev-pathfinder
description: Turn code changes or existing code areas into a prioritized human reading path. Use when the user wants an efficient route through staged or unstaged changes, commits, commit ranges, pull requests, features, modules, directories, entry points, or code questions.
---

# dev-pathfinder

Turn a codebase target into a short, high-signal path for a human reader.

Optimize for "what should I read first to understand this fastest", not for exhaustive explanation.

## Modes

Choose one mode based on the request:

- `review`
  - for staged or unstaged changes, commits, commit ranges, branches, or pull requests
  - optimize for risk, leverage, and reviewer efficiency
- `reading`
  - for features, directories, modules, entry points, stack traces, or code questions
  - optimize for comprehension, architecture, and shortest learning path

If the user does not name a mode, infer it from the target.

Use these default inference rules:

- if the user does not specify a target, inspect staged and unstaged working tree changes first and choose `review`
- if no meaningful diff exists, fall back to `reading` mode against the most likely existing code area implied by the request or current context
- if the primary target is a diff, commit, commit range, branch comparison, or pull request, choose `review`
- if the primary target is an existing feature, module, directory, entry point, stack trace, or code question, choose `reading`
- if both are present, start with `review` to frame what changed, then switch to `reading` only for the core paths that require deeper understanding
- if the request is too vague to classify cleanly, choose the mode that minimizes wasted reading and state the assumption briefly

## Inputs

- Review targets:
  - staged changes
  - unstaged changes
  - both
  - single commit hash
  - commit range
  - branch diff
  - pull request number or URL
- Reading targets:
  - feature name
  - file or directory
  - module or package
  - entry point
  - stack trace
  - bug report
  - architecture or behavior question
- Optional constraints:
  - reviewer or reader role
  - time budget
  - risk tolerance
  - areas to focus on or ignore

## Output Contract

Save exactly one main reading-path note under:

- `$PWD/docs/notes/yyyy-MM-dd'T'HH-mm-ss'Z'_*.md`

Use the current UTC timestamp in `yyyy-MM-dd'T'HH-mm-ss'Z'` format for the filename prefix unless the user requests another exact UTC timestamp.
If the saved note includes any created or updated timestamp in its content, use the same `UTC` format: `yyyy-MM-dd'T'HH-mm-ss'Z'`.
Write the output in the user's language unless asked otherwise.
Write the saved note as normal Markdown content, not inside an outer fenced code block.

Always produce a concise guide with these sections:

1. `Target`
2. `Mode`
3. `Shape`
4. `Start here`
5. `Path`
6. `Watchpoints`
7. `Light scan`

Add `Key concepts` when the task is primarily code reading.
Add `Optional diagram` only when a small Mermaid diagram will reduce cognitive load.
When referencing source files, tests, configs, docs, or directories in the saved note, use repo-local relative Markdown links from the note file so a human can click them in VSCode.
Prefer plain file or directory links such as `[src/app/router.ts](../../src/app/router.ts)` over environment-specific URIs or absolute paths.
If line precision matters, keep the link target as the file and put the line number in visible text such as `[src/app/router.ts](../../src/app/router.ts) line 42`.
Never wrap Markdown links in backticks, inline code, or fenced code blocks in the saved note; links must render in Markdown preview.
Never emit local filesystem absolute paths such as `/Users/...` in the saved note. If a workspace-rooted path must appear in prose, rewrite it with a `$PWD/...` placeholder instead.

Save the guide as markdown and keep the saved note as the canonical artifact for this run.

## File Creation And Management

- Create the destination directory if needed.
- Save the reading path under `$PWD/docs/notes/` with a `yyyy-MM-dd'T'HH-mm-ss'Z'_` UTC filename prefix.
- Do not include local absolute paths, `file://` URLs, `vscode://` URIs, or other machine-specific details in the saved note.
- If a saved note needs to mention a local artifact path, use a `$PWD/...` placeholder rather than a machine-specific absolute path.
- Use repo-local relative Markdown links from the saved note to any referenced source, test, doc, config, or directory.
- Prefer link labels that match the repository path the reader expects to open.
- Keep the saved note previewable as Markdown: do not surround the whole artifact or any link list with code fences.
- When generating a second path for the same target, prefer a new note unless the user explicitly asks to update an existing one.

## Standard Workflow

1. Resolve the target as narrowly as possible.
2. Inspect structure before reading details.
3. Group files into a few meaningful reading units.
4. Rank those units by leverage for the selected mode.
5. Turn them into a serial path that minimizes context switching.
6. Read only enough code to justify the path and its watchpoints.

Do not mirror commit order or directory order blindly.
Flatten the target into a human-friendly learning path that exposes intent, core behavior, and consequences in the easiest order to validate or understand.

## Resolving Targets

Use the narrowest source that matches the request.

For `review` mode:

- staged changes:
  - prefer `git diff --cached --name-status` and `git diff --cached --stat`
- unstaged changes:
  - prefer `git diff --name-status` and `git diff --stat`
- working tree as a whole:
  - inspect both staged and unstaged changes and label them separately if useful
- single commit:
  - prefer `git show --stat --name-status <sha>`
- commit range or branch diff:
  - prefer `git diff --name-status <base>..<head>` and `git diff --stat <base>..<head>`
- pull request:
  - prefer local branch diff if enough context exists
  - use PR metadata or CLI only when available and useful
  - if remote context is missing, state that limitation and fall back to the local diff

For `reading` mode:

- start from the most concrete anchor available:
  - named file or directory
  - route, handler, command, job, or UI screen
  - exported API, class, hook, or service
  - stack trace frame
  - failing test
  - configuration or feature flag
- if the request is vague, derive one anchor and say what assumption you made

State the exact target clearly so the reader knows what is covered.

## Prioritization Heuristics

Start from areas that explain system behavior with the fewest file reads.

Raise priority when the target touches:

- entry points such as routes, handlers, commands, jobs, or UI screens
- shared domain logic or common libraries
- data shape, persistence, migrations, caching, or serialization
- permissions, authentication, billing, security, or deletion paths
- external side effects such as APIs, queues, emails, or background work
- feature flags, configuration, fallback paths, or error handling
- tests that reveal intent, invariants, or missing coverage
- code removal, broad renames, or cross-cutting edits that can hide semantics

In `reading` mode, also raise priority for:

- files that define core concepts or terminology
- orchestration layers that show the end-to-end flow
- stable interfaces that many callers depend on
- canonical tests or examples that demonstrate expected behavior

Lower priority when files look like:

- formatting-only changes
- generated outputs
- lockfiles
- snapshots or fixture churn
- docs-only edits that follow already-understood code

Do not fully ignore low-priority files if they are the only evidence for intent.

## Building The Path

Keep the path short. Usually 3 to 7 steps is enough.

Each step should include:

- `Scope`: the file group, component, or flow to inspect
- `Behavior`: a compact explanation of what that code or logic does at runtime or in the overall flow
- `Links`: one or more repo-local relative Markdown links for the concrete files or directories to open
- `Check`: what the reader should verify or learn
- `Why now`: why this step unlocks the rest
- `Exit signal`: what gives enough confidence to move on

Format the `Path` section as a nested bullet list for readability:

- use one top-level bullet per step
- under each step, add nested bullets for `Scope`, `Behavior`, `Links`, `Check`, `Why now`, and `Exit signal`
- keep labels explicit instead of collapsing them into prose paragraphs
- keep `Behavior` concise, usually one sentence, and make it specific to the actual control flow or responsibility

Example shape:

- Step 1: Open the request entry point
  - `Scope`: HTTP handler and route wiring
  - `Behavior`: accepts the incoming request, normalizes inputs, and decides which service path handles the call
  - `Links`: `[src/http/routes.ts](../../src/http/routes.ts)`, `[src/http/handler.ts](../../src/http/handler.ts)`
  - `Check`: where the request first branches and what inputs are normalized
  - `Why now`: this frames the rest of the flow before diving into internal services
  - `Exit signal`: you can state which downstream service owns the next transition
- Step 2: Follow the core state change
  - `Scope`: domain service and persistence boundary
  - `Behavior`: validates business rules, computes the authoritative state transition, and persists the result
  - `Links`: `[src/domain/service.ts](../../src/domain/service.ts)`, `[src/db/repository.ts](../../src/db/repository.ts)`
  - `Check`: which state mutation is authoritative and where failures surface
  - `Why now`: this is the semantic center of the change
  - `Exit signal`: you can explain the write path and its main invariants

Prefer an order like:

1. entry point or user-visible surface
2. core logic or state transition
3. persistence or side effects
4. tests or examples that confirm intent
5. low-risk supporting files

If commit boundaries are informative, mention them briefly inside a step.
If commit boundaries are noisy, ignore them and organize by behavior instead.

## Shape

Do not summarize every file.

Compress the target into 3 to 7 bullets that help the reader build a mental model before opening files.

Examples:

- new request flow plus one storage change
- refactor isolated behind a stable API
- background job pipeline with retry handling
- feature flag wired from config to handler to UI
- parser core with tests that define edge cases

## Key Concepts

Use this section in `reading` mode when it will reduce confusion.

List only the concepts, layers, or abstractions the reader must understand first.

Examples:

- request lifecycle
- domain entity boundaries
- cache ownership
- adapter versus core service
- test fixture conventions

## Watchpoints

Only list the highest-value concerns. Usually 3 to 6 bullets.

In `review` mode, focus on risk and behavioral blind spots.

Examples:

- old callers may still rely on removed behavior
- migration order may not match read and write paths
- error handling changed only on one branch
- tests cover happy path but not rollback or retry behavior
- a mostly mechanical diff contains one semantic change

In `reading` mode, focus on misunderstandings that waste time.

Examples:

- the public entry point delegates immediately and does not contain real logic
- naming suggests ownership that actually lives in another module
- tests encode the contract more clearly than the implementation
- one config flag changes the path completely

Avoid generic advice that would apply to any target.

## Light Scan

Explicitly identify files or groups that likely need only a quick pass.

Examples:

- snapshots that mirror already-understood logic
- docs following code changes
- generated clients after schema review
- broad rename fallout after the canonical implementation is checked
- wrappers that just forward to the real module

## Optional Diagram

Use Mermaid only when it reduces cognitive load.

Good fits:

- flow from entry point to service to storage
- dependency chain across changed modules
- ordered reading map for a multi-layer subsystem

Keep diagrams small:

- at most 8 nodes
- simple `flowchart LR` or `flowchart TD`
- label inferred structure as inference when it is not explicit in code

## Guardrails

- Do not claim to have completed the review when you are only structuring it.
- Do not produce an exhaustive file-by-file changelog unless the user asks for it.
- Prefer the 20 percent of files that explain 80 percent of understanding or review risk.
- Call out unknowns and missing context instead of guessing.
- If the target is too large, split the path into phases rather than dumping more detail.
