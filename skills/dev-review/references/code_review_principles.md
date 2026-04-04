# Code Review Principles

Use this file as the judgment rubric for the strict first pass in `code-review` mode.

## What qualifies as a finding

Flag an issue only when all of these hold:

- the problem exists in the current code under review
- it has a meaningful impact on correctness, security, performance, reliability, or maintainability
- it is discrete and actionable
- the breakage path or risky behavior can be explained from the code and nearby evidence
- the original author would likely want to fix it if they knew about it

## What does not qualify

Do not flag:

- style-only or formatting-only nits
- vague future risks without a concrete failure mode
- broad architectural preferences without a specific defect or downstream cost
- cleanup ideas that are not tied to a real bug, risk, or confusion point
- speculative comments that depend on unverified external assumptions

## Comment discipline

Each finding should be:

- one issue per comment
- short and matter-of-fact
- explicit about the failure mode, invariant violation, or operational risk
- scoped to the tightest useful file and line range

Avoid praise, generic maintainability advice, and long code excerpts.

## Priority guide

- `P0`: release-blocking or universally broken
- `P1`: urgent and should be fixed in the next cycle
- `P2`: normal actionable bug or risk
- `P3`: low-priority but still worth fixing

Choose the lowest severity that honestly matches the impact.
