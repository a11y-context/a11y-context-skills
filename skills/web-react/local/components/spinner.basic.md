---
id: spinner.basic
title: Spinner
stack: web/react
status: beta
latest_version: 0.1.0
tags: [spinner, loading, busy, status, live-region, reduced-motion]
aliases: [spinner, loading spinner, loading indicator, busy indicator, activity indicator, throbber, loader, button loading state]
summary: Indeterminate loading glyph that carries no semantics of its own, where the graphic is decorative and the control or region hosting it reports the wait through aria-busy and a separate live region.
---

# Spinner

Pattern ID: `spinner.basic`

Indeterminate loading glyph that carries no semantics of its own. The graphic is decorative, and the control or region hosting it reports the wait through `aria-busy` and a separate live region.

A spinner decorates something that already has a label, such as a button, a panel, or a table, and it has no label of its own. That is what separates it from `progress-bar.basic`, which is itself the labeled indicator for a piece of work. Shape does not decide it: a spinner inside a Save button and a spinner filling a panel are both this pattern, and a labeled ring reporting a sync is not.

## Use When
- Use when a control the user activated stays busy long enough that the user would otherwise wonder whether it worked, and the wait has no knowable end point (e.g., a Save button submitting, a Sign in button authenticating).
- Use when a region is fetching or replacing its content with no knowable end point, and the region keeps its place in the layout (e.g., a results panel reloading after a filter change).
- Use when the button or region the indicator sits in already names what is loading, so the indicator itself needs no label.

## Do Not Use When
- Do not use when the process reports how far it has advanced toward a known end point (use `progress-bar.basic`).
- Do not use when the indicator has its own label naming the work and its own place in the layout, whether or not it reports a value, such as a labeled bar beneath "Uploading episode files" or a labeled ring for a sync that is running (use `progress-bar.basic`).
- Do not use when grey shapes stand in for the layout of the content itself, such as bars where lines of text will appear and a block where an image will load (use `skeleton.basic`).
- Do not use when several regions of one view would each show their own spinner at the same time (use `skeleton.basic`).
- Do not use when the message reports the outcome of finished work rather than work still in progress (use `toast.basic`).

## Must Haves

### Roles & structure
- The graphic that draws the spinner has `aria-hidden="true"`, no `role`, no `aria-label`, and no text content.
- The loading state is carried by the host, meaning the control or region the spinner sits inside, together with a live region holding the text that describes the wait.
- When a region is fetching or replacing its content, that region has `aria-busy="true"` for the duration, and the attribute is removed or set to `"false"` once the content arrives.
- The spinner is not focusable and is not in the page tab sequence.

### Accessible name
- The spinner contributes nothing to the accessible name of its host. Adding the graphic does not change what the host control or region is called.
- The host names what is loading: a control through its own label, and a region through its heading referenced by `aria-labelledby`, or through `aria-label`.
- When the host's visible label changes while busy (e.g., "Save" becomes "Saving"), the changed text is the host's accessible name.

### State & properties
- A live region is present in the DOM before the spinner appears, and receives text describing the wait. Use `role="status"`, or an equivalent such as `aria-live="polite"` and `aria-atomic="true"`.
  - The text begins with a status word: "Loading" for a region fetching content, or the progressive form of a control's own label for a control ("Save" becomes "Saving").
  - When the button or region has a short accessible name, append it, taking the words from that existing name rather than authoring new ones (e.g., a panel named "Recommendations" gives "Loading recommendations"). "Loading" on its own is correct when there is no short name to borrow.
- The live region receives a message when the wait ends, on success and on failure alike.
  - The end message reuses the words of the start message in completed form (e.g., "Loading recommendations" becomes "Recommendations loaded").
- The live region text is removed once it is no longer current, so a stale message is not discoverable later by a user browsing the page.
- A control that becomes busy after activation uses `aria-disabled="true"` rather than the native `disabled` attribute, so the control keeps keyboard focus for the duration of the wait.
  - The activation handler returns early while the control is busy, since `aria-disabled` does not block activation on its own.

### Motion & timing
- Under `prefers-reduced-motion: reduce`, the animated graphic is not shown, and visible text stating what is happening is rendered in its place.
  - The host's own visible label satisfies this when it already changes while busy.
- The spinner is removed when the wait ends, and a failed wait is replaced by an error message rather than a graphic that spins indefinitely.

## Customizable
- Delay before the spinner appears. A short delay keeps fast responses from flashing a graphic the user cannot read; 100ms is a common threshold, and some systems show a spinner only when the expected wait exceeds 3 seconds. The threshold is at the engineer's discretion as long as the live region is not populated for waits the user never perceives.
- Whether the host's visible label changes while busy. Leaving "Save" in place and swapping it for "Saving" are both acceptable; when it changes, the new text becomes the accessible name.
- Which element hosts the live region. A dedicated visually hidden region and visible loading text that doubles as the live region are equally acceptable. Visible text is preferred when the wait is long enough that sighted users benefit from the same information.
- Size and placement, including inline within a control, centered within a region, or beside a label.
- The reduced-motion replacement text may repeat what the live region carries or be shorter, as long as it names the work rather than only saying that something is happening.

## Don'ts
- Do not rely on the spinner graphic to announce anything. An SVG with no text is exposed inconsistently across assistive technologies, and a spinner that is the only signal leaves screen reader users with silence.
- Do not put `role="progressbar"` on a spinner that has no value, which reports a range widget with nothing to report.
- Do not put `aria-live` on the spinner graphic or on the element that mounts and unmounts with it, since a live region that is not in the DOM before the change does not announce reliably.
- Do not use the native `disabled` attribute on a control that becomes busy after activation. Focus is destroyed and the user is returned to the start of the document.
- Do not leave a spinner running with no end state after a request fails.
- Do not keep the animation running under `prefers-reduced-motion: reduce`.
- Do not place several spinners in one view for content arriving in pieces.
- Do not attach a spinner to every asynchronous call. Add one when the wait is long enough for the user to notice it, or when the design asks for a busy state on a specific control. A wait the user never perceives needs no indicator.

## Golden Pattern

Structural reference for AI coding assistants — semantics, focus, and keyboard behavior. Styling, copy, and demo data are illustrative.

```jsx
"use client";

// Visually-hidden styles matching the global sr-only utility (global.sr-only).
const srOnly = {
  clip: "rect(1px, 1px, 1px, 1px)",
  height: "1px",
  overflow: "hidden",
  position: "absolute",
  whiteSpace: "nowrap",
  width: "1px",
};

// spin keyframes are defined in the app stylesheet.
const glyph = {
  display: "inline-block",
  width: "1em",
  height: "1em",
  border: "2px solid",
  borderRightColor: "transparent",
  borderRadius: "50%",
  animation: "spin 0.8s linear infinite",
};

function useReducedMotion() {
  const [reduceMotion, setReduceMotion] = useState(false);

  useEffect(() => {
    const query = window.matchMedia("(prefers-reduced-motion: reduce)");
    const apply = () => setReduceMotion(query.matches);
    apply();
    query.addEventListener("change", apply);
    return () => query.removeEventListener("change", apply);
  }, []);

  return reduceMotion;
}

/**
 * Spinner in a control. The button is the host: it keeps focus, its label
 * carries the state, and the glyph adds nothing to the accessibility tree.
 */
export function SaveButtonDemo() {
  const reduceMotion = useReducedMotion();
  const [busy, setBusy] = useState(false);
  const [announcement, setAnnouncement] = useState("");

  function onSave() {
    // aria-disabled does not block activation, so guard the handler.
    if (busy) return;
    setBusy(true);
    setAnnouncement("Saving your changes.");
    window.setTimeout(() => {
      setBusy(false);
      setAnnouncement("Changes saved.");
      // Clear the region once the message is stale, so it is not
      // discoverable later by a user browsing the page.
      window.setTimeout(() => setAnnouncement(""), 3000);
    }, 2500);
  }

  return (
    <div>
      {/* aria-disabled, not disabled: the native attribute destroys focus. */}
      <button type="button" onClick={onSave} aria-disabled={busy}>
        {busy && !reduceMotion ? <span aria-hidden="true" style={glyph} /> : null}
        {busy ? "Saving" : "Save"}
      </button>

      {/* Live region is mounted before the wait begins. */}
      <div role="status" style={srOnly}>
        {announcement}
      </div>
    </div>
  );
}

/**
 * Spinner in a region. The region carries aria-busy and its own name; under
 * reduced motion the glyph is replaced by text rather than simply removed.
 */
export function PanelLoadingDemo() {
  const reduceMotion = useReducedMotion();
  const [loading, setLoading] = useState(true);
  const [announcement, setAnnouncement] = useState("Loading recommendations.");

  useEffect(() => {
    const timer = window.setTimeout(() => {
      setLoading(false);
      setAnnouncement("Recommendations loaded.");
      window.setTimeout(() => setAnnouncement(""), 3000);
    }, 3000);
    return () => window.clearTimeout(timer);
  }, []);

  return (
    <section aria-labelledby="recs-heading" aria-busy={loading}>
      <h2 id="recs-heading">Recommended for you</h2>

      {loading ? (
        reduceMotion ? (
          <p>Loading recommendations</p>
        ) : (
          <span aria-hidden="true" style={glyph} />
        )
      ) : (
        <ul>
          {TITLES.map((title) => (
            <li key={title}>{title}</li>
          ))}
        </ul>
      )}

      <div role="status" style={srOnly}>
        {announcement}
      </div>
    </section>
  );
}

const TITLES = ["Nightfall Protocol", "The Quiet Coast", "Ember and Ash"];
```

## Acceptance Checks

- Structure
  - The spinner graphic exposes no role and no accessible name.
  - Tab never lands on the spinner.
  - While a region is loading it carries `aria-busy="true"`, and the attribute is gone once content arrives.
  - The live region is present in the DOM before the spinner appears, not mounted alongside it.
- Accessible naming
  - The host control or region names what is loading.
  - Adding the spinner does not change the host's accessible name.
  - A control whose label changes while busy reports the changed label.
- Screen reader
  - Starting the wait announces what is being waited on, exactly once.
  - Ending the wait announces the outcome, on both success and failure.
  - Nothing is announced by the graphic itself when the live region is removed from the page.
  - A busy control remains reachable and reports its disabled state without focus moving elsewhere.
- Visual
  - With `prefers-reduced-motion: reduce` set, no animation runs and visible text names the work in the graphic's place.
  - The spinner is distinguishable from its background, per `global.non-text-contrast`.
  - With Windows High Contrast Mode active, the spinner or its replacement text remains visible.
