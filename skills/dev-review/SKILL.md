---
name: dev-review
description: "Review code changes or existing code areas with two modes: `change-review` for diffs, commits, ranges, branches, and pull requests, and `code-review` for features, files, directories, modules, and entry points. Combine a strict first-pass issue review with a broader second pass for intent, security, regression risk, tests, operations, and AI readability."
---

# Review

Review a target in two passes:

1. a strict first pass for concrete, actionable issues
2. a broader second pass for intent, security, regression, testing, operations, and AI-readability checks

Keep the review findings-first, evidence-based, and easy to act on.

Reference maintenance:

- `references/official_review_principles.md` is a maintained summary of the official Codex review prompt and includes an upstream link.
- `references/code_review_principles.md` contains the strict first-pass rules for existing code review.
- `references/second_pass_checklist.md` contains the broader second-pass checks that apply after either mode.

## Modes

Choose one mode based on the request:

- `change-review`
  - for staged or unstaged changes, commits, commit ranges, branches, or pull requests
  - Pass 1 uses [official_review_principles.md](references/official_review_principles.md)
- `code-review`
  - for features, files, directories, modules, entry points, stack traces, failing tests, or bug reports
  - Pass 1 uses [code_review_principles.md](references/code_review_principles.md)

If the user does not name a mode, infer it from the target.

Use these default inference rules:

- if the user does not specify a target, inspect staged and unstaged working tree changes first and choose `change-review`
- if no meaningful diff exists, fall back to `code-review` against the most likely existing code area implied by the request or current context
- if the primary target is a diff, commit, commit range, branch comparison, or pull request, choose `change-review`
- if the primary target is an existing feature, module, directory, entry point, stack trace, failing test, or code question, choose `code-review`
- if both are present, start with `change-review` to frame what changed, then switch to `code-review` only for the core paths that require deeper understanding
- if the request is too vague to classify cleanly, choose the mode that minimizes wasted reading and state the assumption briefly

## Inputs

- Change-review targets:
  - staged changes
  - unstaged changes
  - both
  - a commit hash
  - a commit range
  - a branch diff
  - a pull request number or URL
- Code-review targets:
  - a feature name
  - a file or directory
  - a module or package
  - an entry point
  - a stack trace
  - a failing test
  - a bug report
- optional context:
  - PR title and description
  - feature purpose or expected behavior
  - issue or spec link
  - commit messages
  - focus areas
  - language

## Resolving Review Scope

Resolve the review target as narrowly as possible. Follow the same scope-selection discipline as `dev-walkthrough`.

For `change-review`:

- staged changes:
  - prefer `git diff --cached --name-status` and `git diff --cached --stat`
- unstaged changes:
  - prefer `git diff --name-status` and `git diff --stat`
- working tree as a whole:
  - inspect both staged and unstaged changes
  - label them separately when that avoids confusion
- single commit:
  - prefer `git show --stat --name-status <sha>`
- commit range or branch diff:
  - prefer `git diff --name-status <base>..<head>` and `git diff --stat <base>..<head>`
- pull request:
  - prefer the local branch diff when enough context exists
  - use PR metadata, description, or CLI only when available and useful
  - if remote context is missing, state that limitation and fall back to the local diff

For `code-review`:

- start from the most concrete anchor available:
  - named file or directory
  - feature name
  - route, handler, command, job, or UI screen
  - exported API, class, hook, or service
  - stack trace frame
  - failing test
  - configuration or feature flag
- if the request is vague, derive one anchor and say what assumption you made

State the exact mode and target clearly in the review so the reader knows what is covered.

## Prior Review Baseline

Before starting either pass, always look for prior review artifacts for the same target under `$PWD/docs/reviews`.

If no same-target artifact exists there, it is acceptable to fall back to legacy review artifacts under `$PWD/docs/notes`.

- Prefer the existing filename series when one already exists for the target.
- Otherwise match same-target review notes by the explicit mode and target statement near the top of the note, plus filename and recency cues.
- Read the newest matching review artifact first, then inspect older entries in the same series only as needed to determine whether a point is already recorded, already fixed, intentionally deferred, or still unresolved.
- Build an internal baseline of:
  - already-reported unresolved findings
  - resolved or no-longer-applicable findings
  - prior risks or questions whose status is still unclear
- Treat the latest same-target review artifact as the canonical record for already-known issues unless the current evidence shows a material status change.

## Standard Workflow

1. Resolve the mode and exact review target first and state them explicitly.
2. Locate the latest same-target review artifact, if one exists, and use it as the deduplication baseline for the current run.
3. Gather the minimum context needed to review it:
   - diff shape and touched files for `change-review`
   - relevant surrounding code and tests for either mode
   - PR title and description when available
   - feature purpose, docs, or observable contract for `code-review`
   - commit messages when helpful
4. Run Pass 1 using the rubric for the selected mode.
5. Run Pass 2 using [second_pass_checklist.md](references/second_pass_checklist.md).
6. Deduplicate results and keep only discrete, actionable points.
7. Deduplicate again against the prior review baseline and keep only net-new findings or material status changes.
8. Separate confirmed bugs from unproven risks or missing-context questions.

## Output Contract

Save exactly one main review note under:

- `$PWD/docs/reviews/yyyy-MM-dd'T'HH-mm-ss'Z'_*.md`

Use the current UTC timestamp in `yyyy-MM-dd'T'HH-mm-ss'Z'` format for the filename prefix unless the user requests another exact UTC timestamp.
If the saved review includes any created or updated timestamp in its content, use the same `UTC` format: `yyyy-MM-dd'T'HH-mm-ss'Z'`.
Write the review in the user's language unless asked otherwise.
Use a stable filename series when reviewing the same target more than once.
Write the saved review as normal Markdown content, not inside an outer fenced code block.

Prefer this structure:

1. `Findings`
2. `Open questions / assumptions`
3. `Residual risks`
4. `Change summary` only if it helps orient the reader

State the exact mode and target near the top of the saved note.
If a prior same-target review artifact was used as the baseline, link it near the top of the saved note.
When referencing source files, tests, configs, docs, or directories in the saved note, use repo-local relative Markdown links from the note file so a human can click them in VSCode.
Prefer plain file or directory links such as `[src/api/server.ts](../../src/api/server.ts)` over environment-specific URIs or absolute paths.
If line precision matters, keep the link target as the file and put the line number in visible text such as `[src/api/server.ts](../../src/api/server.ts) line 42`.
Each finding, risk, or open question that points at code should cite the smallest useful location with a clickable Markdown link.
Never wrap Markdown links in backticks, inline code, or fenced code blocks in the saved review; links must render in Markdown preview.
Never emit local filesystem absolute paths such as `/Users/...` in the saved review. If a workspace-rooted path must appear in prose, rewrite it with a `$PWD/...` placeholder instead.
If the environment or caller also requires a specific review format such as JSON or inline comments, produce that format as needed, but still persist the main markdown review note unless the user explicitly asks not to save a file.

Do not restate an older unresolved finding as a new finding.
If a previously reported issue is still present with no meaningful status change, omit it from the new note and leave the earlier artifact as the canonical record.
If a previously reported issue changed status materially, record only the delta and link the earlier artifact.
If there are no actionable findings, say so explicitly and mention any remaining testing gaps or uncertainty.
If there are no new actionable findings beyond issues already captured in the prior review series, say that explicitly instead of repeating those older findings.

## File Creation And Management

- Create the destination directory if needed.
- Save the review as a markdown artifact under `$PWD/docs/reviews/` with a `yyyy-MM-dd'T'HH-mm-ss'Z'_` UTC filename prefix.
- When no prior review artifact exists for the same target, choose a descriptive base filename such as `yyyy-MM-dd'T'HH-mm-ss'Z'_<target-slug>_review.md`.
- When a prior review artifact exists for the same target, reuse that artifact's filename stem as the series root.
- Before choosing the next filename, inspect the latest same-target review artifact and use it as both the series source and the deduplication baseline.
- Treat an unsuffixed prior review file as the first entry in the series; save the next file as `<series-root>_02.md`, then `_03.md`, and so on.
- If the latest matching review artifact already ends with `_<NN>.md`, strip that numeric suffix, keep the rest of the stem unchanged, and increment `NN`.
- Prefer the most recent same-target review artifact when deciding the next filename in the series.
- Do not rename older review artifacts just to normalize the series.
- Do not include local absolute paths, `file://` URLs, `vscode://` URIs, or other machine-specific details in the saved note.
- If a saved note needs to mention a local artifact path, use a `$PWD/...` placeholder rather than a machine-specific absolute path.
- Use repo-local relative Markdown links from the saved note to any referenced source, test, doc, config, or directory.
- Prefer link labels that match the repository path the reader expects to open.
- Keep the saved note previewable as Markdown: do not surround the whole artifact or any link list with code fences.
- When reviewing the same target again later in the session, create the next file in the existing filename series unless the user explicitly asks to overwrite a prior one.

## Pass 1 Rules For `change-review`

Treat Pass 1 as the high-confidence machine-review pass.

- Only flag issues introduced by the reviewed change.
- Require a clear causal path from the diff to the bad outcome.
- Prefer bugs that affect correctness, performance, security, or maintainability.
- Ignore nits, style, and speculative concerns.
- Keep each finding discrete, concise, and tied to the smallest useful location.
- Use the priority discipline from [official_review_principles.md](references/official_review_principles.md).

## Pass 1 Rules For `code-review`

Treat Pass 1 as a strict current-code review pass.

- Flag only concrete issues visible in the current code and its nearby evidence.
- Prefer bugs, security problems, broken invariants, dangerous edge cases, and operationally risky behavior.
- Do not require that the issue was introduced by a current diff.
- Ignore speculative cleanup, style-only comments, and architecture taste.
- Keep each finding discrete, concise, and tied to the smallest useful location.
- Use the discipline in [code_review_principles.md](references/code_review_principles.md).

## Pass 2 Rules

Treat Pass 2 as the complementary review pass.

- Read PR intent before judging behavior in `change-review` when that context exists.
- Read feature purpose, tests, docs, or observable behavior before judging intent in `code-review`.
- Look for issues the strict diff-only pass often misses:
  - mismatch between stated intent and actual behavior
  - compatibility or regression risk outside the edited lines
  - trust-boundary and authorization problems
  - missing test coverage for important branches or failure modes
  - poor observability or hard-to-debug failure handling
  - ambiguous naming or structure that invites future AI or human mistakes
- When a point is plausible but not proven from available evidence, label it as a risk or question, not as a confirmed bug.
- When context is missing, say what is missing and why it blocks certainty.

## Guardrails

- Do not stop after the first valid issue.
- Do not inflate severity.
- Do not present speculation as fact.
- Do not repeat the same finding across successive review notes for the same target unless the current review adds a material status change.
- Do not spend tokens summarizing every file.
- Do not suggest large rewrites unless the current change clearly demands them.
- Prefer a short set of high-signal comments over an exhaustive dump.
