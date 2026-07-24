---
name: skill-authoring
description: "Use when creating, extracting, splitting, reviewing, or releasing portable agent skills or plugin-facing doctrine, especially when deciding whether guidance belongs in canonical doctrine, a trigger wrapper, one-hop reference, optional skill, release train, or repo-local owner."
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
3. Record a Skill Surface Disposition before creating, splitting, deleting,
   renaming, or substantially editing a skill.
4. Write concise, trigger-focused frontmatter. The `description` names when to
   load the skill: symptoms, tasks, and decisions. Do not summarize the workflow
   so agents can skip the body.
5. Keep `SKILL.md` small. Add one-hop `references/` files only when details are
   too long or conditional. Avoid README-style auxiliary docs inside a skill.
6. Prefer existing repo patterns for validation. If a validator or classifier is
   reusable, make it an Agent Trigger Kit template rather than embedding it in a
   doctrine skill.
7. Document consumer adoption separately from implementation details: exact tag,
   install command, default-vs-optional skill choice, and expected entrypoint
   pointer updates.

## Skill Surface Disposition

When a spec or plan changes a skill surface, choose one disposition and record
the reason:

- **Keep canonical**: shared authority, object identity, approval semantics, or
  cross-wrapper invariants belong in one canonical doctrine home.
- **Add or keep trigger wrapper**: use a wrapper only when the workflow is
  high-frequency or high-miss, has distinct trigger words, and can point to
  canonical homes without restating them.
- **Move to one-hop reference**: use a referenced file when details are too long
  or conditional for `SKILL.md`, but still belong to the same skill.
- **Split into separate optional skill**: split when trigger, audience, must-read
  set, or install choice differs enough that bundling increases context load.
  Two concrete tests (borrow-adapt, mattpocock/skills `writing-great-skills`):
  **split-by-invocation** — would a consumer ever need one part without the
  other firing at the same time? If yes, split. **split-by-sequence** — do
  the parts always fire together in the same order for the same task? If so,
  keep them as sequential steps inside one skill instead of splitting.
- **Make default-installed**: install by default only when most ordinary
  adopting-repo sessions need the trigger surface; otherwise keep explicit
  install.
- **Delete or shrink**: remove duplicate prose, stale examples, and broad
  reminders that add tokens without changing behavior.
- **Defer with owner**: route mechanism, adopting-repo policy, private artifact,
  MCP / vector retrieval, or roadmap-lane work to its real owner.

Prefer deletion, pointer, or wrapper before broad canonical growth. One observed
miss is not enough to create a new skill if a small pointer, frontmatter fix, or
smoke assertion closes the gap.

## Release Checklist

- The skill folder name matches the frontmatter `name`.
- The skill is optional unless it is needed by most consumer sessions.
- Installer tests cover default install, explicit install, idempotency, and
  managed sentinel files.
- Release metadata and tag agree before publishing. If a reviewed train changes
  install-facing skill text, default skill choice, plugin metadata, marketplace
  metadata, installer behavior, or adopting-repo install output, bump manifests
  and proceed through the release lifecycle
  directly or as part of a later reviewed batch. After review and merge, the tag
  targets the reviewed head at the then-current manifest version. Do not create
  retroactive tags for intermediate bump-only versions unless a separate
  reviewed release-repair plan authorizes them. Follow
  `agent-operating-manual/25-change-discipline.md` §3.2
  `Release tag / publish lifecycle discipline` for the release gates.
- If a train changes only specs, implementation plans, private planning
  artifacts, non-installed roadmap text, or review evidence, do not bump
  metadata or create a tag unless a reviewed release plan says otherwise.
- Tag creation, tag push, publish approval, post-tag smoke, post-publish
  verification, and no-backfill policy follow `25-change-discipline.md` §3.2.
- Consumer repos upgrade by re-running the installer; imported skill files are
  managed artifacts, not hand-edited local doctrine.

## Public Skill / Plugin Hygiene

- Keep scratch or generated artifacts in an ignored, namespaced path.
- Make premerge version checks fail loud when generated manifests, marketplace
  entries, plugin metadata, or tags disagree.
- Keep public runbooks thin. A runbook should onboard wiring once; ongoing
  learning loops belong in doctrine and per-repo lessons, not in a pin prompt.
- Do not publish a portable release-governance skill from one repo's release
  run. A future portable skill needs writing-skills RED/GREEN pressure
  scenarios across Git-tag-only delivery, hosted releases, package registries,
  plugin marketplaces, and no-publish-surface repos.
