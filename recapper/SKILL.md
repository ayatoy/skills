---
name: recapper
description: Summarize the complete conversation so far in the current session and save a detailed markdown note under $PWD/docs/notes/yyyy-MM-dd_*.md. Also investigate repeated work patterns that appeared during the session and append that analysis. Use when the user asks for a session recap, handoff note, full conversation summary, or workflow repetition analysis.
---

# Recapper

Create a detailed markdown note that captures the current session so far and save it to `$PWD/docs/notes/`.

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

- Save exactly one main note under:
  - `$PWD/docs/notes/yyyy-MM-dd_*.md`
- Use today's local date for `yyyy-MM-dd` unless the user requests another date.
- Capture the session in enough detail that another strong engineer can continue the work without reopening the full transcript.
- Append a dedicated analysis section for repeated work patterns observed during the session.

## Standard Workflow

1. Identify the session scope:
   - when the relevant work started
   - what the user asked for
   - whether the note should cover the whole session or only a named portion
2. Reconstruct the session chronologically from the conversation history.
3. Confirm concrete repository details only where needed:
   - files read or changed
   - commands run
   - validations performed
   - artifacts created
4. Write a comprehensive note that includes requests, decisions, actions, results, blockers, and current status.
5. Analyze repeated work patterns:
   - loops in investigation or implementation
   - repeated retries
   - repeated clarification cycles
   - repeated validation or repair passes
6. Save the note under `$PWD/docs/notes/`.

## What To Capture

- User goals, constraints, and changes in direction
- DEM's key decisions and why they were made
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

## Guardrails

- Do not omit major decisions, reversals, failures, or unresolved issues.
- Do not invent transcript details that are not present in the session or confirmed locally.
- Distinguish confirmed facts from inference when reconstructing intent.
- Do not implement code changes unless the user separately asks for them.
- Keep the note detailed, but remove filler phrasing and low-signal chat.

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
10. Open questions or next handoff notes

## Quality Bar

- Another engineer should be able to resume work from the saved note alone.
- Chronology should be specific enough to explain why the session ended up in its current state.
- Repetition analysis should be evidence-based, not generic process advice.
- If the available session context is incomplete, say exactly what appears to be missing.
