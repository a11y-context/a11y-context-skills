---
id: progress-bar.basic
title: Progress Bar
stack: web/react
status: beta
latest_version: 0.1.0
tags: [progress, progressbar, loading, status, live-region, reduced-motion]
aliases: [progress bar, progress indicator, loading bar, loading indicator, upload progress, download progress, percent complete, indeterminate progress]
summary: Non-interactive indicator of a process advancing toward completion, using the native <progress> element or role="progressbar" with aria-valuenow, and announcing completion through a separate live region rather than on every value change.
---

# Progress Bar

Pattern ID: `progress-bar.basic`

Non-interactive indicator of a process advancing toward completion, using the native `<progress>` element or `role="progressbar"` with `aria-valuenow`, and announcing completion through a separate live region rather than on every value change.

The value is reported by the system, never set by the user. Shape does not decide the pattern: a ring or arc reporting a process belongs here, and a bar the user can drag belongs to `slider.basic` no matter how similar it looks.

## Use When
- Use when a process the user started reports how far it has advanced toward a known end point (e.g., "Uploading 3 of 8 files", a download at 47%).
- Use when a process the user started is running with no knowable end point, and a bar communicates that work is still underway (e.g., a form submitting, a report generating).
- Use when the value advances on its own and the user cannot set, drag, or type it.

## Do Not Use When
- Do not use when the user sets or changes the value by dragging or with arrow keys (use `slider.basic`).
- Do not use when the value is a static measurement within a known range rather than progress toward completion, such as disk usage, storage quota, or battery level (use `meter.basic`).
- Do not use when the indicator is a small glyph inside a button or panel that already carries its own label, added only to show that button or panel is working, such as a spinner inside a Save button while it submits (use `spinner.basic`).
- Do not use when grey shapes stand in for the layout of the content itself, such as bars where lines of text will appear and a block where an image will load (use `skeleton.basic`).
- Do not use when the bar shows position within playing media and the user can seek to a point in it (use `slider.seek`).
- Do not use when the display shows which step of a multi-step sequence the user has reached (use `stepper.basic`).

## Must Haves

### Roles & structure
- Use the native `<progress>` element (preferred), or `role="progressbar"` on a non-native element only when the native element cannot be used.
- The progress bar is not focusable and is not in the page tab sequence.
- The `<progress>` element, or the element carrying `role="progressbar"`, contains no text, headings, images, or interactive content.
  - Render the label, the numeric value, and any status message as siblings of the progress bar.
- When the progress bar reports loading of a specific region of the page, that region has `aria-busy="true"` until loading completes, and the attribute is removed or set to `"false"` afterward.

### Accessible name
- The progress bar has an accessible name that describes what is progressing, via `<label>` or `aria-labelledby` referencing visible text when it exists, otherwise via `aria-label`.
- When a visible label exists, the visible text is contained in the accessible name and appears at the start of it.
- When context beyond the name is needed, add it via `aria-describedby` referencing the visible text that carries it.

### State & properties
- A determinate progress bar sets `aria-valuenow` to the current value, updated as the process advances.
  - On `<progress>`, the `value` attribute carries this and `aria-valuenow` is not added.
- `aria-valuemin` and `aria-valuemax` are set when the range is not 0 to 100, and omitted otherwise, since `aria-valuemin` defaults to `0` and `aria-valuemax` defaults to `100`.
- An indeterminate progress bar omits `aria-valuenow` entirely.
  - On `<progress>`, omit the `value` attribute.
- When a percentage does not describe the value accurately, set `aria-valuetext` to the unit the user cares about (e.g., "3 of 8 files", "About 2 minutes remaining").
- When color distinguishes progress states (e.g., running, paused, failed, or complete) or the kind of work in progress, that distinction is also carried by text, an icon, or a shape, per `global.use-of-color`.
- The filled portion of the bar and the unfilled track differ from each other by a contrast ratio of at least 3:1, per `global.non-text-contrast`.
  - Under Windows High Contrast Mode, author background colors are overridden, so pair the styling with a `@media (forced-colors: active)` override that gives the track a `1px` border in `CanvasText` and the fill a background in `Highlight`.
- Status messages tied to the progress bar (e.g., "Uploading", "Almost done", "Complete") are rendered into a live region that is present in the DOM before the first message appears. Use `role="status"`, or an equivalent such as `aria-live="polite"` and `aria-atomic="true"`.
  - When those messages are visible on screen, the visible container is the live region, and no second copy is added.
  - When the design has no visible status messages, a determinate progress bar announces its completion once through a visually hidden live region (e.g., "Upload complete"), per `global.sr-only`.
  - Announcement text takes its words from the progress bar's accessible name rather than newly authored wording, so the announcement matches the visible label (e.g., a bar named "Uploading episode files" gives "Upload complete").
  - Text in a visually hidden live region is cleared once it no longer describes the current state, so a stale message is not discoverable later by a user browsing the page.
- Announcements are limited to the status messages the design defines and to completion. Intermediate value changes are not announced.

### Motion & timing
- Under `prefers-reduced-motion: reduce`, the progress bar runs no looping animation, such as a barber-pole stripe or a fill that sweeps back and forth, and stays on screen as a static indicator of ongoing work.
  - Movement driven by the value itself is exempt. A fill that advances as progress is made, including in occasional discrete jumps, continues under this preference.

## Customizable
- The base element. The native `<progress>` element is preferred when feasible: it carries the role, the value, and forced-colors behavior without additional code. Substitute `<div role="progressbar">` when the design requires visual treatment the native element cannot express, since `<progress>` is styled through three vendor-specific pseudo-element systems (`::-webkit-progress-bar`, `::-webkit-progress-value`, and `::-moz-progress-bar`) and offers no control over its indeterminate animation. Either implementation requires the naming, value, contrast, and announcement contract above.
- How reduced motion is honored. A CSS `@media (prefers-reduced-motion: reduce)` block setting `animation: none` and a JavaScript `matchMedia` check that skips the animated style are equally acceptable. The golden pattern uses `matchMedia` so the decision is visible in the component.
- Whether the numeric value is also displayed as visible text. When it is, the same value is reflected in `aria-valuenow` or `aria-valuetext`.
- Whether status messages exist at all. A progress bar with no status messages and no completion state (an indeterminate bar that is simply removed when work finishes) needs no live region.
- How often `aria-valuenow` updates is at the engineer's discretion, as long as announcements stay limited to discrete points. The attribute is read on demand by assistive technology rather than announced, so updating it frequently is not itself disruptive.
- Bar thickness, corner treatment, placement relative to the label, and fill animation easing.

## Don'ts
- Do not give the progress bar element `aria-live`, and do not nest it inside a live region. Every value change is then announced, interrupting the user's reading and navigation.
  - A visible status message adjacent to the bar may be a live region, as long as it updates at discrete points rather than on every tick.
- Do not place text, headings, or interactive content inside the `role="progressbar"` element. Descendants of the role are presentational and are removed from the accessibility tree.
- Do not set `aria-valuenow` on an indeterminate progress bar, including to `0`, which reports stalled progress rather than unknown progress.
- Do not add `tabindex="0"` to the progress bar or otherwise place it in the tab sequence.
- Do not use `role="progressbar"` for a value the user can change.
- Do not leave `aria-busy="true"` on a region after its content has finished loading.
- Do not distinguish the fill from the track by background color alone with no `forced-colors` override.
- Do not announce completion twice by pairing a visible status message with a visually hidden one carrying the same text.

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

/**
 * Determinate. The end point is known, so the value is reported and completion
 * is announced once. Native <progress> carries the role and the value.
 */
export function UploadProgressDemo() {
  const progressId = useId();
  const [percent, setPercent] = useState(0);
  const [announcement, setAnnouncement] = useState("");

  useEffect(() => {
    if (percent >= 100) {
      // Announced once, at completion. Not on every tick.
      setAnnouncement("Upload complete.");
      return;
    }
    const timer = window.setTimeout(() => {
      setPercent((value) => Math.min(100, value + 7));
    }, 400);
    return () => window.clearTimeout(timer);
  }, [percent]);

  return (
    <div>
      {/* <progress> is a labelable element, so a native <label> names it. */}
      <label htmlFor={progressId}>Uploading episode files</label>

      <progress id={progressId} value={percent} max={100} />

      {/* Sibling, not a child: descendants of the role are presentational. */}
      <span>{percent}%</span>

      {/* Live region is always mounted; only completion reaches it. */}
      <div role="status" style={srOnly}>
        {announcement}
      </div>
    </div>
  );
}

/**
 * Indeterminate. No end point is known, so aria-valuenow is omitted entirely
 * and the visible status text doubles as the live region.
 */
export function ReportProgressDemo() {
  const labelId = useId();
  const [reduceMotion, setReduceMotion] = useState(false);
  const [status, setStatus] = useState("Gathering viewing data");

  useEffect(() => {
    const query = window.matchMedia("(prefers-reduced-motion: reduce)");
    const apply = () => setReduceMotion(query.matches);
    apply();
    query.addEventListener("change", apply);
    return () => query.removeEventListener("change", apply);
  }, []);

  useEffect(() => {
    const timer = window.setTimeout(() => setStatus("Almost done"), 3000);
    return () => window.clearTimeout(timer);
  }, []);

  return (
    <div>
      <span id={labelId}>Generating report</span>

      {/* No aria-valuenow: the value is unknown, which is not the same as zero. */}
      <div
        role="progressbar"
        aria-labelledby={labelId}
        style={{
          height: "8px",
          border: "1px solid",
          // Reduced motion keeps the indicator and drops the looping animation.
          // progress-slide keyframes are defined in the app stylesheet.
          animation: reduceMotion ? "none" : "progress-slide 1.2s linear infinite",
        }}
      />

      {/* Visible status text IS the live region. No sr-only duplicate. */}
      <p role="status">{status}</p>
    </div>
  );
}
```

## Acceptance Checks

- Structure
  - The progress bar exposes the `progressbar` role.
  - Tab never lands on the progress bar.
  - The progress bar element has no text or interactive descendants; the label, value, and status text sit beside it.
  - While a region is loading, that region carries `aria-busy="true"`, and the attribute is gone once loading finishes.
- Accessible naming
  - The progress bar has an accessible name describing what is progressing.
  - When a visible label is present, its text is contained in the accessible name.
- Screen reader
  - A determinate bar reports its current value on demand, and the reported value matches any visible percentage.
  - An indeterminate bar reports no value, and is not reported as 0%.
  - Where a percentage would be misleading, the value is reported using `aria-valuetext` in the unit shown to the user.
  - Advancing from 0 to complete produces announcements only at the defined status points and at completion, with no announcement per value change.
  - Completion is announced exactly once, and is not duplicated between a visible message and a hidden one.
- Visual
  - The filled portion and the unfilled track meet at least 3:1 contrast against each other.
  - With Windows High Contrast Mode active (or emulated via a browser dev-tool forced-colors setting), the filled portion remains distinguishable from the track.
  - Every progress state that color conveys is still distinguishable in grayscale.
  - With `prefers-reduced-motion: reduce` set, no looping animation runs, and an indeterminate bar remains visible as a static indicator.
  - With that preference set, a determinate fill still advances as the value changes.
