# Official Review Principles

Source for maintenance:

- Official Codex review prompt:
  - <https://github.com/openai/codex/blob/main/codex-rs/core/review_prompt.md>

This file is a maintained summary for this skill, not a verbatim copy.

Use this file as the judgment rubric for the strict first pass.

## What qualifies as a finding

Flag an issue only when all of these hold:

- the reviewed change introduced it
- it has a meaningful impact on correctness, performance, security, or maintainability
- it is discrete and actionable
- it does not depend on an unstated assumption about intent or architecture
- the affected path can be explained from the diff and surrounding code
- the original author would likely want to fix it if they knew about it

## What does not qualify

Do not flag:

- style-only or formatting-only nits
- vague future risks without a concrete breakage path
- pre-existing bugs unless this change clearly worsens or exposes them
- intentional product changes unless the evidence strongly contradicts that reading
- broad architecture preferences that are not tied to a concrete defect

## Comment discipline

Each finding should be:

- one issue per comment
- short and matter-of-fact
- explicit about the scenario where it breaks
- scoped to the tightest useful file and line range

Avoid praise, hedging without reason, and long code excerpts.

## Priority guide

- `P0`: release-blocking or universally broken
- `P1`: urgent and should be fixed in the next cycle
- `P2`: normal actionable bug
- `P3`: low-priority but still worth fixing

Choose the lowest severity that honestly matches the impact.
