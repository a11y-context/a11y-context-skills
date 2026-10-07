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
- **People can also write entries by hand**, for example to seed the file from a helper table the team already maintains. The skill reads them the same way. Rule 1 below governs what the skill writes, not what people write.

### Header

The file opens with this text, verbatim, so an engineer who finds it without knowing A11y Context can tell what it is:

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

An optional `owners:` line may follow, naming who answers for the design system (a team handle, or a path into `CODEOWNERS`). When it is present the skill can address a note to them. When it is absent the skill never guesses a recipient.

### Format

Six `##` sections, one per entry kind, in the order of the table below. Each entry is one fenced `yaml` block. YAML because the skill matches entries by field; one block per entry so a pull request shows exactly which decision changed.

## Entry kinds

| Kind | It says | What the person is asked | Effect when it matches |
|---|---|---|---|
| `mapping` | "Where the corpus names X, this codebase uses Y." X is a pattern's component, or an API a rule names | Once, batched at the end of a task: record Y as your version of X? | The skill uses Y in place of X, and X's requirements still apply to Y |
| `compliance-claim` | "Component Y already meets rule R, through mechanism M in file F" | The gate | The skill re-reads F; if M is there it skips R on Y silently, and if not it says so and checks R as usual |
| `decided-customizable` | "Where rule R leaves a choice open, this codebase chose C" | The gate | The skill applies C instead of asking or guessing |
| `approved-substitution` | "Component Y cannot meet rule R; use framework component Z instead, without asking" | The gate | The skill uses Z and does not ask again |
| `contested` | "We do R differently on purpose, the pattern may be wrong for us, and this would settle it" | Every time? Then why, then what would settle it | The skill keeps the codebase's way, says so every time, and says when the review date has passed |
| `accepted-barrier` | "Rule R is unmet here and we are leaving it, because..." | Every time? Then why, then the scope | The skill does not apply the fix at that scope, and says so every time |

"The gate" means the skill states, in one sentence, exactly what will stop being checked or asked, and writes the entry only on a yes.

**A contested entry and an accepted barrier differ in who thinks the rule is right.** An accepted barrier agrees the pattern is right and keeps the barrier for a stated reason, usually time. A contested entry records that the team believes the pattern is wrong for this codebase, whatever evidence it has (which may be none yet), and what would settle the question. Recording a team's tested convention as a barrier would misstate what the team believes, and would ask them to call their own work wrong before any evidence says so. The engineer never has to name either kind: the skill asks why, in plain words, and the answer decides.

### Fields

Every entry carries `kind`, `date` (ISO), `decided_by`, and `platform` (`all` unless stated; otherwise a form factor such as `phone`, or a named platform). Every kind except `mapping` also carries `reason`: the person's own words, quoted, because six months later it is the one thing a reviewer cannot reconstruct.

`local` always names this codebase's own thing: a component, a helper, or a wrapper.

| Kind | Its own fields |
|---|---|
| `mapping` | `stack`; `pattern` or `rule`; `api` when it maps a rule's API; `local` |
| `compliance-claim` | `rule`, `local`, `mechanism`, `file`, optional `evidence` |
| `decided-customizable` | `rule`, `choice` (a plain sentence), optional `evidence` |
| `approved-substitution` | `rule`, `local`, `substitute` |
| `contested` | `rule`, `local`, `codebase_does` and `pattern_says` (plain sentences), `evidence` (or `none yet`), `settles_on`, `review_by` |
| `accepted-barrier` | `scope` (`instance` or `component`), `rule`, `where` (instance) or `local` (component), `proposed`, `decided` |

**Keys, which decide what a new entry replaces.** A mapping is keyed on `local`. A decided customizable is keyed on `rule` and `platform`. The other four are four different answers to one question, "what does this codebase do about rule R on this thing," so they share one key, `rule` plus `local` (or `where`), and a codebase holds at most one of them per key. Recording a substitution for `BrandChip` replaces an accepted barrier on `BrandChip` under the same rule, and so on.

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
local: com.example.design.BrandCheckbox
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
local: com.example.design.BrandChip
substitute: androidx.compose.material3.FilterChip
decided_by: jordan.lee
platform: all
reason: "BrandChip is 40dp tall until the design system's next release."
```

```yaml
kind: contested
date: 2026-10-07
rule: global.announcements
local: com.example.a11y.announce()
codebase_does: Announces loading states by dispatching an announcement event.
pattern_says: Use a polite live region, and do not dispatch announcement events.
evidence: "On our TV builds, live regions on newly opened screens were dropped or read twice (QA-412)."
settles_on: A TalkBack check on a phone running Android 16, comparing a live region with the announcement event.
review_by: 2026-11-15
decided_by: jordan.lee
platform: all
reason: "The helper is what QA verified. We will switch if the phone check favors live regions."
```

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
reason: "The design system team is resizing BrandChip in its next release; tracked in DS-88."
```

The substitution and the barrier are two answers to the same question about `BrandChip`, so a codebase holds one or the other, never both. The contested example is the honest record of a common situation: the convention runs on every platform (`platform: all`), the evidence behind it came from one, and `settles_on` names the check that would extend or overturn it.

## Rules that bound the file

1. **An entry is written only after a person answers in chat.** Never on the skill's own initiative, and never because something seemed important enough. The person's answer is the only trigger, which is what keeps the file short.
2. **One live entry per key.** A new decision on the same key replaces the old one in place. "Remove the `BrandChip` decision" deletes the entry. The file holds current truth; git holds the history.
3. **Forward-only.** An entry applies the next time the skill meets that component in work it was asked to do. Recording a decision never triggers a sweep of the codebase. A sweep is a separate request, in plain words.
4. **An accepted barrier is never rule-wide.** Instance or component, nothing broader. The skill does not offer a wider scope. A team that wants a rule off across a codebase edits the file by hand, in a commit someone reviews.
5. **Platform truth goes upstream.** If a decision is about how a platform behaves rather than how this codebase is built (a TV screen reader that ignores pane titles, say), it belongs in the corpus, scoped to that platform, so every adopting team inherits it. Until the corpus catches up, the file holds it as a `contested` entry with its evidence, and the skill suggests opening an issue on the corpus repository. When the question settles, either the corpus changes or the codebase does, and the entry is removed.
6. **Only an accepted barrier or a contested entry leaves a Must Have unmet or a Don't broken**, and both are always spoken. A mapping, a compliance claim, and a substitution change how a requirement is met. A decided customizable fills only what the corpus leaves open.

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

**On no**, it uses `BrandCheckbox` as it is, then asks whether to make that permanent:

> Kept `BrandCheckbox`, so the 36dp touch target stays on this checkbox. Should I do this every time it comes up, without asking? That records it in `.a11y-context/decisions.md`, where it stays visible in the repo.

- **No, or no answer**, records nothing, and the same question comes up next time.
- **Yes** gets one follow-up, in plain words: "Is that because the pattern is wrong here, or because it can't be fixed yet?"
  - **The pattern is wrong here:** the skill asks what would settle it and when someone should check, writes a `contested` entry, and suggests opening an issue on the corpus repository, since if the team is right, the pattern is wrong. If nothing has been checked, `evidence` is `none yet`, and the review date is what makes sure the check happens.
  - **It can't be fixed yet:** the skill asks the scope, "Just this checkbox, or every `BrandCheckbox`?", and writes an `accepted-barrier`.

**Why permanence comes first.** An earlier draft asked the engineer to reply "barrier" or "contested." That was the file's vocabulary, not the engineer's decision. In a human check, the case where an engineer disputes the pattern without having checked got neither label; it got the question "should it do this every time?" Permanence is the decision being made, so the skill asks it first, asks why only when something is about to be recorded, and keeps the kind names inside the file. The common path, a one-off refusal, still costs one question.

**When an accepted barrier matches later,** the skill does not apply the fix and says, once per change:

> Kept `BrandCheckbox` at 36dp, per an accepted barrier in `.a11y-context/decisions.md` from 2026-10-07.

**When a contested entry matches later,** the skill keeps the codebase's way and says, once per change:

> Used `announce()`, per a contested entry in `.a11y-context/decisions.md` from 2026-10-07. The pattern says to use a live region; this settles on a TalkBack check on a phone running Android 16.

Once `review_by` has passed, it adds: "Its review date, 2026-11-15, has passed." It does not start fixing on its own when the date passes. A deadline that silently flipped the skill's behavior would surprise the people who set it.

The fix can be turned off. The sentence cannot.

**When a compliance claim matches,** the skill reads the file the claim names. If the mechanism is there, it skips that rule on that component without comment. If it is gone:

> The 2026-10-07 claim says `BrandCheckbox` meets the touch target through `minimumInteractiveComponentSize()` in `BrandCheckbox.kt`, which is no longer there. Checking it as usual.

That catches the common way claims go stale, a refactor. It does not catch a regression with the call still present, and nothing static will.

### Offering the other entries

Three kinds are offered outside the step-two flow, each in one short question:

- **Mappings, once, at the end of a task.** If the skill used a codebase component or helper where a pattern or rule names a different one, and no mapping covers it, it lists them all in one question. Asking per component, mid-task, would be the noise this design exists to avoid.
- **A compliance claim, only when a person says a component already meets a rule**, and only after the skill finds the mechanism in the component's source. If it cannot find it, it says so and does not offer.
- **A decided customizable, when a person or a requirement states a general choice** for something a pattern leaves open.

Approved substitutions, contested entries, and accepted barriers come only from the step-two flow above.

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
- **Each `SKILL.md` gains a Step 0**: read `${CLAUDE_SKILL_DIR}/decisions-protocol.md` and follow it on every task. The protocol is read whether or not the codebase has a decisions file yet, because its asking rules apply either way. The rag variant's existing Step 0 reads its retrieval config; the protocol read becomes the second half of that step.
- **Two guardrails change.** The Communication guardrail told the agent to surface process details only on failure, which would have suppressed the protocol's messages and the scope check's, so it now lets them through. The design-system guardrail said "preserve it," which read literally rules out substituting a component even on a yes, so it now says replacing one goes through the protocol.

**No variant gains Edit.** Writing an entry goes through the client's normal file-edit permission, so the engineer sees the exact diff a second time before it lands. A client that cannot edit files shows the entry as a block and asks the engineer to add it by hand. It never skips the gate. The mcp variants gain Read, which they had no need for before and now need to open the protocol and the decisions file.

## Rollout

1. **This note.** Reviewed and agreed before anything below moves.
2. **The scope check.** Separate from the rest and needed first.
3. **The protocol, in full, on an unmerged branch.** `decisions-protocol.md` with all six kinds, the copy script and its check, and the Step 0 read in all 12 `SKILL.md` files. The evaluation runs against this branch, so nothing reaches anyone who installs the skill until it passes.
4. **An evaluation**, before the asking and the gate ship. Without engineered wording, agents in this project's evaluation consulted the corpus only 13 to 53 percent of the time, and there is no reason to expect a gate does better untested. Cases:
   - Asks before replacing a design-system component; stays silent when adding or fixing usage.
   - Classifies "fixable from outside" against "broken inside" correctly. This is the case that decides whether the skill is useful or annoying.
   - On a refusal, keeps the engineer's way and asks whether to do it every time; asks why only on a yes; never asks the engineer to choose "barrier" or "contested"; then asks the scope or the settling check that follows from the reason.
   - Writes entries in the right shape, under the right key, replacing rather than appending.
   - Suppresses on the next run, and still says the sentence; for a contested entry, adds the review-date line once it has passed.
   - Re-reads a compliance claim's file and catches a missing mechanism.
   - Applies a mapping and a decided customizable.
   - Stops at the scope check for TV code, applies with one line for shared code.
5. **Merge**, once the evaluation passes. If it shows the asking or the gate are unreliable, a mappings-only cut of the protocol can merge first, since mappings are the lowest-risk kind and prove the read path.

## Open questions

- **Who may confirm a compliance claim.** Anyone in the chat, or only the owners named in the header. One option is a `CODEOWNERS` entry for `.a11y-context/`, which makes the pull request the real gate.
- **Other Apple platforms.** The iOS corpus covers iPhone and iPad. macOS, watchOS, and visionOS raise the same question as tvOS and are not in the scope check yet.
- **Connected-TV web apps that provide their own speech.** Some TV web apps speak through the platform's speech synthesis from their own code rather than relying on a screen reader that reads the accessibility tree. Web patterns that assume an external screen reader do not fit them. The scope check stops for these apps today; whether they need their own stack is open.
