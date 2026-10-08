---
name: a11y-context-ios-swiftui-rag
description: Apply accessibility patterns to SwiftUI user-facing UI. Use whenever generating, building, creating, modifying, or refactoring SwiftUI views, screens, or any UI a user sees or interacts with — including buttons, forms, text fields, pickers, toggles, steppers, sliders, alerts, sheets, menus, links, and list rows. Use when the prompt mentions any UI element by name or describes a screen, settings pane, detail view, or interactive control. Do not use for view models, Combine publishers, networking, persistence, data models, or test helpers.
user-invocable: true
allowed-tools: Read WebFetch
---

# A11y Context — SwiftUI Skill (Enterprise RAG)

## Purpose

Retrieve accessibility best-practice patterns from your organization's retrieval system (vector DB / enterprise RAG) and apply them before generating SwiftUI code. Run this skill before any implementation step that produces user-facing UI.

This variant is the **brain**: it decides which patterns are needed and applies them. Your RAG index is the **retrieval mechanism** — you index the A11y Context corpus into it, and this skill queries it. Because your endpoint is your infrastructure, the skill can't have the address baked in; it reads the address from a config file (below).

This skill's own files, such as `decisions-protocol.md`, are in the folder that contains this `SKILL.md`, and every path to one of them below is relative to that folder. In Claude Code, that folder is `${CLAUDE_SKILL_DIR}`.

---

## Scope check — before any other step

This corpus covers iPhone and iPad. It does not cover Apple TV, where the focus engine and the Siri Remote change what correct looks like. Run this check for each file you will change, since one task can touch both.

**The file targets Apple TV** if any of these is true:
- It is compiled only for tvOS: it belongs only to a target built for the `appletvos` SDK, or its contents are wrapped in `#if os(tvOS)`.
- It imports `TVUIKit` or `TVServices`.
- The request names Apple TV, tvOS, or the Siri Remote.

**If the file targets Apple TV,** do not retrieve or apply patterns to it. Do the work using the codebase's existing tvOS accessibility conventions, and say once: "This code targets Apple TV. The A11y Context SwiftUI corpus covers iPhone and iPad only, so I followed the codebase's existing tvOS accessibility conventions and did not apply iPhone patterns here."

**If the file builds for both iOS and tvOS,** apply patterns to the iOS code, leave `#if os(tvOS)` blocks alone, and add one line: "This change also ships in the tvOS build and was not checked against tvOS behavior."

**Otherwise,** continue with the steps below.

---

## Step 0 — Read the retrieval config and the decisions protocol

Read `a11y-context.config.json`. It provides:
- `ragEndpoint` — the URL the skill queries for pattern content
- `indexName` — the index/namespace holding the A11y Context corpus
- `stack` — the platform to scope to (`ios/swiftui`)
- `topK` — how many chunks to retrieve per query (default 3)

If the config still contains the placeholder `ragEndpoint`, stop and tell the user to fill it in before the skill can retrieve.

Then read `decisions-protocol.md` and follow it on every task. It covers this codebase's `.a11y-context/decisions.md`, which may not exist yet, and when to ask before replacing something the codebase already has.

---

## Step 1 — Select and query per component

For each component type involved in the current task, form a retrieval query from the component's name and role (e.g., "modal dialog", "toast notification", "account dropdown menu") and query `ragEndpoint` against `indexName`, filtered to `stack`, returning the top `topK` chunks.

Adapt the call to your RAG platform's API — the retrieval contract varies (Pinecone, Weaviate, Azure AI Search, a custom endpoint). The corpus pages are chunked on major headings and each chunk carries its pattern `id` and summary, so filter and rank by relevance to the component.

Retrieve queries for all components before generating any code. If a component returns no relevant chunks, note `Native + Foundations` for it and continue.

---

## Step 2 — Extract and apply

From the retrieved chunks for each component, extract and apply:
- **Must Haves** — non-negotiable WCAG 2.2 AA requirements; implement all of them
- **Don'ts** — hard constraints; never produce code that violates them
- **Customizable** — optional aspects that may be adjusted
- **Golden Pattern** — the implementation reference; match its structure and its accessibility semantics, adapted to the project's conventions

They appear in the pattern in that order: what you must do, what you must never do, where you have room, then the reference implementation.

If retrieval quality is poor (chunks don't cover a selected pattern's Must Haves), widen `topK` or refine the query before falling back to native semantics. Do not invent pattern guidance.

---

## Step 3 — Retrieve Foundations (Always)

On every UI task, also query for the Foundations ruleset (index terms: "Foundations", "global rules", "focus states", "landmarks", "headings", "contrast"). Foundations rules are not only screen-level; most are component-specific. **Apply every Foundations rule to the code you write.** Do not pre-filter which rules to read: a rule that does not apply excludes itself, because there is no page title inside a button.

`scope` exists for one job, and it is the opposite of filtering. It tells you **what not to go and repair in code you were not asked to change.** The buckets are a structural scale, identical on every stack:

- `screen` — the document, route, or screen as a whole
- `layout` — the structural frame inside a screen: landmarks, heading hierarchy, regions
- `component` — an individual element and its own presentation

So: adding a button to an existing screen means applying the `component` rules to the button you write, and leaving a missing navigation title or a broken heading order **alone**. Report what you saw; do not fix it. Silently repairing it produces a large diff for a small request; silently ignoring it wastes what you noticed. Say it in one line and move on.

Apply all `Must Haves` from every rule that bears on the code you are writing.

---

## Step 4 — Apply and Generate

Do not produce final code until the retrieval queries have returned, or you have explicitly noted that no patterns apply.

Apply all Must Haves from retrieved patterns and applicable Foundations rules. Treat the Golden Pattern as the implementation reference — match its structure and its accessibility semantics, adapted to the project's existing view and styling conventions.

---

## Retrieval Parameters

- Always scope to the `ios/swiftui` stack. This skill covers SwiftUI only. Other stacks exist in the corpus and are not interchangeable with it.
- If the user is writing for a different stack, stop and say which skill covers it (`a11y-context-web-react-*`, `a11y-context-android-compose-*`). The corpus serves all three, and the patterns are not interchangeable — a stack's Golden Patterns are written in its own language against its own accessibility layer.
- If the RAG endpoint is unreachable, report it and stop. Do not silently fall back.

---

## Guardrails

### Retrieval
- Query only for the components in the current task. Retrieve Foundations once per session, and again if a later request brings in a new component type or the results have left your context.
- Prefer precision over recall — retrieve the pattern that matches, not adjacent similar ones.

### Design System & Scope
- If the project uses a component library or design system, preserve it.
- Replace one of its components only by following the decisions protocol, which asks first.
- Prefer minimal-change compliance: fix usage (props, labels, structure) before replacing components.
- Do not refactor unrelated code or introduce architectural changes beyond the requested scope.

### Styling
- Use the project's existing styling (view modifiers, a design system, shared style types, etc.).
- Treat Golden Pattern styling as optional examples, not requirements.
- Do not introduce a new styling or component dependency unless explicitly requested.

### Communication
- Apply this skill implicitly as part of implementation — do not narrate the retrieval workflow to the user.
- Surface process details only if retrieval fails, or the user explicitly asks how patterns were selected or applied.
- The scope check's message and the decisions protocol's messages are not process narration. Say them as written when they call for them.
