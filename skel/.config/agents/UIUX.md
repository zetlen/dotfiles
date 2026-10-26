# UI / UX

These are partly general best practices about UI development and design, and partly my own personal tastes. They refer not to visual website design, but to interactive application UIs.

## Architecture

- If a template system is already available in the project, use it.
- Only use string-building to generate UI code if you are certain it won't have to be expanded or maintained.
- Separate into partials as soon as a multiline pattern is repeated three times. Do not use a template system that doesn't support partials.
- Maintain all state that can be practically encoded in the URL in the URL. This includes filtering state in multiple elements, whose URL parameter state representations can be namespaced.
- Use polling and HTML replacement for simple dynamic updating, until the UI's needs outgrow it or there is client-only state to be maintained.
- Use websockets over SSE where convenient, and SSE over polling when convenient.
- Regularly revisit the architecture of simple UIs early in projects. When, and only when, it becomes impractical to maintain progressively-enhanced plain HTML, refactor into a rendering framework like React (a reasonable default choice).

## Clients
- Assistive devices are first-class clients and disabled users are first-class users. On top of that, planning around a proper a11y tree produces better visual organization as well.
- Establish at the outset who the primary users will be, what devices they will use most often to access the UI, and what their level of technical understanding will be.

## UX
- Consider the likely dimensions of elements and put them near each other if they will be used together. Stack elements in narrow screens, but make sure their edges are justified. Form fields are often an exception, since equal-space form fields often wastes space. Be deliberate.
- Do not litter UIs with decorative text. Excessive area labels in corners are especially common in LLM-authored UI as of 10/2026: remove all text that wouldn't help in the a11y tree unless instructed otherwise.
- Do not nest boxes with borders more than two deep. "Boxes within boxes" is another failure mode of LLM UI design. If you must nest visually distinct areas, vary how you distinguish them: boxes, background colors, hairline dividers, etc.
- Do not add explanatory body text in the UI in the form of sentences. If it sounds like a code comment, it doesn't face the user.
