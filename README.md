# A11y Context Skills

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

Consolidated repository for [A11y Context](https://a11y-context-project.vercel.app) skill artifacts — installable skill files for using accessibility patterns inside an AI coding assistant.

## Status

| Platform | Status | Variants |
|---|---|---|
| Web / React | Production | `local`, `http` |
| iOS / SwiftUI | Coming soon | — |
| Android / Compose | Coming soon | — |

## Repository layout

```
skills/
  web-react/
    local/      ← reads patterns from bundled local files
      SKILL.md  (frontmatter name: a11y-context-web-react-local)
      patterns.json
      components/
      global_rules.md
    http/       ← fetches patterns from the public docs site
      SKILL.md  (frontmatter name: a11y-context-web-react-http)
      patterns.json
      global_rules.md
```

The skill's canonical name comes from the SKILL.md frontmatter `name:` field — that's what determines the install directory regardless of how the skill is retrieved.

## What's new vs. the variant repos

Each SKILL.md here carries an enhanced `description` field with phrasing designed to **improve invocation rates by AI coding assistants**. The earlier `claude-rule-skill-*` variant repos relied on a separate `a11y-policy.md` rule file to enforce invocation — that mechanism is hard to apply at the org level, so the invocation guidance has been folded into the skill's own `description` instead.

## Provenance

Skill content is derived from the experimental variant repos preserved in the [a11y-context-archive](https://github.com/a11y-context-archive) org:

- `claude-rule-skill-local` → `skills/web-react/local/`
- `claude-rule-skill-http` → `skills/web-react/http/`

Those repos retain their original SKILL.md `description` fields (without the rule-like invocation phrasing) and the separate rule file as historical artifacts from the 9-variant A11y Context evaluation. This repo is the canonical, maintained source going forward.

## Consumption

Three supported paths:

1. **Atlas** — point a Paramount catalog entry at the relevant skill directory (e.g., `path: "skills/web-react/local/"`). See [Atlas docs](https://atlas.docs.paramount.tech).
2. **Direct download** — coming soon: per-skill ZIPs from the [A11y Context downloads page](https://a11y-context-project.vercel.app).
3. **Git clone** — clone this repo and copy the relevant skill directory into your AI tool's skills location (e.g., `.claude/skills/a11y-context-web-react-local/` for Claude Code).

## License

Apache 2.0 — see [LICENSE](LICENSE).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Corpus patterns are authored in [a11y-context/accessibility-pattern-api](https://github.com/a11y-context/accessibility-pattern-api).
