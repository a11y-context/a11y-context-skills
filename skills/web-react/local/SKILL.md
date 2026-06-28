---
name: a11y-context-web-react-local
description: Apply accessibility patterns to React user-facing UI. Use whenever generating, building, creating, modifying, or refactoring React components, pages, routes, views, or any UI a user sees or interacts with — including buttons, forms, dialogs, modals, navigation, menus, carousels, dropdowns, toasts, banners, headers, footers, landing pages, product pages, and account flows. Use when the prompt mentions any UI element by name or describes a homepage, hero, card row, or interactive widget. Do not use for custom hooks (use*), context providers, HOCs, API handlers, type definitions, constants, or test helpers.
user-invocable: true
allowed-tools: Read
---

# A11y Context — React Skill

## Purpose

Read accessibility best-practice patterns from local documentation files and apply them before generating front-end React code. Run this skill before any implementation step that produces user-facing UI.

---

## Step 1 — Select Relevant Patterns

Read the component catalog from `${CLAUDE_SKILL_DIR}/patterns.json`. Each entry contains:
- `id` — the pattern identifier
- `summary` — a short description of the pattern
- `aliases` and `tags` — alternate names and keywords
- `selection_excerpt.use_when` — conditions under which this pattern applies
- `selection_excerpt.do_not_use_when` — conditions that exclude this pattern
- `source.path` — relative path to the local pattern file

For each component type involved in the current task:
1. Match the component against `aliases`, `tags`, and `use_when` criteria.
2. Apply `do_not_use_when` to exclude false matches.
3. If a component type has no matching pattern, note `Native + global rules` for it and continue.

Produce a short list of selected pattern IDs before reading any pattern files. If a component matches multiple patterns, prefer the most specific match (e.g., `button.toggle` over `button.basic` for a toggle action). If still ambiguous, read all candidates and apply the most applicable after reviewing their full content.

---

## Step 2 — Read Full Patterns

For each selected pattern, read the local file at:

```
${CLAUDE_SKILL_DIR}/{source.path}
```

where `source.path` is the value from the catalog entry (e.g., `components/accordion.md`, `components/button.basic.md`).

Read all selected pattern files in parallel before generating any code. Only read files for IDs on the selected list.

From each file, extract and apply:
- **Must Haves** — non-negotiable WCAG 2.2 AA requirements; implement all of them
- **Don'ts** — hard constraints; never produce code that violates them
- **Golden Pattern** — use as the implementation reference; match its structure and ARIA usage, adapted to the project's conventions
- **Customizable** — optional aspects that may be adjusted

If a file is missing, note it and continue with native HTML semantics and any applicable global rules.

---

## Step 3 — Apply Global Rules (Conditional)

Read `${CLAUDE_SKILL_DIR}/global_rules.md` when the task involves page/layout structure, headings, landmarks, navigation, or focus-critical UI (dialogs, menus, carousels).

Each rule in the file has a `scope` field. Apply only the rules whose scope matches the current task:

**Scope selection guide:**
- Building or modifying a full page or route → apply rules scoped to `page`, `layout`, `utility`
- Adding or modifying interactive components only → apply rules scoped to `component`, `utility`, `style`
- Both → apply all rules

Apply all `Must Haves` from matching rules. Do not introduce unrelated changes to satisfy rules outside the task scope.

Read at most **once** per session.

---

## Step 4 — Apply and Generate

Do not produce final code until pattern files have been read, or you have explicitly noted that no patterns apply to the current task.

Apply all `must_haves` from read patterns and applicable global rules. Treat `golden_pattern` code as the implementation reference — match its structure and ARIA usage, adapted to the project's existing component and styling conventions.

---

## Guardrails

### Retrieval
- Use the local catalog at `${CLAUDE_SKILL_DIR}/patterns.json` for component selection.
- Read only the pattern files needed for the current task.
- Read each pattern file at most once per session. Read `global_rules.md` at most once per session.

### Design System & Scope
- If the project uses a component library or design system, preserve it.
- Prefer minimal-change compliance: fix usage (props, labels, structure) before replacing components.
- Do not refactor unrelated code or introduce architectural changes beyond the requested scope.

### Styling
- Use the project's existing styling system (Tailwind, CSS modules, design system tokens, etc.).
- Treat `golden_pattern` styling as optional examples, not requirements.
- Do not introduce a new styling dependency unless explicitly requested.

### Communication
- Apply this skill implicitly as part of implementation — do not narrate the file-reading workflow to the user.
- Surface process details only if:
  - a file read fails, or
  - the user explicitly asks how patterns were selected or applied.
