# Decisions layer

*Design note, proposed October 2026. Not built yet. When a part of it ships, the `SKILL.md` text for that part is canonical and this note records why it works the way it does.*

## What this adds

The A11y Context corpus is general on purpose. It names no company and no design system. The codebases it runs in are not general. They wrap Material in their own `BrandCheckbox`, settle choices the corpus leaves open, and sometimes keep a known barrier for a reason a person can state. Today the skill has nowhere to learn any of that, so it either fights the codebase or follows it into a barrier.

This note adds three things, all on the skill side:

1. **A decisions file**, `.a11y-context/decisions.md`, committed at the root of the consuming repository. It records what people in that codebase decided.
2. **A protocol** the skill follows: when it reads the file, when it asks before changing something, and how a person's answer becomes an entry.
3. **A scope check** that stops the skill from applying a stack's patterns to a form factor the corpus does not cover.

The corpus does not change. Design-system knowledge stays out of it.

## Where the layer sits

| Layer | Example | Correct by default? | Where its knowledge lives |
|---|---|---|---|
| Platform primitives | HTML elements, Compose Foundation | The elements are; compositions are not | The corpus |
| Framework components | Material 3 composables, SwiftUI controls | Mostly, within documented limits | The corpus, as the reference implementation |
| Company design system | `BrandCheckbox` | Unknown | The decisions file |

On the web the middle layer is thin. The browser ships a dozen correct elements and nothing like a tab set or a bottom sheet, so the corpus's Golden Patterns are the reference. On Android and iOS the middle layer is thick, so the corpus mostly protects compositions the framework already gets right. The decisions file works the same way on every stack.

## The file

### Location and lifecycle

`.a11y-context/decisions.md` at the repository root.

- **Not inside the skill's folder.** Installing a new version of the skill replaces its folder, and anything stored there with it.
- **Committed.** Every engineer's agent in the repository reads the same decisions, and every entry shows up in a pull request where someone can review it.
- **Created by the skill on the first entry a person confirms**, with the header below. Nothing creates it ahead of time, and the skill never creates an empty one.

### Header

The file opens with this text, verbatim, so an engineer who finds it without knowing A11y Context can tell what it is:

```markdown
# Accessibility decisions for this codebase

Read by the A11y Context skill (https://a11y-context-project.vercel.app) before it applies
accessibility patterns to generated code. Each entry records a decision a person made in chat:
which of this codebase's components and helpers stand in for the ones the patterns name, which
rules a component already meets, which open choices the team settled, which components to
replace because they cannot meet a rule, and which accessibility barriers the team has
knowingly kept. The skill never writes here on its own; it asks first. One entry per decision;
edits replace in place; git holds the history.
```

An optional `owners:` line may follow, naming who answers for the design system (a team handle, or a path into `CODEOWNERS`). When it is present the skill can address a note to them. When it is absent the skill never guesses a recipient.

### Format

Five `##` sections, one per entry kind, in the order of the table below. Each entry is one fenced `yaml` block. YAML because the skill matches entries by field; one block per entry so a pull request shows exactly which decision changed.

## Entry kinds

| Kind | It says | What the person is asked | Effect when it matches |
|---|---|---|---|
| `mapping` | "Where the corpus names X, this codebase uses Y." X is a pattern's component, or an API a rule names | Once: is Y your version of X? | The skill uses Y in place of X, and X's requirements still apply to Y |
| `compliance-claim` | "Component Y already meets rule R, through mechanism M in file F" | The gate | The skill re-reads F; if M is there it skips R on Y silently, and if not it says so and checks R as usual |
| `decided-customizable` | "Where rule R leaves a choice open, this codebase chose C" | The gate | The skill applies C instead of asking or guessing |
| `approved-substitution` | "Component Y cannot meet rule R; use framework component Z instead, without asking" | The gate | The skill uses Z and does not ask again |
| `accepted-barrier` | "Rule R is unmet here and we are leaving it, because..." | The gate, plus a scope question | The skill does not apply the fix at that scope, and says so every time |

"The gate" means the skill states, in one sentence, exactly what will stop being checked or asked, and writes the entry only on a yes.

### Fields

Every entry carries `kind`, `date` (ISO), `decided_by`, and `platform` (`all` unless stated; otherwise a form factor such as `phone`, or a named platform). Every kind except `mapping` also carries `reason`: the person's own words, quoted, because six months later it is the one thing a reviewer cannot reconstruct.

| Kind | Its own fields | Key (one live entry per key) |
|---|---|---|
| `mapping` | `stack`; `pattern` or `rule`; `api` when it maps a rule's API; `local` | `local` |
| `compliance-claim` | `rule`, `component`, `mechanism`, `file`, optional `evidence` | `rule` + `component` + `platform` |
| `decided-customizable` | `rule`, `choice` (a plain sentence), optional `evidence` | `rule` + `platform` |
| `approved-substitution` | `rule`, `component`, `substitute` | `rule` + `component` |
| `accepted-barrier` | `scope` (`instance` or `component`), `rule`, `where` (instance) or `component`, `proposed`, `decided` | `rule` + `where` or `component` |

`evidence` takes an issue key, a link, or the device and screen reader something was verified on. `proposed` and `decided` are the skill's plain sentences, so someone who was not there can read what the skill wanted to do and what the team decided instead.

**A mapping never vouches for what it maps to.** It changes which name the skill writes, not what the result must do. If the skill reads `Y` and finds it cannot meet the requirements `X` carries, that is the broken-component case below, and the skill asks.

### Examples

```yaml
kind: mapping
date: 2026-10-07
stack: android/compose
pattern: checkbox.basic
local: com.example.design.BrandCheckbox
decided_by: jordan.lee
platform: all
```

```yaml
kind: mapping
date: 2026-10-07
stack: android/compose
rule: global.traversal-order
api: Modifier.semantics { isTraversalGroup = true }
local: com.example.a11y.traversalGroup()
decided_by: jordan.lee
platform: all
```

```yaml
kind: compliance-claim
date: 2026-10-07
rule: global.touch-target-size
component: com.example.design.BrandCheckbox
mechanism: Modifier.minimumInteractiveComponentSize() on the row that owns toggleable
file: design/src/main/java/com/example/design/BrandCheckbox.kt
evidence: "Checked with TalkBack on a Pixel 8, Android 16"
decided_by: jordan.lee
platform: all
reason: "The wrapper sizes its own row, so callers cannot get this wrong."
```

```yaml
kind: decided-customizable
date: 2026-10-07
rule: global.screen-announcement
choice: When a screen opens, screen-reader focus lands on the screen's title.
evidence: ACCESS-123
decided_by: sam.ortiz
platform: all
reason: "One rule for every screen, so users always know where they start."
```

```yaml
kind: approved-substitution
date: 2026-10-07
rule: global.touch-target-size
component: com.example.design.BrandChip
substitute: androidx.compose.material3.FilterChip
decided_by: jordan.lee
platform: all
reason: "BrandChip is 40dp tall until the design system's next release."
```

```yaml
kind: accepted-barrier
date: 2026-10-07
scope: component
rule: global.touch-target-size
component: com.example.design.BrandChip
proposed: Replace BrandChip with Material FilterChip, which meets the 48dp target.
decided: Keep BrandChip at 40dp.
decided_by: sam.ortiz
platform: all
reason: "The design system team is resizing BrandChip in its next release; tracked in DS-88."
```

The last two are the two possible answers to the same question about `BrandChip`. A codebase holds one or the other, never both, which the key enforces.

## Rules that bound the file

1. **An entry is written only after a person answers in chat.** Never on the skill's own initiative, and never because something seemed important enough. The person's answer is the only trigger, which is what keeps the file short.
2. **One live entry per key.** A new decision on the same key replaces the old one in place. "Remove the `BrandChip` decision" deletes the entry. The file holds current truth; git holds the history.
3. **Forward-only.** An entry applies the next time the skill meets that component in work it was asked to do. Recording a decision never triggers a sweep of the codebase. A sweep is a separate request, in plain words.
4. **An accepted barrier is never rule-wide.** Instance or component, nothing broader. The skill does not offer a wider scope. A team that wants a rule off across a codebase edits the file by hand, in a commit someone reviews.
5. **Platform truth goes upstream.** If a decision is about how a platform behaves rather than how this codebase is built (a TV screen reader that ignores pane titles, say), it belongs in the corpus, scoped to that platform, so every adopting team inherits it. The file holds a `compliance-claim` pointing at the local workaround until the corpus catches up, and the skill suggests opening an issue on the corpus repository.
6. **Only an accepted barrier leaves a Must Have unmet**, and it is always spoken. A mapping, a compliance claim, and a substitution change how a Must Have is met. A decided customizable fills only what the corpus leaves open.

## What the skill does

### Reading the file

After the scope check and before selecting patterns, the skill reads `.a11y-context/decisions.md` if it exists. If it does not exist, the skill carries on exactly as today. If an entry is malformed, the skill ignores that entry, says once which one, and carries on. A broken entry never suppresses a fix.

Matching uses the key fields and nothing else. Where it is unclear whether an entry applies, it does not.

### Applying a pattern: when to stay quiet and when to ask

**Most fixes are silent.** Adding what is missing (a name, a modifier, a semantics property) to code the skill was asked to write or change needs no comment. Fixing how a design-system component is used, in that same code, needs none either. Most work ends here.

**The skill asks first only when the fix would replace, bypass, or remove something that already exists**: a design-system component, a shared helper, a wrapper someone built on purpose. That test is mechanical. The skill applies it to its own planned diff and does not weigh how important the change seems. A skill that asks for permission constantly has misread the cases above as this one.

The worked case. The task is a "Remember me" checkbox. The codebase's `BrandCheckbox` fixes its row at 36dp internally, so nothing the skill adds from outside can meet the 48dp target.

**Before writing anything:**

> `BrandCheckbox` fixes its row at 36dp, so it can't meet the 48dp touch target this pattern requires, and nothing I add from outside changes that. For this row I'd use Material's `Checkbox` directly. It meets the target but won't match the design system's styling. Go ahead?

**On yes**, it writes the code with the framework component, then:

> Done. The real fix is in `design/.../BrandCheckbox.kt`. I can make that change too, which touches shared design-system code; draft a note to the design-system owners; or leave it. Which?

Then, unless the person chose to fix the component itself:

> Should I use Material's `Checkbox` in place of `BrandCheckbox` from now on, without asking? Reply "Always" to record that in `.a11y-context/decisions.md`.

"Always" writes an `approved-substitution`.

**On no**, it uses `BrandCheckbox` as it is, then offers the gate:

> That leaves a 36dp touch target on this checkbox. Record it as an accepted barrier in `.a11y-context/decisions.md`? It will be visible in the repo, and I will mention it each time it applies. Just this checkbox, or every `BrandCheckbox`?

A yes writes an `accepted-barrier` at the scope chosen. A no records nothing, and the same question comes up next time.

**When an accepted barrier matches later,** the skill does not apply the fix and says, once per change:

> Kept `BrandCheckbox` at 36dp, per an accepted barrier in `.a11y-context/decisions.md` from 2026-10-07.

The fix can be turned off. The sentence cannot.

**When a compliance claim matches,** the skill reads the file the claim names. If the mechanism is there, it skips that rule on that component without comment. If it is gone:

> The 2026-10-07 claim says `BrandCheckbox` meets the touch target through `minimumInteractiveComponentSize()` in `BrandCheckbox.kt`, which is no longer there. Checking it as usual.

That catches the common way claims go stale, a refactor. It does not catch a regression with the call still present, and nothing static will.

### What it falls back to

When the skill bypasses a design-system component, it falls back to the layer that component is built on:

| Stack | Fallback |
|---|---|
| `android/compose` | The Material 3 composable |
| `ios/swiftui` | The SwiftUI native control |
| `web/react` | The native HTML element where one exists, otherwise the corpus pattern's Golden Pattern |

### Requirements

Requirements direct the work. The patterns govern how it is built.

- **If the request names a ticket or requirements document and the skill can read it, it reads it before selecting patterns.** The skill does not ask for access to anything. Whether it can read a ticket depends on the client and its connectors.
- **If the request is to build a new screen or feature and names no requirements, the skill asks once per session:** "Is there a ticket or requirements doc for this? Any accessibility requirements in it would shape the work." It does not ask for small changes or bug fixes.
- **A requirement that settles something a pattern leaves open wins, without comment.** If the requirement itself states the choice as a general rule ("on every screen"), the skill offers to record it as a `decided-customizable`, with the ticket as `evidence`.
- **A requirement that contradicts a Must Have is asked about, every time:** "The ticket asks for X. The pattern requires Y, because Z. Follow the ticket or the pattern?" Following the ticket goes through the accepted-barrier gate, with the ticket as `evidence`.

Whether a conflict is with a Must Have or a Customizable is a structural fact about the pattern, so the skill never has to judge how serious a conflict is.

## Scope check

Each stack's corpus covers specific form factors and none of the skill files said so. The skill's description fires on any UI in its framework, so an agent fixing a TV bug was handed phone guidance that can contradict tested TV fixes. The scope check runs before every other step.

**It runs per file**, since one task can touch both. For each file the skill will change:

- **The file targets a form factor the corpus does not cover:** the skill does not retrieve or apply patterns to it, and says so once, naming what it did instead (the codebase's existing conventions).
- **The file is shared with a build the corpus does not cover:** the skill applies patterns as usual and adds one line saying the change also ships to that build and was not checked against it.
- **Otherwise:** it carries on with the steps below.

**Why stop, not warn and carry on.** The TV contradictions found so far are of the kind an agent would "fix" in the wrong direction, for example replacing a live region a TV team added on purpose with the pane title the phone corpus requires. A warning would be the only thing between the agent and that regression.

| Stack | Covers | Stops for | Signals, any one of which is enough |
|---|---|---|---|
| `android/compose` | Phones and tablets | Android TV, Google TV, Fire TV | Imports from `androidx.tv.*` or `androidx.leanback.*`; a manifest declaring `android.software.leanback` or a `LEANBACK_LAUNCHER` category; a module or source set that exists for the TV build (`compose-tv`, `ui-tv`, `app-tv`, `firetv`, a `tv` source set); a request naming a TV, a remote, or the D-pad |
| `ios/swiftui` | iPhone and iPad | Apple TV | `#if os(tvOS)`; a target built for the `appletvos` SDK; imports of `TVUIKit` or `TVServices`; a request naming Apple TV, tvOS, or the Siri Remote |
| `web/react` | Browser apps on desktop, laptop, tablet, and phone | Connected TVs | A file, app, or package named for a TV platform (`tizen`, `webos`, `vizio`, `hisense`, `ctv`, `smart-tv`); TV platform globals (`tizen`, `webOS`, `PalmSystem`) or remote-key registration; a spatial-navigation library for remote input; a request naming a TV, a TV platform, a remote, or the 10-foot experience |

Two refinements:

- **A phone feature named for live TV or a TV guide is not a TV signal.** Path signals look for modules that exist for the TV build, not for the word.
- **Chromecast.** A Cast receiver (`cast.framework.CastReceiverContext`, or a page loading the Cast receiver framework) runs on the TV, so it counts as a connected-TV signal unless the surrounding code clearly says otherwise. A Cast sender is never a signal on its own: it is part of whatever app it lives in, which the other signals decide.

## Packaging

**Each variant ships as its own zip of its own folder**, so a file at the repository root reaches no one. The corpus repository's download generator walks `skills/<stack>/<variant>/` and zips each one. That decides two things.

- **The protocol text lives once and is copied into every variant.** Its source is `shared/decisions-protocol.md`. A script copies it into all 12 variant folders, and a check fails if any copy differs. This is how `global_rules.md` already reaches the local and http variants.
- **Each `SKILL.md` gains one line at the start of its steps**: read `${CLAUDE_SKILL_DIR}/decisions-protocol.md`, then the codebase's `.a11y-context/decisions.md`. The rag variant's existing Step 0 reads its retrieval config; the decisions read becomes the second half of that step.

**No variant's `allowed-tools` changes.** Writing an entry goes through the client's normal file-edit permission, so the engineer sees the exact diff a second time before it lands. A client that cannot edit files shows the entry as a block and asks the engineer to add it by hand. It never skips the gate.

## Rollout

1. **This note.** Reviewed and agreed before anything below moves.
2. **The scope check.** Separate from the rest and needed first.
3. **The protocol, mappings only.** `decisions-protocol.md`, the copy script and its check, the one-line read in all 12 `SKILL.md` files. Mappings are the lowest-risk kind and prove the read path.
4. **An evaluation**, before the asking and the gate ship. Without engineered wording, agents in this project's evaluation consulted the corpus only 13 to 53 percent of the time, and there is no reason to expect a gate does better untested. Cases:
   - Asks before replacing a design-system component; stays silent when adding or fixing usage.
   - Classifies "fixable from outside" against "broken inside" correctly. This is the case that decides whether the skill is useful or annoying.
   - Opens the gate on a refusal and asks the scope question.
   - Writes entries in the right shape, under the right key, replacing rather than appending.
   - Suppresses on the next run, and still says the sentence.
   - Re-reads a compliance claim's file and catches a missing mechanism.
   - Applies a mapping and a decided customizable.
   - Stops at the scope check for TV code, applies with one line for shared code.
5. **Compliance claims, substitutions, barriers, and the asking**, once the evaluation passes.

## Open questions

- **Who may confirm a compliance claim.** Anyone in the chat, or only the owners named in the header. One option is a `CODEOWNERS` entry for `.a11y-context/`, which makes the pull request the real gate.
- **Other Apple platforms.** The iOS corpus covers iPhone and iPad. macOS, watchOS, and visionOS raise the same question as tvOS and are not in the scope check yet.
- **Connected-TV web apps that provide their own speech.** Some TV web apps speak through the platform's speech synthesis from their own code rather than relying on a screen reader that reads the accessibility tree. Web patterns that assume an external screen reader do not fit them. The scope check stops for these apps today; whether they need their own stack is open.
