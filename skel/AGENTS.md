# AGENTS.md

Rules and guidelines to follow when working on technical projects with me.

This document is split into multiple parts, so each section can be read only when its subject matter becomes relevant during work. Do not read them until that time, but at that time, they become mandatory reading.

All files below are located in one folder, `~/.config/agents/`, so the filename alone is used. They are symlinks into my dotfiles repository; see GIT#My dotfiles before running git there.

## References

When referencing clauses, here is the format: `<basename>#<section>[.subsection][.index]`. `<basename>` is the basename of the file in which the clause was found, e.g. `TESTING` for `TESTING.md`. `<section>` refers to the h2 markdown header `##` exactly at, or immediately preceding, the referenced line. Optional `[.subsection]`s if there is a deeper hierarchy of markdown headers, and `.index` (numeric, 1-indexed) if the referenced item is in an ordered or unordered list. Do not use line numbers in references. Example: `TESTING#Determinism.2`.

When a clause from these files applies to what you are doing or reporting, cite it in the reply with this format. A clause you cannot cite is a clause you have not read.

## Conflicts

Where a plugin skill's workflow or a hook's instruction conflicts with these files, these files win. Tell me about the conflict in the reply, naming the skill and the clause.

## Sections

### [Code](CODE.md)
Read before writing or reviewing application code: when replacing or removing anything, when adding logging, and for language-specific style.

### [Testing](TESTING.md)
Read before and while writing, auditing, reviewing, or debugging tests, including unit tests, functional tests, integration tests, end-to-end tests, and test helper code such as mocks, fixtures, and runners. Also read when a test fails.

### [UI and UX](UIUX.md)
Read before and while coding, auditing, reviewing, or debugging UI, including web and mobile UI, TUIs, and CLIs, all of which count as UI.

### [Prose](PROSE.md)
Read before and while writing prose text, including explanatory documentation, code comments, introductions, guides, instructions, reports, issues, pull requests, and agent instruction files.

### [Version control](GIT.md)
Read before branching, committing, pushing, opening or merging a pull request, writing a CI workflow, adding project tooling, or touching a repository I do not own.

### [Decisions](DECISIONS.md)
Read before proposing a design, acting on a recorded decision, asking me a question, spending money, deploying, or choosing infrastructure.

### [Operating](SESSION.md)
Read before running a long command, starting a background process, dispatching or coaching other agents, or verifying a feature for handover.

## Templates

### [Project instruction file](AGENTS-TEMPLATE.md)
The template for a repository's own `AGENTS.md`. Use it when creating one, and when pruning one that restates the code.
