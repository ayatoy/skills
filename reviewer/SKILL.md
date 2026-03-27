---
name: reviewer
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

Resolve the review target as narrowly as possible. Follow the same scope-selection discipline as `pathfinder`.

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

## Standard Workflow

1. Resolve the mode and exact review target first and state them explicitly.
2. Gather the minimum context needed to review it:
   - diff shape and touched files for `change-review`
   - relevant surrounding code and tests for either mode
   - PR title and description when available
   - feature purpose, docs, or observable contract for `code-review`
   - commit messages when helpful
3. Run Pass 1 using the rubric for the selected mode.
4. Run Pass 2 using [second_pass_checklist.md](references/second_pass_checklist.md).
5. Deduplicate results and keep only discrete, actionable points.
6. Separate confirmed bugs from unproven risks or missing-context questions.

## Output Contract

Save exactly one main review note under:

- `$PWD/docs/notes/yyyy-MM-dd_*.md`

Use today's local date for `yyyy-MM-dd` unless the user requests another date.
Write the review in the user's language unless asked otherwise.

Prefer this structure:

1. `Findings`
2. `Open questions / assumptions`
3. `Residual risks`
4. `Change summary` only if it helps orient the reader

State the exact mode and target near the top of the saved note.
When referencing source files, tests, configs, docs, or directories in the saved note, use repo-local relative Markdown links from the note file so a human can click them in VSCode.
Prefer plain file or directory links such as `[src/api/server.ts](../../src/api/server.ts)` over environment-specific URIs or absolute paths.
If line precision matters, keep the link target as the file and put the line number in visible text such as `[src/api/server.ts](../../src/api/server.ts) line 42`.
Each finding, risk, or open question that points at code should cite the smallest useful location with a clickable Markdown link.
If the environment or caller also requires a specific review format such as JSON or inline comments, produce that format as needed, but still persist the main markdown review note unless the user explicitly asks not to save a file.

If there are no actionable findings, say so explicitly and mention any remaining testing gaps or uncertainty.

## File Creation And Management

- Create the destination directory if needed.
- Save the review as a markdown artifact under `$PWD/docs/notes/` with a `yyyy-MM-dd_` filename prefix.
- Do not include local absolute paths, `file://` URLs, `vscode://` URIs, or other machine-specific details in the saved note.
- Use repo-local relative Markdown links from the saved note to any referenced source, test, doc, config, or directory.
- Prefer link labels that match the repository path the reader expects to open.
- When reviewing the same target again later in the session, prefer creating a new note unless the user explicitly asks to overwrite a prior one.

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

Treat Pass 2 as the complementary reviewer pass.

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
- Do not spend tokens summarizing every file.
- Do not suggest large rewrites unless the current change clearly demands them.
- Prefer a short set of high-signal comments over an exhaustive dump.
