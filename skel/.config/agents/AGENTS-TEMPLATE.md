# AGENTS.md

<!--
Template for a repository's AGENTS.md. Copy it, fill every section, delete
these comments. Keep what an agent cannot infer from the code; delete what
it can. Architecture summaries, file trees, and API listings restate the code
and go stale: leave them out. The global rules in ~/.config/agents/ already
apply; do not repeat them here. State the reasoning in a linked document,
not here.
-->

<One paragraph: what this project is, who uses it, and which document holds the reasoning. Read that document first.>

## Facts

- Version: `<file and field that holds the version literal>`. Below 1.0.0, no backwards compatibility (CODE#Compatibility.1). Preserved contracts: <none | serialized format X, published URLs under /s/>.
- Forge: <GitHub `owner/repo` with `gh` | Gitea at `<host>` with the Gitea MCP tools>. <A GitHub remote is a read-only mirror.>
- Integration: <pull request required, squash-merged | direct push to `main` allowed>. Branch protection: <verified commits | none>.
- Merge gate: `<command>` must pass <before every commit | before every push>. It runs <what: format, typecheck, lint, tests>.
- Hooks: <lefthook, installed by `<command>` | none>.
- Toolchain: <mise pins the runtimes; `<package manager>`; `<task runner>`>.
- Reaches money or production: <none | `<command>` deploys to `<host>`; `<resource>` is billed>. Each needs a go/no-go question first (DECISIONS#Actions that need my explicit answer).
- Runs that need a real terminal: <none | `<command>`>.
- Secrets: <`.env` holds real credentials, never echo it; `.env.example` lists the names>.

## Commands

```sh
<install>        # <what it does>
<dev server>     # <what it does, port>
<build>
<test all>
<test one>       # <how to select one file or one test>
<check>          # the merge gate
```

## Where things go

| You are about to | Read first |
| --- | --- |
| <Add an endpoint> | <docs/guides/add-endpoint.md> |
| <Change the schema> | <docs/features/database.md> |
| <Change the recruiting stages> | <docs/agents/recruiting-state-machine.md> |

## Non-negotiables

<Numbered. Each one states the failure it prevents, in one sentence, so the reader can tell a rule from a taste.>

1. <Never edit `drizzle/`. Migrations are generated and immutable once committed; a hand edit desynchronizes the snapshot and every later diff.>
2. <Never break the `.route()` chain in `app.ts`. A separate `app.route()` call serves traffic and silently drops the route from the exported type, so frontend calls stop being type-checked with no error anywhere.>

## Do not

- <Do not add a dependency without saying what it replaces and why the alternative was worse.>
- <Do not `git push`, open a pull request, or change repository settings unless asked.>
