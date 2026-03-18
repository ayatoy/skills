---
name: resolver
description: Add best-effort inferred answers to open questions found in investigation notes, reviews, specifications, and other free-form text. Use when a document or request contains unresolved questions and the goal is to append the strongest defensible answer, clearly labeled as an inference with confidence and basis.
---

# Open Question Resolver

Take a document, note, review, spec, or free-form text that contains open questions and append the strongest defensible answers you can infer.

## Inputs

- A local file path, pasted text, or a mixed request that includes question-like statements
- Optional constraints:
  - preserve exact structure
  - edit in place or create a copy
  - answer only some questions
  - language or tone

## What Counts As A Target

Use this skill when the input contains any of these:

- a section such as `Open questions`, `Questions`, `Unknowns`, `Assumptions`, or `Risks`
- bullets or sentences that ask what, why, how, whether, which, when, or who
- review comments or reports that end in unresolved questions
- a document that implies pending decisions even if it is not formally labeled

This skill works especially well after `investigator`, `reviewer`, or `specifier`, but it also applies to arbitrary prose with embedded questions.

## Output Contract

- Keep the original question text intact.
- Append an answer directly below or immediately after each target question when possible.
- Label each appended answer clearly as an inference, not a confirmed fact.
- Include a confidence level: `high`, `medium`, or `low`.
- Include the short basis for the inference when it is not obvious from nearby context.
- If a question cannot be answered responsibly, leave it open and state why it remains unresolved.

## Default Edit Rules

- If the user gives a writable local file, edit it in place unless they ask for a separate file.
- If editing in place would be risky or ambiguous, create a sibling file with `-inferred` before the extension.
- If the input is pasted text, return the revised text in the response unless the user asks to save it somewhere.
- Preserve formatting and section order with the smallest reasonable diff.

## Standard Workflow

1. Identify the exact question targets.
2. Group duplicates or near-duplicates so the same issue is answered once.
3. Gather evidence in this order:
   - the surrounding text
   - related local repository context
   - external sources only when the question depends on unstable or missing local facts
4. Infer the single best answer that is still defensible from the evidence.
5. Append the answer next to the question with confidence and basis.
6. Leave a question unanswered only when the evidence is too weak to support a responsible inference.

## Inference Rules

- Prefer the most likely answer, not a menu of possibilities, unless the evidence is genuinely split.
- Distinguish facts from inference explicitly.
- Use concrete assumptions instead of vague hedging.
- When multiple answers are plausible, choose one and mention the key assumption that makes it the best default.
- Keep the answer short and decision-useful.
- Match the language of the source document unless the user asks otherwise.

## Annotation Style

Use the lightest format that fits the source material. Prefer patterns like these:

- Under a bullet question:
  - `Inferred answer: ...`
  - `Confidence: medium`
  - `Basis: ...`
- Inline after a prose question:
  - `Proposed answer: ... (inference, confidence: low)`

Keep labels consistent within one document.

## Guardrails

- Do not rewrite history by replacing the original question with an answer.
- Do not present guessed answers as verified facts.
- Do not invent evidence, requirements, or stakeholder intent without labeling them as assumptions.
- Do not broaden the document into a full redesign or implementation plan unless the user asks for that.
- Do not leave vague placeholders like `TBD` when a reasonable inference is possible.
- Do not force an answer when the honest result is `still unresolved because ...`.

## Quality Bar

- Each appended answer should help the reader move forward.
- The confidence level should match the actual evidence strength.
- The basis should be short but specific enough that another engineer can challenge it.
- The final document should read as a careful augmentation, not a rewrite.
