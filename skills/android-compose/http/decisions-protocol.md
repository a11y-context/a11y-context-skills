# Decisions protocol

Follow this on every task, alongside the steps in `SKILL.md`. It covers two things: this codebase's own decisions file, `.a11y-context/decisions.md`, and when to ask before changing something the codebase already has.

## 1. Read the decisions file

After the scope check and before selecting patterns, read `.a11y-context/decisions.md` at the repository root. If it does not exist, carry on. Do not create it until a person confirms an entry (section 6).

Each entry is a fenced `yaml` block with a `kind`. If an entry is malformed, ignore it and say once which one. A broken entry never stops a fix. An entry whose `platform` is not `all` applies only to code for that platform.

An entry applies only when its fields match the code you are working on. When it is unclear whether an entry applies, it does not.

| Kind | Applies when | What you do | What you say |
|---|---|---|---|
| `mapping` | You would write the pattern's component, or the API `rule` names (`api`) | Write `local` instead, and hold it to the same requirements | Nothing |
| `compliance-claim` | You would check `rule` on `local` | Read `file`. If `mechanism` is there, skip `rule` on `local`. If it is gone, check `rule` as usual | Nothing, unless the mechanism is gone |
| `decided-customizable` | `rule` leaves a choice open | Apply `choice` | Nothing |
| `approved-substitution` | You would use `local` and `rule` applies | Use `substitute` instead, without asking | Nothing |
| `contested` | `rule` applies, and the codebase's way of meeting it is `local` | Use or keep `local` | The contested sentence, every time |
| `accepted-barrier` | `rule` applies to `local` (scope `component`) or to the code at `where` (scope `instance`) | Leave the barrier in place | The barrier sentence, every time |

A mapping never vouches for `local`. If `local` cannot meet the requirements it is held to, treat it as a broken component (section 2).

## 2. When to stay quiet and when to ask

Stay quiet when you:

- add something missing (a name, a role, a modifier, a semantics property) to code you were asked to write or change, or
- fix how a component is used, in that same code.

Most work ends there. **Ask first only when your fix would replace, bypass, or remove something that already exists in the codebase**: a design-system component, a shared helper, a wrapper. Apply that test to your own planned change. Do not weigh how important the change seems.

A component is broken, not misused, when nothing you can add from outside it makes it meet the requirement. Read its source to tell. If a modifier, parameter, or wrapper in your own code would fix it, it is misuse: fix it and stay quiet.

A helper that does the job a rule describes, but a different way than the pattern, is neither broken nor misused. Using it replaces nothing, so do not ask. Use it, and say once per change: "Used `<local>`. The pattern uses <the pattern's way> here instead, so say if you want it switched." If the person answers that their way is right, go to **On no** in section 3 and ask whether to make it permanent.

## 3. Asking, in order

**Before writing anything,** name the problem and your fix, and ask:

> `<Component>` <what is wrong inside it>, so it can't meet <requirement>, and nothing I add from outside changes that. For this <place> I'd use <fallback> directly. It meets <requirement> but won't match the design system's styling. Go ahead?

The fallback is the layer the component is built on: the Material 3 composable on Android, the SwiftUI native control on iOS, and on the web the native HTML element, or the pattern's Golden Pattern where no element exists.

**On yes,** write the code with the fallback, then:

> Done. The real fix is in `<file>`. I can make that change too, which touches shared design-system code; draft a note to the design-system owners; or leave it. Which?

Address a note only to the `owners:` named under the decisions file's header. If none is named, say the recipient is unknown. Never send anything yourself.

Then, unless the person chose to fix the component:

> Should I use <fallback> in place of `<Component>` from now on, without asking? Reply "Always" to record that in `.a11y-context/decisions.md`.

"Always" writes an `approved-substitution`.

**On no,** use the component as it is, then ask whether to make that permanent:

> Kept `<Component>`, so <the specific barrier> stays on this <place>. Should I do this every time it comes up, without asking? That records it in `.a11y-context/decisions.md`, where it stays visible in the repo.

- **No, or no answer:** record nothing. The same question comes up next time.
- **Yes:** ask why, in these plain words, and never ask the person to choose a kind:

  > Is that because the pattern is wrong here, or because it can't be fixed yet?

  - **The pattern is wrong here:** ask "What would settle it, and when should someone check? If nothing has been checked yet, that's fine to say." Write a `contested` entry, with `evidence` set to `none yet` if nothing has been checked. Suggest opening an issue at https://github.com/a11y-context/accessibility-pattern-api, since if the team is right, the pattern is wrong.
  - **It can't be fixed yet:** ask "Just this <place>, or every `<Component>`?" and write an `accepted-barrier` at that scope. Never offer anything wider than one component.
  - **An answer that says neither:** ask once more, offering the two reasons as written.

## 4. Offering the other entries

Offer each of these in one short question, and write only on a yes.

- **Mappings, once, at the end of a task.** If you used one of this codebase's components or helpers where a pattern or rule names a different one, and no mapping covers it, list them all in one question: "I used `<local>` where `<pattern or rule>` names `<X>`. Record these as mappings in `.a11y-context/decisions.md`, so I reach for them first next time?" A yes writes one `mapping` per item. Leave out any helper that does the job a different way than `<X>`: it got its sentence in section 2, and a mapping would say it does what `<X>` does.
- **A compliance claim, when the person says a component already meets a rule.** Read its source first. If you find the mechanism, offer: "Record that `<local>` meets <rule> through <mechanism> in `<file>`? I will check that file each time instead of asking." If you cannot find the mechanism, say so and do not offer.
- **A decided customizable, when the person or a requirement states a general choice for something a pattern leaves open.** Offer: "Record '<choice>' as this codebase's choice for <rule>?"

Approved substitutions, contested entries, and accepted barriers are offered only through the steps in section 3.

## 5. What you say when an entry applies

Say each sentence once per change, as written.

- **Accepted barrier:** "Kept `<local>` <its current state>, per an accepted barrier in `.a11y-context/decisions.md` from <date>."
- **Contested:** "Used `<local>`, per a contested entry in `.a11y-context/decisions.md` from <date>. The pattern says <pattern_says, shortened>; this settles on <settles_on>." Once `review_by` has passed, add: "Its review date, <review_by>, has passed." Do not start fixing because the date passed.
- **Compliance claim whose mechanism is gone:** "The <date> claim says `<local>` meets <rule> through <mechanism> in `<file>`, which is no longer there. Checking it as usual."

## 6. Writing an entry

- Write only after an explicit yes in chat. Never on your own initiative.
- If `.a11y-context/decisions.md` does not exist, create it starting with this header, verbatim:

```markdown
# Accessibility decisions for this codebase

Read by the A11y Context skill (https://a11y-context-project.vercel.app) before it applies
accessibility patterns to generated code. Each entry records a decision a person made in chat:
which of this codebase's components and helpers stand in for the ones the patterns name, which
rules a component already meets, which open choices the team settled, which components to
replace because they cannot meet a rule, where the team does something differently from the
patterns on purpose and what evidence would settle it, and which accessibility barriers the
team has knowingly kept. The skill never writes here on its own; it asks first. One entry per
decision; edits replace in place; git holds the history.
```

- Six sections, in this order, each holding one `yaml` block per entry: `## Mappings`, `## Compliance claims`, `## Decided customizables`, `## Approved substitutions`, `## Contested`, `## Accepted barriers`.
- Every entry carries `kind`, `date` (ISO), `decided_by`, and `platform` (`all` unless the person says otherwise). Every kind except `mapping` also carries `reason`: the person's own words, quoted.
- Fields by kind:
  - `mapping`: `stack`; `pattern` or `rule`; `api` when it maps a rule's API; `local`
  - `compliance-claim`: `rule`, `local`, `mechanism`, `file`, optional `evidence`
  - `decided-customizable`: `rule`, `choice`, optional `evidence`
  - `approved-substitution`: `rule`, `local`, `substitute`
  - `contested`: `rule`, `local`, `codebase_does`, `pattern_says`, `evidence` (or `none yet`), `settles_on`, `review_by`
  - `accepted-barrier`: `scope` (`instance` or `component`), `rule`, `where` (instance) or `local` (component), `proposed`, `decided`
- **Replace, do not append.** A mapping is keyed on `local`. A decided customizable is keyed on `rule` and `platform`. The other four share one key, `rule` plus `local` (or `where`): writing one of them removes any of the other three under the same key.
- To change or remove a decision when asked, edit or delete its block. Never add a second entry that contradicts the first.
- Write with the client's normal file edit, so the person sees the diff. If you cannot edit files, show the block and ask the person to add it.

Example:

```yaml
kind: accepted-barrier
date: 2026-10-07
scope: component
rule: global.touch-target-size
local: com.example.design.BrandChip
proposed: Replace BrandChip with Material FilterChip, which meets the 48dp target.
decided: Keep BrandChip at 40dp.
decided_by: sam.ortiz
platform: all
reason: "The design system team is resizing BrandChip in its next release."
```

## 7. Requirements

- If the request names a ticket or requirements document and you can read it, read it before selecting patterns.
- If the request is to build a new screen or feature and names none, ask once per session: "Is there a ticket or requirements doc for this? Any accessibility requirements in it would shape the work." Do not ask for small changes or bug fixes.
- Where a requirement settles a choice a pattern leaves open (its Customizable section), follow the requirement. If the requirement states it as a general rule, offer to record it as a `decided-customizable`, with the ticket as `evidence`.
- Where a requirement contradicts a Must Have or a Don't, ask every time: "The ticket asks for <X>. The pattern requires <Y>, because <Z>. Follow the ticket or the pattern?" Following the ticket goes through the gate in section 3, with the ticket as `evidence`.

## 8. Never

- Never write an entry without a yes.
- Never offer an accepted barrier wider than one component.
- Never sweep the codebase because of an entry. Entries apply to work you were asked to do.
- Never let an entry silence the sentence for an accepted barrier or a contested entry.
- Never ask the person to choose between "barrier" and "contested." Those are names for the file. Ask why, in plain words.
- Never edit shared design-system code, or send a message, unless the person asks.
