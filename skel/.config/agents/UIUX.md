# UI / UX

These are partly general best practices about UI development and design, and partly my own personal tastes. They refer not to visual website design, but to interactive application UIs.

## Architecture

- If a template system is already available in the project, use it.
- Separate into partials as soon as a multiline pattern is repeated three times. Do not use a template system that doesn't support partials.
- Only use string-building to generate UI code if you are certain it won't have to be expanded or maintained.
- Regularly revisit the architecture of simple UIs early in projects. When, and only when, it becomes impractical to maintain progressively-enhanced plain HTML, refactor into a rendering framework like React (a reasonable default choice).
- If a component library is in the project, use its stock molecules as documented and express the project's look as a theme: tokens, fonts, radius, and thin variants. Hand-build a primitive only when no molecule fits. Bespoke interaction primitives re-litigate decisions the library already made. Past failure example: managery's first React cut built EmbossCard, Stamp, KebabMenu, ClampedBody and a three-state inline title editor, then pivoted to stock Dialog, DropdownMenu, and Collapsible plus one Button variant.
- Maintain all state that can be practically encoded in the URL in the URL. This includes filtering state in multiple elements, whose URL parameter state representations can be namespaced.

## Clients
- Assistive devices are first-class clients and disabled users are first-class users. On top of that, planning around a proper a11y tree produces better visual organization as well.
- Establish at the outset who the primary users will be, what devices they will use most often to access the UI, and what their level of technical understanding will be.

## Interaction
- Every dialog submits on Cmd/Ctrl+Enter and cancels on Escape.
- Every icon-only button has an `aria-label`.

## UX
- Consider the likely dimensions of elements and put them near each other if they will be used together. Stack elements in narrow screens, and keep their edges aligned.
- Do not give form fields equal widths. Size each field to the judged typical or maximum length of its content: a number field is much narrower than an email field, which is narrower than a full-name field, under most circumstances.
- Do not litter UIs with decorative text. The habit to avoid is the heads-up-display look: small uppercase tracked-out labels above headings or in corners, joined by middle dots ("MTV FARM · FOUR ERA CHANNELS · 21 AUG 2026", "PRE-IMPLEMENTATION SURVEY · NO CODE WRITTEN"), status badges repeated in several places, and metadata nobody asked for (dates, counts, "2026 PORTFOLIO"). Remove all text that would not help in the a11y tree unless instructed otherwise.
- Do not nest boxes with borders more than two deep. "Boxes within boxes" is another failure mode of LLM UI design. If you must nest visually distinct areas, vary how you distinguish them: boxes, background colors, hairline dividers, etc.
- Do not add explanatory body text in the UI in the form of sentences. If it sounds like a code comment, it doesn't face the user.
- User-facing copy describes the outcome or the action, never the mechanism. Keep consequential facts in plain words. Cut reassurance, a second sentence that repeats the first, and consequences the reader already knows. Past failure example: Chronicler's admin screen said "its messages are fetched and transformed right here in the browser," to a reader who is non-technical and does not care where or how the transform takes place.

## Visual
- Flat over decorated. No faux-3D, emboss, or drop-shadow treatments on marks and controls.
- One accent color belongs to the one main action per view. Headings and landmarks get their hierarchy from a type scale, not from the accent.
- Subtle over heavy. When a state needs a visual, reuse a property the element already has before adding a new ornament.
- Expect several rounds on sizing. Do not try to land a size in one shot.
