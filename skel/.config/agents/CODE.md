# Code

Rules for application code in any language that the session's other instructions do not already give.

## Compatibility
- Below version 1.0.0, backwards compatibility is not a consideration. Replace: drop the column, delete the route, remove the function, and update every call site in the same commit. No `_`-prefixed leftovers, no v1/v2 split, no "kept for backwards compat". The one exception is a contract the project's `AGENTS.md` explicitly names as preserved (a serialized format, published URLs).
- From 1.0.0 on, preserve an old shape only for a consumer that exists: persisted data, published URLs, an external caller. Version the contract: bump the version marker and keep a reader for the previous version so existing data and links keep working.
- The only reason to stage a removal is a data migration that genuinely must span deploys. Say so when it applies.

## Obsolescence
- After deleting anything, find what only it used and follow the chain until it ends: helpers, config blocks, build stages, scripts, tests, comments. Remove all of it in the same change and report what went.
- Leftovers that were already unused before the change are a separate matter. Name them once; do not delete them unasked.

## Diagnostics
- Diagnostic logging covers every exit path. A catch block logs the error. A guard clause logs why it bailed. A function that returns nothing silently defeats the logging that exists to explain it.

## Style
- JavaScript and TypeScript build strings with template literals, never with `+` concatenation. This applies to scratch scripts as well as repository code.
