# Tests

Like any coding model, you likely have habits about tests that conflict with mine. These items are based on observations of the failure modes of LLM-authored tests. Most of them are variants of a consistent habit of asserting facts about the code itself, instead of about the behavior under test.

## Assertions
- Never test for the presence of code you wrote or the organizational structure of source code.
- Do not test for derived properties of static values. If a list of regexes declared as a literal happens to have 5 items, do not assert that it has 5 items. That does not have a meaningful relationship to functionality.
- When removing a feature, a UI element, or a code path, never add a test that checks it stays removed. Such a test pins a removal, not a behavior, and gets in the way of later changes. Delete the thing, then drop or narrow the existing assertions that relied on it.
- A property is tested in exactly one place. When a unit test and an end-to-end case would assert the same thing, keep the unit test.
- An integration-level guarantee needs an integration test. A permission check, for example, is proven by a request that gets a 403. Asserting that a mock returns false proves only that the mock returns false.

## Architecture
- If the mocks and fixtures are growing faster than the tests, that is a sign that the testing methodology is flawed. Read the suite and judge whether it has outgrown its structure. Propose a restructuring when it has: introduce a dependency-injection container, replace fixtures with scratch services, or restructure the source so the implementation is testable without the scaffolding.
- A suite whose dependency is missing (a database, a browser, a binary) fails with instructions for providing it. It never skips.

## Determinism

A test passes or fails by the code alone. Its result does not depend on how fast the machine is, the order the tests run in, what else runs on the machine, the user who runs it, or the shell it starts from. A test that fails one run in a thousand is a broken test, and it immediately loses signal. If a test cannot be deterministic, write a different test that is.

- No wall clock and no randomness in an outcome. Do not call `Date.now()`, a bare `new Date()`, `Math.random`, `randomUUID`, `randomBytes`, or their equivalents in a test. Use fixed instants, counter-based ids, and fake timers by default.
- Wait on the event, never on the clock. A test that needs something to have happened receives from a channel, awaits a promise or a wait group, or polls a condition with a bounded helper. It never sleeps for a fixed time. When timing is itself the thing under test, the clock line carries a comment saying so and the margin is generous.
- Prove a thing did not happen by first finishing the work that could have done it, then looking.
- Nothing outlives its test. Background work started by a test is awaited or cancelled before the test returns.
- Compare two times only when they come from the same clock.
- The machine and the shell stay out. Bind to port 0. Clear every environment variable the code reads before the run. Never depend on a user, a home directory, or a real network.
- Tests pass in any order. Shuffle them. A test that overrides shared state restores it in a cleanup.
- UI tests wait for interactions to complete through the framework's own waiting primitives, never through a fixed delay.

## Failures

When a test fails, stop. Do not retry, skip, or move on.

- Establish whether the failure comes from your change or is pre-existing by running the test on the base branch.
- Find the cause: a race, a timing assumption, shared state, nondeterministic input.
- Fix it when feasible. When the cause is too far afield for the current change, open an issue with the analysis before continuing. A failure is never dismissed as flaky without one of those two outcomes.
- Fix the whole class in one pass. One flaky test means the suite has that class of problem. Sweep for every instance before closing the change.
- Never re-run a failed CI job to get past a flake without also tracking down the cause.

## Style
- Tests are for humans. Suite and test names must be descriptive and free of jargon internal to the project. When that makes test names unreasonably long, put the shared context in the name of the parent describe block so the test names under it can stay short.
