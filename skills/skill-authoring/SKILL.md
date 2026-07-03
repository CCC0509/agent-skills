---
name: skill-authoring
description: "Use when creating, extracting, reviewing, or releasing portable agent skills or plugin-facing doctrine from repo-local playbooks. Covers scope boundaries, trigger metadata, reusable resources, scratch namespace policy, release/version reconciliation, and consumer install guidance for shareable skills/plugins."
---

# Skill Authoring

Use this when turning repo-local agent behavior into a reusable skill or plugin
surface. Keep the boundary sharp:

- **Doctrine text lives in agent-skills**: reusable judgment, workflows,
  review methods, lifecycle rules, and authoring guidance.
- **Mechanism lives in agent-trigger-kit or the adopting repo**: validators,
  trigger-layer generators, script templates, pin/session/closeout tooling, and
  outcome collection.
- **Memory data stays per repo**: `LESSONS.md`, `00-diagnosis.md`,
  ops-observations, review logs, and domain playbooks are not centralized.

## Authoring Flow

1. Pin the source material: exact files, commit/range, and which repo owns each
   piece after extraction.
2. Decide whether the content is doctrine, mechanism, or repo-local data before
   writing. Do not mix runtime collection into a markdown-only skill.
3. Write concise frontmatter. The `description` must say what the skill does and
   the situations that should trigger it; do not hide trigger rules in the body.
4. Keep `SKILL.md` small. Add one-hop `references/` files only when details are
   too long or conditional. Avoid README-style auxiliary docs inside a skill.
5. Prefer existing repo patterns for validation. If a validator or classifier is
   reusable, make it an Agent Trigger Kit template rather than embedding it in a
   doctrine skill.
6. Document consumer adoption separately from implementation details: exact tag,
   install command, default-vs-optional skill choice, and expected entrypoint
   pointer updates.

## Release Checklist

- The skill folder name matches the frontmatter `name`.
- The skill is optional unless it is needed by most consumer sessions.
- Installer tests cover default install, explicit install, idempotency, and
  managed sentinel files.
- Release metadata and tag agree before publishing.
- Consumer repos upgrade by re-running the installer; imported skill files are
  managed artifacts, not hand-edited local doctrine.

## Public Skill / Plugin Hygiene

- Keep scratch or generated artifacts in an ignored, namespaced path.
- Make premerge version checks fail loud when generated manifests, marketplace
  entries, plugin metadata, or tags disagree.
- Keep public runbooks thin. A runbook should onboard wiring once; ongoing
  learning loops belong in doctrine and per-repo lessons, not in a pin prompt.
