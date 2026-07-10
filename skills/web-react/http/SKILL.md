---
name: a11y-context-web-react-http
description: Apply accessibility patterns to React user-facing UI. Use whenever generating, building, creating, modifying, or refactoring React components, pages, routes, views, or any UI a user sees or interacts with — including buttons, forms, dialogs, modals, navigation, menus, carousels, dropdowns, toasts, banners, headers, footers, landing pages, product pages, and account flows. Use when the prompt mentions any UI element by name or describes a homepage, hero, card row, or interactive widget. Do not use for custom hooks (use*), context providers, HOCs, API handlers, type definitions, constants, or test helpers.
user-invocable: true
allowed-tools: Read WebFetch
---

# A11y Context — React Skill

## Purpose

Retrieve accessibility best-practice patterns from the pattern documentation site and apply them before generating front-end React code. Run this skill before any implementation step that produces user-facing UI.

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

Produce a short list of selected pattern IDs before making any fetch calls. If a component matches multiple patterns, prefer the most specific match (e.g., `button.toggle` over `button.basic` for a toggle action). If still ambiguous, retrieve all candidates and apply the most applicable after reading their full content.

---

## Step 2 — Retrieve Full Patterns

For each selected pattern ID, fetch its documentation page:

```
GET https://a11y-context-project.vercel.app/web/react/components/{id}
```

Example: for `toast.basic` → `https://a11y-context-project.vercel.app/web/react/components/toast.basic`

Issue all fetches in parallel before generating any code — do not retrieve one at a time.

From each fetched page, extract and apply:
- **Must Haves** — non-negotiable WCAG 2.2 AA requirements; implement all of them
- **Don'ts** — hard constraints; never produce code that violates them
- **Golden Pattern** — use as the implementation reference; match its structure and ARIA usage, adapted to the project's conventions
- **Customizable** — optional aspects that may be adjusted

If a fetch returns a 404 or fails, note it and continue with native HTML semantics and any applicable global rules. Do not invent pattern guidance.

---

## Step 3 — Apply Global Rules (Always retrieve; apply by scope)

Read `${CLAUDE_SKILL_DIR}/global_rules.md` on every UI task. Foundations rules are not only page-level — many are component-specific. Each rule has a `scope` field; apply the Must Haves of every rule whose scope matches the current change:

**Scope selection guide:**
- Building or modifying a full page or route → apply rules scoped to `page`, `layout`, `utility`
- Adding or modifying interactive components only → apply rules scoped to `component`, `utility`, `style`
- Both → apply all rules

Apply all `Must Haves` from matching rules. Do not introduce unrelated changes to satisfy rules outside the task scope.

Read at most **once** per session.

---

## Step 4 — Apply and Generate

Do not produce final code until pattern pages have been fetched, or you have explicitly noted that no patterns apply to the current task.

Apply all Must Haves from retrieved patterns and applicable global rules. Treat the Golden Pattern as the implementation reference — match its structure and ARIA usage, adapted to the project's existing component and styling conventions.

---

## Retrieval Parameters

- Always use the `web/react` path. It is the only populated stack.
- If the user explicitly requests a different stack, state that it is not yet available and proceed with `web/react` equivalents, or stop if the task cannot be adapted.
- If a fetch fails, report the error and stop. Do not attempt alternative retrieval mechanisms.

---

## Guardrails

### Retrieval
- Use the local catalog at `${CLAUDE_SKILL_DIR}/patterns.json` for component selection.
- Fetch only the patterns needed for the current task.
- Fetch each pattern URL at most once per session. Read `global_rules.md` at most once per session.

### Design System & Scope
- If the project uses a component library or design system, preserve it.
- Prefer minimal-change compliance: fix usage (props, labels, structure) before replacing components.
- Do not refactor unrelated code or introduce architectural changes beyond the requested scope.

### Styling
- Use the project's existing styling system (Tailwind, CSS modules, design system tokens, etc.).
- Treat Golden Pattern styling as optional examples, not requirements.
- Do not introduce a new styling dependency unless explicitly requested.

### Communication
- Apply this skill implicitly as part of implementation — do not narrate the retrieval workflow to the user.
- Surface process details only if:
  - a fetch fails or is blocked, or
  - the user explicitly asks how patterns were selected or applied.
