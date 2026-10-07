---
name: a11y-context-android-compose-mcp
description: Apply accessibility patterns to Jetpack Compose user-facing UI. Use whenever generating, building, creating, modifying, or refactoring composables, screens, or any UI a user sees or interacts with — including buttons, forms, text fields, dialogs, bottom sheets, navigation, menus, lists, content shelves, switches, checkboxes, and settings screens. Use when the prompt mentions any UI element by name or describes a screen, home feed, card row, or interactive widget. Do not use for ViewModels, repositories, use cases, data classes, dependency-injection modules, network clients, or test helpers.
user-invocable: true
allowed-tools: mcp__a11y-context__list_patterns mcp__a11y-context__get_pattern mcp__a11y-context__get_foundations Read
---

# A11y Context — Jetpack Compose Skill (MCP)

## Purpose

Retrieve accessibility best-practice patterns through the A11y Context MCP server and apply them before generating Compose UI code. Run this skill before any implementation step that produces user-facing UI.

This variant is the **brain**: it decides which patterns are needed and applies them. The [MCP server](https://github.com/a11y-context/accessibility-pattern-mcp) is the **retrieval mechanism** — it must be installed in your client (see the server's README). The three tools below assume the server is configured under the name `a11y-context`; if you named it differently, the tool prefix changes accordingly.

This skill's own files, such as `decisions-protocol.md`, are in the folder that contains this `SKILL.md`, and every path to one of them below is relative to that folder. In Claude Code, that folder is `${CLAUDE_SKILL_DIR}`.

---

## Scope check — before any other step

This corpus covers Android phones and tablets. It does not cover Android TV, Google TV, or Fire TV, where the remote and the platform's screen readers change what correct looks like. Run this check for each file you will change, since one task can touch both.

**The file targets TV** if any of these is true:
- It imports from `androidx.tv.*` or `androidx.leanback.*`.
- Its module's manifest declares the `android.software.leanback` feature or a `LEANBACK_LAUNCHER` category.
- It lives in a module or source set that exists for the TV build, such as `compose-tv`, `ui-tv`, `app-tv`, `firetv`, or a `tv` source set. A phone feature named for live TV or a TV guide is not a TV module.
- The request names Android TV, Google TV, Fire TV, a TV screen, a remote, or the D-pad.

**If the file targets TV,** do not retrieve or apply patterns to it. Do the work using the codebase's existing TV accessibility conventions, and say once: "This code targets Android TV or Fire TV. The A11y Context Compose corpus covers phones and tablets only, so I followed the codebase's existing TV accessibility conventions and did not apply phone patterns here."

**If the file is in a shared module that the TV build also uses,** apply patterns as usual and add one line: "This change also ships in the TV build and was not checked against TV behavior."

**Otherwise,** continue with the steps below.

---

## Step 0 — Follow the decisions protocol

Read `decisions-protocol.md` and follow it on every task. It covers this codebase's `.a11y-context/decisions.md`, which may not exist yet, and when to ask before replacing something the codebase already has.

---

## Step 1 — Select Relevant Patterns

Call `list_patterns` to retrieve the component catalog. Each entry contains:
- `id` — the pattern identifier
- `summary` — a short description of the pattern
- `aliases` and `tags` — alternate names and keywords
- `selection_excerpt.use_when` — conditions under which this pattern applies
- `selection_excerpt.do_not_use_when` — conditions that exclude this pattern

For each component type involved in the current task:
1. Match the component against `aliases`, `tags`, and `use_when` criteria.
2. Apply `do_not_use_when` to exclude false matches.
3. If a component type has no matching pattern, note `Native + Foundations` for it and continue.

Produce a short list of selected pattern IDs before making any `get_pattern` calls. If a component matches multiple patterns, prefer the most specific match (e.g., `radio.basic` over `list-item.basic` for a row in a mutually exclusive set). If still ambiguous, retrieve all candidates and apply the most applicable after reading their full content.

---

## Step 2 — Retrieve Full Patterns

For each selected pattern ID, call `get_pattern(id)`. Issue all calls before generating any code — do not retrieve one at a time.

From each returned pattern, extract and apply:
- **Must Haves** — non-negotiable WCAG 2.2 AA requirements; implement all of them
- **Don'ts** — hard constraints; never produce code that violates them
- **Customizable** — optional aspects that may be adjusted
- **Golden Pattern** — the implementation reference; match its structure and its accessibility semantics, adapted to the project's conventions

They appear in the pattern in that order: what you must do, what you must never do, where you have room, then the reference implementation.

If a call fails, report the error and stop. Do not invent pattern guidance or fall back to another retrieval mechanism.

---

## Step 3 — Retrieve Foundations (Always, in full)

Call `get_foundations()` on every UI task. Foundations rules are not only screen-level; most are component-specific. **Apply every Foundations rule to the code you write.** Do not pre-filter which rules to read: a rule that does not apply excludes itself, because there is no page title inside a button.

`scope` exists for one job, and it is the opposite of filtering. It tells you **what not to go and repair in code you were not asked to change.** The buckets are a structural scale, identical on every stack:

- `screen` — the document, route, or screen as a whole
- `layout` — the structural frame inside a screen: landmarks, heading hierarchy, regions
- `component` — an individual element and its own presentation

So: adding a button to an existing screen means applying the `component` rules to the button you write, and leaving a missing pane title or a broken heading order **alone**. Report what you saw; do not fix it. Silently repairing it produces a large diff for a small request; silently ignoring it wastes what you noticed. Say it in one line and move on.

Apply all `Must Haves` from every rule that bears on the code you are writing.

Call it again if a later request in this session brings in a new component type, or if the response is no longer in your context. Otherwise once per session is enough. Do not pass the optional `scope` argument: it narrows what the server returns, and narrowing retrieval is not what `scope` is for.

---

## Step 4 — Apply and Generate

Do not produce final code until `get_pattern` has returned for every selected pattern, or you have explicitly noted that no patterns apply.

Apply all Must Haves from retrieved patterns and applicable Foundations rules. Treat the Golden Pattern as the implementation reference — match its structure and its accessibility semantics, adapted to the project's existing component and theming conventions.

---

## Retrieval Parameters

- Always use the `android/compose` stack. This skill covers Jetpack Compose only. Other stacks exist in the corpus and are not interchangeable with it.
- If the user is writing for a different stack, stop and say which skill covers it (`a11y-context-web-react-*`, `a11y-context-ios-swiftui-*`). The corpus serves all three, and the patterns are not interchangeable — a stack's Golden Patterns are written in its own language against its own accessibility layer.
- If the MCP server is unreachable, report it and stop. Do not attempt alternative retrieval mechanisms.

---

## Guardrails

### Retrieval
- Select with `list_patterns`; retrieve only the patterns needed for the current task.
- Call `get_pattern` once per selected id, and `get_foundations` once, per session. Call either again if a later request returns to that component, brings in a new one, or the response has left your context.

### Design System & Scope
- If the project uses a component library or design system, preserve it.
- Replace one of its components only by following the decisions protocol, which asks first.
- Prefer minimal-change compliance: fix usage (props, labels, structure) before replacing components.
- Do not refactor unrelated code or introduce architectural changes beyond the requested scope.

### Styling
- Use the project's existing theming system (the Material theme, design-system tokens, etc.).
- Treat Golden Pattern styling as optional examples, not requirements.
- Do not introduce a new theming or component dependency unless explicitly requested.

### Communication
- Apply this skill implicitly as part of implementation — do not narrate the retrieval workflow to the user.
- Surface process details only if a tool call fails, or the user explicitly asks how patterns were selected or applied.
- The scope check's message and the decisions protocol's messages are not process narration. Say them as written when they call for them.
