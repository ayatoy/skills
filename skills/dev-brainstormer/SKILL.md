---
name: dev-brainstormer
description: Start a free-form brainstorming conversation, create or update a canonical inbox note under $PWD/docs/inbox/yyyy-MM-dd'T'HH-mm-ss'Z'_*.md, and continuously distill the discussion into an abstract, concept-oriented brief for what the user wants to do next. Use when the user wants to think aloud, explore ideas, refine vague requests, or turn loose inputs such as text, files, or the current session into a strong upstream note for dev-supervisor or dev-investigator without overconstraining later investigation.
---

# dev-brainstormer

Run an open-ended brainstorming conversation while maintaining a single canonical inbox note under `$PWD/docs/inbox/`.

The goal is to produce a compact, concept-oriented brief that works well as upstream input for `dev-supervisor` and `dev-investigator`.

The inbox note is not a transcript. It is the working record of what matters:

- what the user wants to do next
- why that matters
- the shape of the problem
- constraints and preferences
- candidate directions and tradeoffs
- open questions that still block clarity

## Inputs

Accept flexible input.

Possible sources include:

- plain text
- pasted notes
- file paths
- directories
- screenshots or other attached assets when available
- a prior inbox note
- the current session history

If the user provides explicit input, treat that as the primary source and extract topics from it.
If the user provides no explicit input, use the relevant session history as the input.

## Output Contract

- Create or update exactly one main inbox note under:
  - `$PWD/docs/inbox/yyyy-MM-dd'T'HH-mm-ss'Z'_*.md`
- Create the inbox note at the start of the brainstorming run, before substantive ideation continues.
- Use the current UTC timestamp in `yyyy-MM-dd'T'HH-mm-ss'Z'` format for the filename prefix unless the user asks for another exact UTC timestamp.
- If the saved note includes any created or updated timestamp in its content, use the same `UTC` format: `yyyy-MM-dd'T'HH-mm-ss'Z'`.
- Write the note in the user's language unless asked otherwise.
- Keep the inbox note as the canonical artifact for the brainstorming thread.
- Make the note useful as a handoff or starting brief for `dev-supervisor` or `dev-investigator`.
- Keep the note abstract enough that downstream investigation is not prematurely narrowed.
- Distill the conversation continuously; do not dump raw chat logs into the note.
- When the same brainstorming thread continues, prefer updating the existing inbox note instead of creating a fresh file, unless the user asks to split topics or start a new thread.
- If the user explicitly names source files, directories, or code paths they want considered, it is acceptable to record those concrete anchors in the note.
- Never emit local filesystem absolute paths such as `/Users/...` in the saved note. If a workspace-rooted path must appear in prose, rewrite it with a `$PWD/...` placeholder instead.

## Standard Workflow

1. Resolve the primary input.
2. Extract likely topics, themes, or decision areas from that input.
3. Create the inbox note immediately under `$PWD/docs/inbox/`.
4. Seed the note with the initial agenda and a first-pass conceptual brief of what the user may want next.
5. Stay in brainstorming mode and continue the conversation freely.
6. After each meaningful exchange, update the note with the distilled essence:
   - newly clarified goals
   - desired direction
   - strong preferences and constraints
   - viable directions and tradeoffs
   - unanswered questions
7. Keep the note concise, current, and decision-useful.
8. End with the latest state of understanding, without forcing a narrow downstream path.

## Brainstorming Mode

While this skill is active, prioritize the conversation and note distillation only.

Do not invoke downstream workflow skills during the brainstorming run, including:

- `dev-supervisor`
- `dev-investigator`
- `dev-resolver`
- `dev-specifier`
- `dev-planner`
- `dev-reviewer`
- `dev-pathfinder`
- `dev-recapper`

Do not start implementation, edit source files outside the inbox note, or run execution-oriented workflows just because a plausible solution appears.

Only transition out of brainstorming mode when the user explicitly asks to move on to the next step.

## Exit Boundary

Brainstorming does not end automatically.

Do not infer the end of brainstorming just because:

- the discussion feels mature
- a plausible solution appears
- the note looks sufficiently detailed
- the user asks for advice about what to do next

Exit brainstorming mode only on explicit transition intent from the user.

Document canonical transition intents in English, but interpret the user's actual language semantically.

Treat intents like these as valid transition signals:

- `stop brainstorming`
- `pass this to dev-investigator`
- `use this as input to dev-supervisor`
- `turn this into a spec`
- `turn this into a plan`
- `start implementation`

Treat vague phrases like these as insufficient on their own:

- `this is getting good`
- `this is coming together`
- `what do you think we should do next?`
- `what should we do next?`

Interpret the user's wording by intent rather than exact phrase matching.

Examples:

- Japanese, English, and mixed-language variants should all work if they clearly express the same transition intent.
- Minor wording differences, tense differences, and polite phrasing should not matter.
- Ambiguous phrasing should still be treated as ambiguous even if it contains words like `next`, `plan`, or `implement`.

When the user expresses only a vague desire to move forward, stay in brainstorming mode and ask one short clarification question about which next step they want.

When an explicit transition signal is given:

1. Update the inbox note one last time.
2. Tighten the conceptual brief so the downstream step has a strong starting point without being over-directed.
3. End brainstorming mode.
4. Only then allow the next workflow skill or implementation phase to begin.

## Topic Extraction

Derive discussion topics from the most concrete signals available.

Examples:

- nouns or concepts that appear repeatedly
- explicit asks, desired changes, or pain points
- decisions the user is struggling with
- constraints, deadlines, audiences, or quality bars
- files, modules, products, or workflows named in the input
- conflicting goals that imply a tradeoff discussion

If the input spans multiple subjects, split them into a short topic list and use that as the initial agenda.

If the input is too vague, infer 2 to 5 plausible topics and mark them as provisional.

## Conversation Style

- Prefer natural back-and-forth over rigid interviewing.
- Help the user think, compare, refine, and challenge assumptions.
- Ask focused follow-up questions only when they materially sharpen the problem.
- Offer candidate framings, options, and tradeoffs when useful.
- Avoid prematurely collapsing the conversation into a final specification.
- Keep the brainstorming wide early, then narrow once patterns become clear.
- Bias the discussion toward extracting a better problem statement and stronger conceptual brief.

## Distillation Rules

The note should capture the durable signal, not the full dialogue.

Always prefer concise synthesis over transcript-like logging.

Update these areas as the conversation evolves:

- `What we may want to do`
- `Why this matters`
- `Topics`
- `Desired direction`
- `Core concepts`
- `Constraints and preferences`
- `Ideas and options`
- `Tensions and tradeoffs`
- `Decisions and non-goals`
- `Open questions`
- `User-provided reference targets` when explicitly provided

When a point becomes clear, move it from speculation into a more concrete section.
When an idea is rejected, keep it only if that rejection prevents future backtracking.
Prefer phrasing that preserves exploration room for another agent.
Treat concrete code paths as optional anchors, not as an exhaustive or binding investigation scope, unless the user explicitly says to constrain scope to them.

## File Creation And Management

- Create `$PWD/docs/inbox/` if it does not exist.
- Prefer filenames like:
  - `$PWD/docs/inbox/yyyy-MM-dd'T'HH-mm-ss'Z'_topic-slug.md`
- If no clear topic slug exists yet, use:
  - `$PWD/docs/inbox/yyyy-MM-dd'T'HH-mm-ss'Z'_brainstorm.md`
- When continuing an existing thread, reuse the most relevant current inbox note when defensible.
- Do not create multiple competing inbox notes for the same active thread unless the user asks for separation.
- Do not include local absolute paths, `file://` URLs, or editor-specific URIs in the saved note.
- If a saved note needs to mention a local artifact path, use a `$PWD/...` placeholder rather than a machine-specific absolute path.

Create new notes from:

- `skills/dev-brainstormer/references/TEMPLATE.md`

## Suggested Note Structure

Use this structure in the inbox note:

1. Title
2. Status
3. Seed input
4. What we may want to do
5. Why this matters
6. Topics
7. Desired direction
8. Core concepts
9. Constraints and preferences
10. Ideas and options
11. Tensions and tradeoffs
12. Decisions and non-goals
13. Open questions
14. User-provided reference targets (optional)

## Guardrails

- Do not treat the note as a verbatim transcript.
- Do not over-normalize early ambiguity; preserve uncertainty when it is still useful.
- Do not invent requirements that were not stated or strongly implied.
- Distinguish confirmed asks from your own inferred framing.
- Prefer a strong problem brief over a comprehensive discussion log.
- Prefer abstract problem framing over concrete task decomposition.
- Do not include specific references, file lists, or procedural next steps unless the user explicitly wants them in the note.
- When the user explicitly provides source code paths or concrete reference targets, you may include them, but keep them clearly labeled as user-provided anchors rather than inferred scope.
- Do not invoke `dev-supervisor` or any downstream subskill while brainstorming is still in progress.
- Do not auto-exit brainstorming mode based on confidence, momentum, or note completeness.
- Do not jump into implementation, planning, specification, or investigation unless the user explicitly ends the brainstorming phase and asks for that transition.
- Prefer updating the existing inbox note over scattering partial notes across `docs/notes/`.

## Quality Bar

- Another engineer should be able to read the inbox note and understand:
  - what the user seems to want to do next
  - why it matters
  - how the problem is currently framed
  - what is still uncertain
  - which options are currently alive
- The note should get sharper as the conversation progresses.
- The final state should be a strong enough brief that `dev-supervisor` or `dev-investigator` can start from it without being over-directed.
