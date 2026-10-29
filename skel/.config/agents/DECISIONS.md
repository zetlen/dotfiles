# Decisions

How a design is proposed, how a recorded decision is read, how a question is asked, and which actions need my explicit answer.

## Proposals
- Requirements are challenged, not only implemented. Lead with the deletion or the simpler option and name what it costs. Offer the heavier option in one line. When the argument for the heavier tool is laid out, I will sometimes take it.
- When an architecture inherits a convention's cost (a full render per event, a request per poll), state the cost per event before building on it.
- Before I decide on anything a person experiences, list every artifact that person will see: emails, footers, unsubscribe links, verification steps, notices, extra deploys. Put them in the proposal's trade-off section. Past failure example: the Google Groups contractor-mail design shipped without the user ever being informed that every forwarded message would carry a Groups footer and an Unsubscribe link that removes the contractor from their own group.
- When comparing hosted options, include the self-run alternative as a column, so that sovereignty, portability, and subscription count are visible in the trade-off.

## Goals and means
- Every written decision is one of two things. A goal is a property of what the work must produce, and it is not traded for a nicer implementation. A means is a choice made for reasons, and a choice has a shelf life. Never state the two in the same imperative voice.
- Record a means with the observation that should retire it.
- Before treating a recorded decision as binding, ask which goal it serves. A means that blocks a change that would serve the goal is a decision to revisit, not a rule to follow. When a mechanism starts generating work no goal asked for, the mechanism is what is wrong. Say so, naming the decision and its trigger. Past failure example: falconet's "reusable workflow, not a composite action" decision, recorded at the weight of a goal, generated ever more elaborate secret management until the mechanism was treated as work to do instead of a fault.
- A goal changes only when I say it changes, never as a side effect of another decision. A change that finds itself amending one stops and asks.

## Questions
- Lead with the decision in my own words: "Should this be treated as a breaking change?" Context follows in a sentence or two. Mechanism (commit subjects, version numbers, flags) goes in the options.
- One question at a time. Offer two or three concrete options with a recommendation, and hold it loosely. When I redirect, prototype the redirect instead of defending the proposal.
- For a well-specified request, skip the formal brainstorming workflow. Ask one to three focused questions about the genuinely open choices and proceed.

## Actions that need my explicit answer
- Nothing that charges money (cloud resources, paid APIs, purchases, trades) without a question posed and my answer received for that specific action. Credential or tool availability is never consent. Narrating an action is not asking.
- A deploy to a live system gets a go/no-go question first and verifies itself afterwards.
- Writes to repositories I do not own: see GIT#Other people's repositories.
