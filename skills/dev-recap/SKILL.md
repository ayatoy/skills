---
name: dev-recap
description: Summarize the complete conversation so far in the current session and save or update a detailed markdown note under $PWD/docs/recaps/yyyy-MM-dd'T'HH-mm-ss'Z'_*.md. Also investigate repeated work patterns that appeared during the session, identify recurring patterns that should become Agent Skills, and append both analyses. Use when the user asks for a session recap, handoff note, full conversation summary, or workflow repetition analysis.
---

# dev-recap

Create or update a detailed markdown note that captures the current session so far and save it to `$PWD/docs/recaps/`.

## Primary Source

- Use the current session history as the main source of truth.
- Do not ask the user to paste the conversation again unless the relevant history is unavailable in context.
- Use local repository evidence only to confirm concrete details such as file paths, diffs, commands, or artifacts mentioned during the session.

## Inputs

- Implicit primary input:
  - the full conversation so far in the current session
- Optional user constraints:
  - audience
  - desired filename hint
  - language
  - whether to include recommendations or keep the note strictly factual

## Output Contract

- Create or update exactly one main note under:
  - `$PWD/docs/recaps/yyyy-MM-dd'T'HH-mm-ss'Z'_*.md`
- Use the current UTC timestamp in `yyyy-MM-dd'T'HH-mm-ss'Z'` format for the filename prefix unless the user requests another exact UTC timestamp.
- If the saved note includes any created or updated timestamp in its content, use the same `UTC` format: `yyyy-MM-dd'T'HH-mm-ss'Z'`.
- If `dev-recap` is run again for the same active session or workstream, prefer updating the existing recap note instead of creating a second recap note.
- Write the saved note in the user's language unless the user asks otherwise.
- Capture the session in enough detail that another strong engineer can continue the work without reopening the full transcript.
- Append a dedicated analysis section for repeated work patterns observed during the session.
- Append a dedicated recommendation section for recurring patterns that are strong candidates for Agent Skill creation.
- Write the saved note as normal Markdown content, not inside an outer fenced code block.
- When referencing source files, tests, configs, docs, plans, specs, notes, or directories in the saved note, use repo-local relative Markdown links from the note file so a human can click them in VSCode.
- Prefer plain file or directory links such as `[docs/specs/2026-03-28T14-22-05Z_example.md](../../docs/specs/2026-03-28T14-22-05Z_example.md)` over environment-specific URIs or absolute paths.
- If line precision matters, keep the link target as the file and put the line number in visible text such as `[src/app/main.ts](../../src/app/main.ts) line 42`.
- Never wrap Markdown links in backticks, inline code, or fenced code blocks in the saved note; links must render in Markdown preview.
- Never emit local filesystem absolute paths such as `/Users/...` in the saved note. If a workspace-rooted path must appear in prose, rewrite it with a `$PWD/...` placeholder instead.

## Existing Recap Reuse

When `dev-recap` is invoked again after more user interaction, treat the existing recap note as the baseline when it appears to describe the same session or workstream.

Prefer reusing an existing recap note when most of these are true:

- it is the newest recap-like note under `$PWD/docs/recaps/`
- if no recap exists there yet, optionally fall back to legacy recap-like notes under `$PWD/docs/notes/`
- it already uses recap sections such as `Session chronology`, `Current status`, or `Repeated work patterns`
- its scope, filename hint, or linked artifacts match the current conversation
- no stronger evidence suggests the user wants a separate independent recap

When reusing an existing recap note:

- update the note in place instead of creating a duplicate recap artifact
- preserve still-correct context from the earlier version
- extend `Session chronology` with the new interaction delta instead of rewriting history from scratch without reason
- refresh `Decisions and reasoning`, `Files, commands, and artifacts`, `Problems, blockers, and resolutions`, and `Current status` so they reflect the latest state
- reorganize sections when needed so the note stays readable; do not only append a raw log dump
- remove or rewrite stale statements that the newer session state has superseded
- keep the result as one coherent handoff note, not a chain of loosely appended mini-recaps

Create a new recap note only when the evidence indicates a genuinely separate session, a different requested scope, or an explicit user request for a separate artifact.

## Standard Workflow

1. Identify the session scope:
   - when the relevant work started
   - what the user asked for
   - whether the note should cover the whole session or only a named portion
2. Determine whether an existing recap note should be reused:
   - inspect the newest recap-like notes under `$PWD/docs/recaps/` when needed
   - choose one existing note as the update target when the current run is a continuation
   - otherwise prepare a new note path
3. Reconstruct the session chronologically from the conversation history.
4. Confirm concrete repository details only where needed:
   - files read or changed
   - commands run
   - validations performed
   - artifacts created
5. Write or update a comprehensive note that includes requests, decisions, actions, results, blockers, and current status.
6. Analyze repeated work patterns:
   - loops in investigation or implementation
   - repeated retries
   - repeated clarification cycles
   - repeated validation or repair passes
7. Analyze Agent Skill opportunities:
   - repeated workflows that would benefit from reusable procedural guidance
   - repeated transformations that likely want a stable checklist, template, script, or reference bundle
   - repeated tool choreography that is easy to forget or expensive to rediscover
   - repeated workarounds or repair loops that could be prevented by a focused skill
8. Save the single resulting note under `$PWD/docs/recaps/`.

## What To Capture

- User goals, constraints, and changes in direction
- The AI assistant's key decisions and why they were made
- Investigations performed and what they established
- Commands, edits, and validations that materially changed the work
- Errors, blockers, dead ends, and how they were resolved
- Pending questions, risks, and unfinished work
- Final state of the session at the time the note is written

## Repeated Work Pattern Analysis

Add a section named `Repeated work patterns`.

For each pattern:

- name the pattern clearly
- describe the concrete loop or recurrence
- cite the relevant moments in the session
- explain the likely cause
- state the effect on speed, risk, or quality
- suggest a practical adjustment only if the user asked for recommendations

If no meaningful repetition is present, state that explicitly and say what was checked.

## Agent Skill Opportunity Analysis

Add a section named `Agent skill opportunities`.

This section is narrower than `Repeated work patterns`. Include only patterns that are good candidates for becoming a reusable Agent Skill.

Treat a pattern as a skill candidate only when most of these are true:

- it recurred enough in the session to be more than a one-off
- the workflow has a recognizable trigger
- the work benefits from stable steps, reusable references, or deterministic scripts
- packaging the know-how would likely reduce future ambiguity, retries, or token-heavy re-explanation
- the pattern is specific enough that another engineer could imagine a focused skill boundary

Do not recommend a skill for:

- generic engineering behavior such as "read the code carefully"
- one-off debugging threads with no reusable workflow
- tasks that are already well covered by an existing skill unless the gap is concrete
- patterns so broad that they should remain general reasoning rather than a skill

For each recommended skill candidate:

- give the proposed skill a concise name
- describe the repeated session pattern that motivates it
- cite the concrete evidence from the session
- explain why a skill is a better fit than ad hoc repetition
- define the likely trigger conditions for invoking the skill
- outline the minimum useful contents:
  - workflow instructions
  - scripts, references, templates, or assets if clearly justified
- note whether an existing skill appears adjacent and what gap remains
- state the expected benefit
- give a confidence level such as `high`, `medium`, or `low`

If there are no credible skill candidates, state that explicitly and explain why the observed repetition does not clear the bar.

## Guardrails

- Do not omit major decisions, reversals, failures, or unresolved issues.
- Do not invent transcript details that are not present in the session or confirmed locally.
- Distinguish confirmed facts from inference when reconstructing intent.
- Do not implement code changes unless the user separately asks for them.
- Do not create duplicate recap notes for the same ongoing session unless the user explicitly asks for a separate note.
- Keep the note detailed, but remove filler phrasing and low-signal chat.
- Do not include local absolute paths, `file://` URLs, `vscode://` URIs, or other machine-specific details in the saved note.
- If a saved note needs to mention a local artifact path, use a `$PWD/...` placeholder rather than a machine-specific absolute path.
- Use repo-local relative Markdown links from the saved note to any referenced source, test, doc, config, plan, spec, note, or directory.
- Keep the saved note previewable as Markdown: do not surround the whole artifact or any link list with code fences.
- Keep skill recommendations evidence-based and conservative; recommend fewer, stronger candidates rather than a long speculative list.

## Suggested Note Structure

Use this structure in the saved note:

1. Title
2. TL;DR
3. Scope of this note
4. Session chronology
5. Decisions and reasoning
6. Files, commands, and artifacts
7. Problems, blockers, and resolutions
8. Current status
9. Repeated work patterns
10. Agent skill opportunities
11. Open questions or next handoff notes

## Quality Bar

- Another engineer should be able to resume work from the saved note alone.
- Chronology should be specific enough to explain why the session ended up in its current state.
- Repetition analysis should be evidence-based, not generic process advice.
- Skill opportunity analysis should identify only concrete, reusable opportunities with clear triggers and likely payoff.
- File, spec, plan, and note references should be clickable from the saved note with repo-local relative Markdown links.
- If the available session context is incomplete, say exactly what appears to be missing.
