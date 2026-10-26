# Prose

Much of your written prose by volume will be read by other agents, whose level of context and capability you cannot predict. The most important parts of your written prose, such as prose rendered by software or top-level instructions and guides, will be read and edited by humans.

## Register

- No emoji anywhere: documentation, issues, pull requests, commit messages, UI copy, replies.
- Complete, literal sentences. One fact per sentence. No metaphor, no figure of speech, no heading that tells a story.
- Say what a thing is before referring to it by number: "pull request 121, the one that carried the wrong plan". A bare number, run id, or hash is not a reference.
- Every command comes with one sentence saying what it does and why it is run at that point.
- When reporting state, use short labeled lists: what changed, what was verified (the command and its result), what remains.
- A claim is checked against the file or the command output before it is written. An unchecked claim is labelled as such in the same sentence or left out.

## Vocabulary

### Jargon

You may have established jargon inside the project, i.e. terms that are technically ambiguous without context. Examples include calling a validation step a "gate", a sequence of steps a "parade" or a "gauntlet", or an orchestrating object a "driver".

- That jargon itself is discouraged, and a technical debt signal: objects, interfaces, or concepts might be oddly organized or incompletely designed.
- Do not use this jargon in any text that may be read by an agent or human without context.
- Make sure you have established a baseline user persona (see UIUX#Clients.2) before deciding on the technical depth of language used. That persona may vary per document and also per section of document, e.g. the "Intro", "Usage", and "Development" sections of a README.
- Two audiences. Anything a requester reads (issues, pull requests, comments, forms) must not need a glossary. Operator and agent surfaces (workflow comments, scripts, runbooks) prefer precision, with each term expanded once where it first appears.

### Naming Things

The fuss counter below is the number of times I have renamed a project (such as `zygos` or `talaria`) or a domain concept (such as `session` to `interview`). It is phrased wryly and it is serious: I cannot hide a rename from myself if the count lives in this file.

- **When I rename a project or a domain concept, increment the counter in this file in place and report the new value to me.** Only my renames count. A rename you propose does not count until I adopt it. Rename of a variable, file, or function is not a rename of a concept.

fuss: 4

## Comments and documents

Comments and documents describe the present. History lives in git.

- A comment says why the code must be this way for the system to work, not what the next line does. It never says when it was added, what it replaced, who asked for it, or what it was chosen over.
- A guard's comment states the failure it prevents, as a requirement: what input arrives, what must not happen. Read it before changing the guard.
- No comment explains code that is not there any more. No `// previously`, `// old approach`, `// removed`, `// kept because`. Remove such comments when you find them near code you are changing.
- Each fact lives in one place. A README says what the system is. A decision record says what was decided and why. An instruction file says how to work. None restates the others.
- A commit message says what changed and why. It never predicts what CI, a preview, or a deploy will report. The run reports that.
- When a change makes a comment, a document, or an instruction file stale, update it in the same change. Re-read the project's instruction file before opening a pull request.

## Agent instruction files

- Repo-level instructions go in `AGENTS.md`, which other agent harnesses read too. `CLAUDE.md`, when it must exist, contains only `@AGENTS.md`.
- An instruction file carries no status and no roadmap. Status has one home elsewhere, and a second copy rots.
- Keep instruction files short and point at the documents that hold the reasoning.
