---
name: a11y-context-android-compose-http
description: Apply accessibility patterns to Jetpack Compose user-facing UI. Use whenever generating, building, creating, modifying, or refactoring composables, screens, or any UI a user sees or interacts with — including buttons, forms, text fields, dialogs, bottom sheets, navigation, menus, lists, content shelves, switches, checkboxes, and settings screens. Use when the prompt mentions any UI element by name or describes a screen, home feed, card row, or interactive widget. Do not use for ViewModels, repositories, use cases, data classes, dependency-injection modules, network clients, or test helpers.
user-invocable: true
allowed-tools: Read WebFetch
---

# A11y Context — Jetpack Compose Skill

## Purpose

Retrieve accessibility best-practice patterns from the pattern documentation site and apply them before generating Compose UI code. Run this skill before any implementation step that produces user-facing UI.

---

## Step 1 — Select Relevant Patterns

Read the component catalog from `${CLAUDE_SKILL_DIR}/patterns.json`. Each entry contains:
- `id` — the pattern identifier used to construct the fetch URL
- `summary` — a short description of the pattern
- `aliases` and `tags` — alternate names and keywords
- `selection_excerpt.use_when` — conditions under which this pattern applies
- `selection_excerpt.do_not_use_when` — conditions that exclude this pattern

For each component type involved in the current task:
1. Match the component against `aliases`, `tags`, and `use_when` criteria.
2. Apply `do_not_use_when` to exclude false matches.
3. If a component type has no matching pattern, note `Native + global rules` for it and continue.

Produce a short list of selected pattern IDs before making any fetch calls. If a component matches multiple patterns, prefer the most specific match (e.g., `radio.basic` over `list-item.basic` for a row in a mutually exclusive set). If still ambiguous, retrieve all candidates and apply the most applicable after reading their full content.

---

## Step 2 — Retrieve Full Patterns

For each selected pattern ID, fetch its documentation page:

```
GET https://a11y-context-project.vercel.app/android/compose/components/{id}
```

Example: for `switch.basic` → `https://a11y-context-project.vercel.app/android/compose/components/switch.basic`

Issue all fetches in parallel before generating any code — do not retrieve one at a time.

From each fetched page, extract and apply:
- **Must Haves** — non-negotiable WCAG 2.2 AA requirements; implement all of them
- **Don'ts** — hard constraints; never produce code that violates them
- **Customizable** — optional aspects that may be adjusted
- **Golden Pattern** — use as the implementation reference; match its structure and semantics, adapted to the project's conventions

They appear in the pattern file in that order: what you must do, what you must never do, where you have room, then the reference implementation.

If a fetch returns a 404 or fails, note it and continue with a component that meets the Foundations contract and any applicable Foundations rules. Do not invent pattern guidance.

---

## Step 3 — Apply Global Rules (Always retrieve them all; scope bounds repairs, not reading)

Read `${CLAUDE_SKILL_DIR}/global_rules.md` on every UI task. Foundations rules are not only screen-level; most are component-specific. **Apply every Foundations rule to the code you write.** Do not pre-filter which rules to read: a rule that does not apply excludes itself, because there is no page title inside a button.

`scope` exists for one job, and it is the opposite of filtering. It tells you **what not to go and repair in code you were not asked to change.** The buckets are a structural scale, identical on every stack:

- `screen` — the document, route, or screen as a whole
- `layout` — the structural frame inside a screen: landmarks, heading hierarchy, regions
- `component` — an individual element and its own presentation

So: adding a button to an existing screen means applying the `component` rules to the button you write, and leaving a missing pane title or a broken heading order **alone**. Report what you saw; do not fix it. Silently repairing it produces a large diff for a small request; silently ignoring it wastes what you noticed. Say it in one line and move on.

Apply all `Must Haves` from every rule that bears on the code you are writing.

Re-read it if a later request in this session brings in a new component type, or if its contents are no longer in your context. Otherwise once per session is enough.

---

## Step 4 — Apply and Generate

Do not produce final code until pattern pages have been fetched, or you have explicitly noted that no patterns apply to the current task.

Apply all Must Haves from retrieved patterns and applicable global rules. Treat the Golden Pattern as the implementation reference — match its structure and its `Modifier.semantics` usage, adapted to the project's existing component and theming conventions.

---

## Retrieval Parameters

- Always use the `android/compose` path. This skill covers Jetpack Compose only. Other stacks exist in the corpus and are not interchangeable with it.
- If the user explicitly requests a different stack, state that it is not yet available and proceed with `android/compose` equivalents, or stop if the task cannot be adapted.
- If a fetch fails, report the error and stop. Do not attempt alternative retrieval mechanisms.

---

## Guardrails

### Retrieval
- Use the local catalog at `${CLAUDE_SKILL_DIR}/patterns.json` for component selection.
- Fetch only the patterns needed for the current task.
- Fetch each pattern URL once, and again only if a later request returns to that component or its contents have left your context. The same applies to `global_rules.md`.

### Design System & Scope
- If the project uses a component library or design system, preserve it.
- Prefer minimal-change compliance: fix usage (props, labels, structure) before replacing components.
- Do not refactor unrelated code or introduce architectural changes beyond the requested scope.

### Styling
- Use the project's existing theming system (the Material theme, design-system tokens, etc.).
- Treat Golden Pattern styling as optional examples, not requirements.
- Do not introduce a new theming or component dependency unless explicitly requested.

### Communication
- Apply this skill implicitly as part of implementation — do not narrate the retrieval workflow to the user.
- Surface process details only if:
  - a fetch fails or is blocked, or
  - the user explicitly asks how patterns were selected or applied.
