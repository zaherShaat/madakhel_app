# Repo AI Instructions

This repository uses a conservative, minimal-change approach for AI-assisted edits.

## Core guidance

- Think before coding. Surface assumptions clearly and ask clarifying questions when requirements are ambiguous.
- Keep changes surgical. Edit only what is necessary to satisfy the request.
- Avoid speculative or unnecessary features. Do not introduce abstractions or extra behavior unless explicitly asked.
- Match existing style and patterns. For Flutter/Dart code, follow the current project organization and idioms.
- Do not clean up unrelated code. Only remove imports or declarations when they become unused because of your own changes.

## When modifying code

- Define success criteria before implementing: what behavior should change, what file(s) should be affected, and how will correctness be verified.
- Preserve adjacent code structure and formatting. Do not refactor unrelated sections.
- If a request refers to a file or behavior that is not present, ask for the exact target rather than guessing.
- Use concise, direct edits. Prefer simple fixes over complex rewrites.

## When uncertain

- Ask the user whether the rule should apply globally or only to specific files.
- Clarify whether the requested changes should target Flutter/Dart UI code, state management, data models, or build configuration.
- If there is no clear project-specific style, default to minimal, idiomatic Dart and existing repository conventions.

## Example prompts to test this instruction

- "Update `lib/view/income_source/components/add_transaction_sheet.dart` so the form validates empty input."
- "Add a new widget under `lib/view` that shows a list of income sources."
- "Fix the button action in `lib/main.dart` without refactoring unrelated widgets."

## Suggested next customization

Consider adding a project-specific `AGENTS.md` or `.github/copilot.yml` file that defines preferred file types, common project contexts, and explicit Do/Don't rules for Flutter/Dart edits.