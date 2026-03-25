---
name: planner
description: When writing complex features or significant refactors, use an ExecPlan from design to implementation.
---

# ExecPlans

Create an execution plan following `PLANS.md` methodology.

## Instructions

1. **Read [PLANS.md](references/PLANS.md) first** - This contains all methodology, requirements, structure, and guidelines
2. Follow the process and skeleton defined in [PLANS.md](references/PLANS.md) to the letter
 
## Manage plan files

Find, read, update, or delete plan files in `$PWD/docs/plans`, always creating a plan file to facilitate collaboration with the user; when creating or updating a plan, always refer to PLANS.md; write the plan file primarily in the user’s native language, but switch to English when higher precision or technical rigor is needed, as plan files are co-edited with the user and updated interactively as needed.
When creating a plan file, prepend the filename with the `yyyy-MM-dd_` prefix.
Do not include local paths or other environment-specific information in plan files; use appropriate placeholders such as `$PWD` instead.

## Authorize plan execution

Only execute a created ExecPlan when the user explicitly instructs you to execute it. Treat execution as authorized only if the user uses an approved trigger phrase.
The only approved trigger phrase is `Execute the plan` (case-insensitive).
Do not execute the plan in response to vague approvals (e.g., “OK,” “Sounds good,” “Go ahead”) or alternative phrasings unless they include that exact trigger phrase.
