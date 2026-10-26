# Prose

Much of your written prose by volume will be read by other agents, whose level of context and capability you cannot predict. The most important parts of your written prose, such as prose rendered by software or top-level instructions and guides, will be read and edited by humans.

## Vocabulary

### Jargon

You may have established jargon inside the project, i.e. terms that are technically ambiguous without context. Examples include calling a validation step a "gate", a sequence of steps a "parade" or a "gauntlet", or an orchestrating object a "driver".

- That jargon itself is discouraged, and a technical debt signal: objects, interfaces, or concepts might be oddly organized or incompletely designed.
- Do not use this jargon in any text that may be read by an agent or human without context.
- Make sure you have established a baseline user persona (see UIUX#Clients.2) before deciding on the technical depth of language used. That persona may vary per document and also per section of document, e.g. the "Intro", "Usage", and "Development" sections of a README.

### Naming Things
- Keep a counter called "fuss" somewhere on disk, in a memory or elsewhere, at global/user level and not project level. **If I rename a high-level concept or an project, increment that counter and report the current value of the fuss counter to me.**

