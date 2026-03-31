---
name: investigator
description: Investigate a given topic deeply in the current repository and produce a detailed research report saved at $PWD/docs/notes/yyyy-MM-dd_*.md. Use when the user asks for a deep dive, technical investigation, comparative analysis, root-cause research, or background study and expects a persisted markdown note.
---

# Topic Investigation Reporter

Create a detailed markdown research report for a user-provided topic and save it to `$PWD/docs/notes/`.

## Inputs

- Topic text: can be a single word, phrase, or long sentence.
- A `.md` file path or pasted markdown to use as the investigation brief.
- Optional constraints: scope, audience, deadline, required format, language.

## Markdown Brief Handling

When the user provides a `.md` file path or pasted markdown, treat that document as the primary investigation brief.

- Read the document before broad repository exploration.
- Use the document's stated goals, scope boundaries, constraints, open questions, and referenced artifacts to drive the investigation.
- Do not collapse the document into a shorter paraphrase and then investigate only the paraphrase.
- During synthesis, check findings back against the document and explicitly call out any requested area that remains unresolved or any conclusion that conflicts with the brief.

## Output Contract

- Save exactly one main report file under:
  - `$PWD/docs/notes/yyyy-MM-dd_*.md`
- Use today's local date for `yyyy-MM-dd` unless the user requests another date.
- Write the saved report in the user's language unless the user asks otherwise.
- Keep report content evidence-based and traceable.
- Write the saved report as normal Markdown content, not inside an outer fenced code block.
- When referencing source files, tests, configs, docs, or directories in the saved report, use repo-local relative Markdown links from the note file so a human can click them in VSCode.
- Prefer plain file or directory links such as `[src/api/server.ts](../../src/api/server.ts)` over environment-specific URIs or absolute paths.
- If line precision matters, keep the link target as the file and put the line number in visible text such as `[src/api/server.ts](../../src/api/server.ts) line 42`.
- Never wrap Markdown links in backticks, inline code, or fenced code blocks in the saved report; links must render in Markdown preview.
- Never emit local filesystem absolute paths such as `/Users/...` in the saved report. If a workspace-rooted path must appear in prose, rewrite it with a `$PWD/...` placeholder instead.

## Standard Workflow

1. Determine scope from the topic text.
2. Investigate local repository evidence first.
3. Add external evidence when local data is insufficient or when recency matters.
4. Use all available relevant resources as needed and investigate thoroughly instead of stopping at the first plausible explanation.
5. Synthesize findings into a structured report.
6. Save the report file to `$PWD/docs/notes/` and cite all sources.

## Guardrail

- Do not jump into implementation or edit source code after the investigation is complete.

## File Creation and Management

Create the destination path and template with: `$HOME/.agents/skills/investigator/references/TEMPLATE.md` and save the filled report to `$PWD/docs/notes/yyyy-MM-dd_*.md`. Always use the `yyyy-MM-dd_` prefix for filenames. Do not include local paths or environment-specific information in the report; use placeholders like `$PWD` instead. 
This prints the final path and creates a draft markdown file if it does not exist.
- Do not include local absolute paths, `file://` URLs, `vscode://` URIs, or other machine-specific details in the saved note.
- If a saved note needs to mention a local artifact path in prose, use a `$PWD/...` placeholder rather than a machine-specific absolute path.
- Use repo-local relative Markdown links from the saved note to any referenced source, test, doc, config, or directory.
- Prefer link labels that match the repository path the reader expects to open.
- Keep the saved note previewable as Markdown: do not surround the whole artifact or any link list with code fences.

## Local Investigation Checklist

- Search broadly with `rg` for topic terms and synonyms.
- Expand outward from the obvious entry points and inspect adjacent modules, callers, configs, tests, and historical notes when they may change the conclusion.
- Read relevant code, tests, configs, docs, issues, and notes.
- Capture concrete evidence:
  - file paths
  - key behaviors
  - assumptions and gaps

## External Investigation Checklist

- Use web research for unstable or time-sensitive facts.
- When the repository alone does not settle the question, use the web and any other available primary sources needed to close the gap responsibly.
- Prefer primary sources.
- Record source URLs in the report.
- Distinguish facts from inferences.

## Report Structure

Use this structure in the saved note:

1. Title
2. TL;DR
3. Topic and scope
4. Method (where and how you investigated)
5. Findings (with evidence)
6. Impact / implications
7. Open questions and risks
8. Recommended next actions
9. Sources

## Quality Bar

- Be specific; avoid generic summaries.
- Tie each major claim to explicit evidence.
- When evidence comes from the repository, cite the smallest useful location with a clickable Markdown link.
- Include unknowns explicitly instead of guessing.
- Keep prose concise but complete enough for decision-making.
