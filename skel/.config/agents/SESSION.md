# Operating

How to run commands, delegate, and verify during a session.

## Long-running commands
- Run anything that may take more than a minute in the background with its output in a file, and arm a monitor that reports progress on an interval, flags a process that looks stuck, and ends with a done line. I should never have to ask whether it is stuck.
- Never pipe a long run through `tail` in the foreground.
- Before starting a persistent process (a dev server, a container stack), check for one already running from this session and reuse or stop it. Never run a duplicate. Duplicates fight for ports and locks.
- Some runners misbehave without a real terminal (browser test suites, interactive installers). Run those in a terminal pane or hand me the exact command.

## Delegation
- Pass an explicit model on every subagent dispatch and name it in the dispatch: Haiku for mechanical edits and lookups, Sonnet for ordinary implementation and review, Opus for design-heavy or multi-file work. Use the top tier only for work that genuinely needs it, and say so when you do.
- The target is total spend, not avoiding the strong model. A cheaper model that needs three rounds costs more than one round of a stronger one. Pick the cheapest model that will finish in one round.
- Before a heavyweight autonomous run (a multi-stage pipeline, a multi-hour build), quote the expected scale and get a nod. Quote about twice the finder estimate when a verification stage is included.
- "A pool of N" over a list means every item, at most N at once. It never means N items.
- When coaching an agent I dispatched elsewhere, coach it all the way through: implement, push, pull request, green CI, merge, verify. Do not amend or finish its work in its place. Complaints about its quality are welcome; the fix is a better next prompt.
- A non-Claude coding agent is for when the model family matters: a second-opinion review of a security-sensitive diff, an adversarial verifier, or flat-cost bulk mechanical work. Not for research whose output you need in your own context.

## Verification
- A feature gated by an environment value (a mode flag, an enforcement switch) is verified with that value set: in the running app, and in the end-to-end suite, with the scenario the ticket describes. Unit tests alone leave it untestable.
- When comparing images, charts, or spectra and the difference is not clearly visible, say so, then build tooling that extracts numbers. Never narrate a difference that should be there.
- When I link or name a document, read it first and say in one line what it says before researching anywhere else. Tool output is invisible to me. Only the prose shows what was read.
