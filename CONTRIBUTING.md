# Contributing

This repo packages installable skill artifacts for [A11y Context](https://a11y-context-project.vercel.app). One repo, multiple platforms (web/react today; iOS and Android coming), multiple retrieval variants per platform (local, http, possibly more).

## License

Apache 2.0 — see [LICENSE](LICENSE). By submitting a contribution, you agree to license it under Apache 2.0 and confirm that the contribution does not contain proprietary, confidential, or internal material from any employer, client, or third party that you do not have explicit permission to release publicly.

## Scope

Contributions to this repo should:

- Preserve the skill structure expected by Claude Code and compatible AI tools (`SKILL.md` with valid YAML frontmatter, supporting files alongside as needed)
- Keep skill `name:` fields unique across the repo — the convention is `a11y-context-<platform>-<variant>` (e.g., `a11y-context-web-react-local`)
- Match SKILL.md `name:` to the install-destination directory consumers expect

## Where other contributions belong

- **New accessibility patterns, pattern revisions, foundational rules** → contribute to [a11y-context/accessibility-pattern-api](https://github.com/a11y-context/accessibility-pattern-api). The corpus is the source of truth; skill files in this repo are derived consumption artifacts.
- **Organization-specific patterns or design-system component references** → keep them in your internal fork, not upstream.
- **A bug in the original 9-variant evaluation harness** → see the test harness in [a11y-context/_a11y-test-harness](https://github.com/a11y-context/_a11y-test-harness).

For broader scope guidance and the WCAG-vs-organization-specific boundary, see the corpus repo's [CONTRIBUTING.md](https://github.com/a11y-context/accessibility-pattern-api/blob/main/CONTRIBUTING.md).
