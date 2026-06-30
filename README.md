# A11y Context Skills

[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

Installable AI coding assistant skills for the [A11y Context](https://a11y-context-project.vercel.app) accessibility-pattern corpus. Drop a skill into your AI tool's skills directory and your assistant uses the patterns automatically when generating UI code.

## What's here

| Platform | Skill | Retrieval |
|---|---|---|
| Web / React | `a11y-context-web-react-http` | Fetches corpus from the public docs site at generation time |
| Web / React | `a11y-context-web-react-local` | Reads a bundled copy of the corpus from disk — fully offline |
| iOS / SwiftUI | Coming soon | — |
| Android / Compose | Coming soon | — |

### Picking between HTTP and Local

**HTTP — recommended starting point.** The agent fetches pattern pages from `a11y-context-project.vercel.app` at generation time. Always current; nothing to refresh. The smallest footprint — a single `SKILL.md` file in your repo. Needs network access from the agent.

**Local.** The agent reads patterns from a bundled copy of the corpus inside the skill folder. Fully offline; fastest retrieval. A good fit for network-restricted environments. You'll need to refresh the bundled corpus when the upstream releases an update.

## Install

### Quickest path: download a ZIP

Each skill is built as a ready-to-unzip artifact on the [A11y Context downloads page](https://a11y-context-project.vercel.app/getting-started/ai-coding-agents/downloads). Pick the skill you want, download the ZIP, and unzip it into your AI tool's skills directory.

Install locations:

| AI tool | Project-level install location |
|---|---|
| Claude Code | `.claude/skills/` |
| Cursor | `.cursor/skills/` |
| GitHub Copilot (VS Code) | `.github/skills/` |
| Opencode | `.opencode/skills/` |
| Codex | `.agents/skills/` |

Example, Claude Code:

```bash
unzip a11y-context-web-react-http.zip -d .claude/skills/
```

The folder inside the ZIP is named after the canonical skill name (declared in the `SKILL.md` frontmatter), so unzipping into your skills directory places the skill at the path your AI tool expects.

### Alternative: clone the repo

If you want to track updates with `git pull` or fork the skill to customize it for your environment, clone this repo and copy the skill folder into your AI tool's skills directory:

```bash
git clone https://github.com/a11y-context/a11y-context-skills
cp -r a11y-context-skills/skills/web-react/http \
      <your-project>/.claude/skills/a11y-context-web-react-http
```

## Verifying installation

After installing, run this prompt in a UI project (note: it doesn't mention accessibility):

```
Add a toast notification that confirms when an item is saved.
```

The agent should retrieve the toast pattern before writing code. Expected behavior in the output: the live region container is mounted at all times, the message is announced via `role="status"`, focus does not move to the toast, and the toast auto-dismisses with the region cleared.

## Repository layout

```
skills/
  web-react/
    local/      ← offline-local variant
      SKILL.md
      patterns.json
      components/
      global_rules.md
    http/       ← HTTP-fetch variant
      SKILL.md
      patterns.json
      global_rules.md
```

The skill's canonical name (declared in `SKILL.md` frontmatter `name:`) is also the destination folder name when consumed.

## Keeping the local variant current

The local variant bundles a snapshot of the upstream corpus. When the upstream [accessibility-pattern-api](https://github.com/a11y-context/accessibility-pattern-api) ships a new catalog release, this repo is synced — re-download the ZIP or `git pull` to pick up the new corpus.

The HTTP variant always retrieves the current corpus at generation time — no update needed in your project.

## License

Apache 2.0 — see [LICENSE](LICENSE).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Pattern content (the actual accessibility specifications) lives in [a11y-context/accessibility-pattern-api](https://github.com/a11y-context/accessibility-pattern-api); this repo packages installable artifacts derived from it.
