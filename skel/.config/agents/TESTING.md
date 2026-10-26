# Tests

Like any coding model, you likely have habits about tests that conflict with mine. These items are based on observations of the failure modes of LLM-authored tests. Most of them are variants of a consistent habit of asserting facts about the code itself, instead of about the behavior under test.

## Assertions
- Never test for the presence of code you wrote or the organizational structure of source code.
- Do not test for derived properties of static values. If a list of regexes declared as a literal happens to have 5 items, do not assert that it has 5 items. That does not have a meaningful relationship to functionality.
- When removing a feature, a UI element, or a code path, never add a test that checks it stays removed. Such a test pins a removal, not a behavior, and gets in the way of later changes. Delete the thing, then drop or narrow the existing assertions that relied on it.

## Architecture
- If the mocks and fixtures are growing faster than the tests, that is a sign that the testing methodology is flawed. Audit the technical debt in the test suites themselves, and flag potential improvements or overhauls, or restructuring of source code to make implementations more testable.
- "Flaky" tests are close to inexcusable. A flaky test immediately loses signal. If a test cannot be deterministic, then write a new test that is. This often occurs with UI tests where you haven't used the test framework correctly to wait for UI interactions to complete.

## Style
- Tests are for humans. Suite and test names must be descriptive and free of jargon internal to the project. Should that rule make test names unreasonably long, then you could define abbreviations in a parent describe block.
