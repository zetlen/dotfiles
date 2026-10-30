# Version control

How changes move from a working tree to a default branch, and what reaches outside the repository.

## Issues
- When writing issue titles, use the following grammar convention: if the issue is a feature request, use "should" language, and if the issue is a bug, describe the buggy behavior in the present tense. If encountering issues that don't follow this convention, offer to rephrase them.

## Branches and pull requests
- Work lands through a branch and a pull request, even on a solo project. Commit directly to the default branch only when I say so.
- Before branching, before pushing, and before opening a pull request: fetch, fast-forward the local default branch, and rebase the working branch on it. `git fetch origin main && git log HEAD..origin/main --oneline` must print nothing. If the rebase is not trivial, ask before proceeding.
- One concern per pull request. Anything in the repository that looks wrong but that the request did not mention belongs in another pull request.
- When writing pull request titles, use conventional-commit notation, and describe what the pull request does to a codebase, not just the new behavior. "test: add coverage validation in CI" is acceptable, "coverage is checked in CI" is not.
- When the repository is squash-merged, the pull request title becomes the commit subject on the default branch, so it follows the commit subject rules below.
- Do not offer to merge locally when the repository has branch protection or a pull request convention. Push and open the pull request, with a body that says what changed and what must happen before it merges. Report the URL.
- In a stack of pull requests, watch for the merge and the deploy of the one you presented, then pull the default branch, rebase the next branch, and present it. I merge one at a time after a green deploy.

## Commits
- Subjects follow Conventional Commits: `<type>[(scope)][!]: <description>`, imperative, lowercase. The body says why.
- One capability per commit, not one commit per phase of work.
- Never disable commit signing. No `-c commit.gpgsign=false`, no `--no-gpg-sign`, no environment overrides. If signing fails headless, stop and say so.

## Other people's repositories
- Never open a pull request, issue, discussion, or comment on a repository, forum, or package registry I do not own. Not with my credentials, not under any circumstances. Prepare the patch and the write-up inside my own repository and say it is ready for me to submit.

## CI workflows
- Before writing or editing a workflow, look up the current release of every action it uses and read the release notes across any skipped major versions. Pin an action that receives a secret to the commit SHA of its release.
- When watching a run, find it by commit SHA with retries, poll on a short interval, report each job as it completes, and stop on the first failure. The watcher ends when the run ends.
- In a shell step, capture a command's whole result into a variable and then inspect it. Never `cmd | grep -q`: `grep -q` exits on the first match and can turn a found match into a failed pipeline under `pipefail`.

## My dotfiles
- The files in `~/.config/agents/` are symlinks into `~/.dotfiles`, and `PROSE.md` holds the fuss counter that agents edit in place. Never run `git reset`, `git stash`, `git restore`, `git checkout`, or `git clean` in that repository. An uncommitted increment there is the record; losing it hides a rename.

## Project tooling
- Reusable project commands go in a Makefile, or the project's existing task runner. Do not add mise tasks. mise is my version manager; the repository does not depend on it.
- Git hooks run through lefthook.
