# Second-Pass Checklist

Use this file after the strict bug-finding pass.

This pass complements the strict first pass with broader engineering checks. It is allowed to surface concerns that are not fully proven, but those must be labeled clearly as `Risk`, `Question`, or `Needs confirmation`.

## Why a second pass exists

The first pass is intentionally strict. That keeps findings high-confidence, but it also creates blind spots.

Use a second pass because a strict first pass can miss issues such as:

- the implementation drifting from the stated PR intent
- the implementation drifting from the stated feature purpose or observable contract
- regressions that emerge outside the edited lines through shared code, defaults, or integration behavior
- security or permission problems that require understanding data flow or trust boundaries, not just the local diff
- operational weaknesses such as poor logging, missing failure-path handling, or changes that will be hard to debug after deploy
- code that technically works now but is easy for future humans or AI agents to misread and break

The second pass exists to catch those higher-context problems without lowering the quality bar of the first pass.

## 1. Intent and spec alignment

Check whether:

- the code matches the PR title and description in `change-review`
- the code matches the stated feature purpose, docs, tests, or observable contract in `code-review`
- behavior changes exist that are not mentioned in the PR in `change-review`
- product or business intent appears inconsistent with the implementation

If the relevant intent source is missing or too thin, say that explicitly.

## 2. Security and trust boundaries

Check whether:

- untrusted input is validated or constrained
- authorization and permission checks are preserved
- secrets, personal data, or sensitive internals can leak through logs or errors
- boundary conditions such as empty, oversized, malformed, or reordered input were considered

If you cannot prove a vulnerability but the change increases risk, call it out as a confirmation item instead of a confirmed bug.

## 3. Design and maintainability

Check whether:

- responsibilities stay clear
- coupling or hidden side effects increased
- the change fits nearby design patterns
- future edits are likely to become harder or more fragile

Focus on maintainability problems that have a plausible downstream cost, not taste.

## 4. AI readability

Check whether:

- names make intent obvious without extra context
- booleans and mode flags can be interpreted unambiguously
- state transitions and branching are easy to explain in plain language
- important ordering constraints or side effects are explicit
- the structure is likely to mislead future AI-assisted edits or reviews

Call out ambiguity that is likely to cause incorrect future changes.

## 5. Compatibility and regression risk

Check whether:

- callers or consumers may rely on previous defaults or error behavior
- untouched flows can change because of initialization order, defaults, or shared helpers
- API contracts, schemas, persistence behavior, or side effects changed silently
- existing integrations could fail without obvious test coverage

State the affected workflow or consumer whenever possible.

## 6. Tests and operations

Check whether:

- important happy paths and failure paths are covered
- rollback, retry, timeout, or partial-failure behavior is exercised when relevant
- logs, metrics, or errors are sufficient to debug production failures
- the change would be diagnosable if it misbehaves after deploy

When asking for tests, say what scenario is missing and what risk that leaves.

## Result labeling

Use these labels mentally when deciding how to report the point:

- `Finding`: high-confidence, actionable issue with clear evidence
- `Risk`: plausible issue with partial evidence
- `Question`: information is missing and should be confirmed before merge

Do not collapse all three into the same tone. Preserve the confidence difference.
