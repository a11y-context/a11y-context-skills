---
id: avatar.basic
title: Avatar
stack: web/react
status: beta
latest_version: 0.1.0
tags: [avatar, identity, image, alt-text, initials, profile]
aliases: [avatar, user avatar, profile picture, profile photo, profile image, initials avatar, monogram, gravatar]
summary: Image, initials, or glyph standing for a person or entity, where the accessible name identifies who is represented and stays the same whichever branch of the fallback chain renders.
---

# Avatar

Pattern ID: `avatar.basic`

Image, initials, or glyph standing for a person or entity, where the accessible name identifies who is represented and stays the same whichever branch of the fallback chain renders.

## Use When
- Use when an image, initials, or a glyph identifies a specific person (e.g., a comment author, an account holder, a viewer in a list) or a non-person entity (e.g., a channel, a team, or a brand account).

## Do Not Use When
- Do not use when activating the avatar performs an action or navigates elsewhere (use `button.basic` or `link.basic`).
- Do not use when a status, presence, or count indicator sits on or beside the avatar (use `badge.basic`).
- Do not use when avatars are stacked into a group with an overflow affordance such as "+3" (use `avatar.group`).
- Do not use when the image is content the user is meant to look at rather than an identifier for someone, such as a poster, a thumbnail, or artwork (use `collection-row.basic` when it sits in a browse row).

## Must Haves
- When a visible name for the same person sits beside the avatar, the avatar is decorative: `alt=""` on an `<img>`, or `aria-hidden="true"` on any other rendering.
- When the avatar is the only identification of the person or entity, it carries an accessible name, and that name is the person's or entity's name.
- A photograph, an initials fallback, and a generic glyph for the same person carry the same name.
- An `<img>` avatar is named with `alt`.
- A rendering that is not an `<img>` uses `role="img"` named with `aria-label` or `aria-labelledby`.
  - Descendants of `role="img"` are presentational. Initials or an inline `<svg>` inside it are not exposed, so the name comes from the attribute.

## Customizable
- Which element renders the artwork. An `<img>`, an inline `<svg>`, a `<span>` of initials, and an element carrying a CSS `background-image` are all acceptable. An `<img>` is named with `alt`; every other rendering carries `role="img"` and an `aria-label`.
- Where the name lives on a rendering that is not an `<img>`. `role="img"` with `aria-label` is preferred. When the artwork must stay out of the accessibility tree entirely, `aria-hidden="true"` on the artwork with the name supplied as visually hidden text (see `global.sr-only`) is an acceptable substitute.
- The fallback chain. A photograph, a monogram, a generic glyph, or a color derived from the identifier, in any order, as long as the name is the same at every branch.
- Which form of the name is used, whether a display name, a full name, or a username, as long as it matches the form used for the same person elsewhere in the view.
- Shape, size, border treatment, and how the image is cropped.

## Don'ts
- Do not make the avatar focusable or place it in the page tab sequence.
- Do not use a file name, "avatar", "image", "photo", or "profile picture" as the accessible name.
- Do not place text inside `role="img"` and rely on it being announced. Browsers apply `presentation` to every descendant of that role.
- Do not pair `alt=""` with an `aria-label`. Supplying a name by any mechanism restores the implicit image role, and the avatar stops being decorative.
- Do not omit `alt` on an `<img>` avatar. An absent `alt` leaves the image unnamed rather than decorative.
- Do not name only the branch that usually renders, leaving the fallback anonymous.

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

export function Avatar({ name, src, decorative = false }) {
  const [failed, setFailed] = useState(false);

  if (src && !failed) {
    return <img src={src} alt={decorative ? "" : name} onError={() => setFailed(true)} />;
  }

  if (decorative) {
    return <span aria-hidden="true">{monogram(name)}</span>;
  }

  // role="img" makes descendants presentational: the initials are never
  // announced, so aria-label is the only thing naming this.
  return (
    <span role="img" aria-label={name}>
      {monogram(name)}
    </span>
  );
}

function monogram(name) {
  return name
    .split(" ")
    .map((part) => part[0])
    .join("");
}

function AvatarExamples() {
  return (
    <>
      {/* Visible name present, so the avatar is decorative. */}
      <p>
        <Avatar name="Jane Okonkwo" src="/avatars/jane.jpg" decorative />
        <span>Jane Okonkwo</span> commented on your clip.
      </p>

      {/* No visible names, so each avatar is named. Marcus has no photo and
          reports the same name from the initials branch. */}
      <ul>
        <li>
          <Avatar name="Jane Okonkwo" src="/avatars/jane.jpg" />
        </li>
        <li>
          <Avatar name="Marcus Bell" />
        </li>
        <li>
          <Avatar name="Priya Raman" src="/avatars/priya.jpg" />
        </li>
      </ul>

      {/* Alternative to Avatar's role="img" branch, not an addition to it, for
          artwork that cannot carry a role such as a CSS background. The name
          must sit outside the aria-hidden subtree or it is never announced. */}
      <span>
        <span aria-hidden="true" style={{ background: "url(/avatars/jane.jpg)" }} />
        <span style={srOnly}>Jane Okonkwo</span>
      </span>
    </>
  );
}
```

## Acceptance Checks
- Structure
  - Tab never lands on the avatar.
  - A decorative avatar exposes no role and no accessible name.
- Accessible naming
  - A meaningful avatar's accessible name is the person's or entity's name.
  - The name contains no file name and none of the words "avatar", "image", "photo", or "profile picture".
  - Blocking the image so the fallback renders produces the same name the photograph produced.
- Screen reader
  - An avatar beside a visible name announces the person once, not twice.
  - Initials inside a `role="img"` avatar are not announced as separate text.
- Visual
  - A glyph or monogram carrying meaning is distinguishable from its background, per `global.non-text-contrast`.
