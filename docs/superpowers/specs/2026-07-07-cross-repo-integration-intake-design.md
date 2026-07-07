# Cross-Repo Integration Intake / Adopting-Repo Overlap Audit Design

**Status:** Design spec for review.

**Goal:** Define the v0.5.9 cross-repo intake protocol that lets agents decide
where a rule, trigger surface, mechanism, bootstrap template, or adopting-repo
policy belongs before changing multiple public tool repos or generated local
copies.

## Problem

Recent trains tightened `agent-skills` itself: handoff triggers, skill-surface
discipline, release gates, and public PR / release train discipline. The next
failure mode is cross-repo coordination.

The user raised three connected issues after the v0.5.8 merge:

- `operator-bootstrap` already carries user-level instructions. The sandbox /
  credential retry rule exists in relay doctrine, but agents can still miss it
  unless the bootstrap layer exposes it clearly.
- Agent Trigger Kit owns mechanisms such as `session-check`, root-source plugin
  layout handling, validators, outcome taxonomy, and trigger-layer templates.
  The recurring `agent-skills: plugin directory missing` source-repo boundary
  should not be patched with fake directories inside `agent-skills`.
- Other public tool repos may need the new public PR / release train discipline,
  but applying it directly would be risky without first auditing their local
  entrypoints, installed skill pins, trigger layers, and repo-owned policies.

There is already a `cross-repo-reference-map.md`, but it is an ownership map,
not an execution intake. It answers "who owns this?" after the issue is clear.
It does not yet give agents a repeatable, read-only packet for importing a repo
into the coordination surface and deciding what is safe to change.

## Design

Implement v0.5.9 as a doctrine slice in `agent-skills`, not as a cross-repo
edit train. The implementation should define a reusable intake / overlap audit
that future agents can run before touching `operator-bootstrap`, Agent Trigger
Kit, Stock Scanner, or another adopting repo.

### 1. Canonical Home

The canonical home should be
`skills/agent-operating-manual/cross-repo-reference-map.md`.

That file already routes ownership between `operator-bootstrap`,
`agent-skills`, Agent Trigger Kit, adopting repos, and MCP / codebase-index
tooling. v0.5.9 should extend it with a small "Cross-Repo Integration Intake"
section and, if needed, a one-hop checklist subsection.

Keep these boundaries stable:

- `agent-skills` owns portable doctrine, review / relay / approval semantics,
  release discipline, skill text, and plugin metadata.
- `operator-bootstrap` owns user-level and machine-level instruction templates,
  generated bootstrap text, and operator distribution mechanics.
- Agent Trigger Kit owns validators, `session-check`, closeout behavior,
  outcome taxonomy, hooks, trigger-layer generation, plugin layout
  normalization, and reusable mechanism templates.
- Adopting repos own generated imports, `.agent-skills/pin`, local AGENTS /
  CLAUDE / GEMINI addenda, repo memory, domain playbooks, and local audit
  evidence.
- MCP / retrieval tooling is optional discovery infrastructure; it is not
  canonical memory and should not become a prerequisite for ordinary doctrine
  maintenance.

### 2. Intake Packet

Before changing another repo or deciding that a portable rule should be applied
there, the acting agent should produce a compact intake packet with these
fields:

- **Source repo / source object:** the doctrine, spec, plan, PR, tag, or rule
  that triggered the cross-repo question.
- **Target repo / target head:** repo name, local checkout path if needed,
  branch, base, head, and whether the target is public.
- **Current entrypoints:** AGENTS.md / CLAUDE.md / GEMINI.md, README pointers,
  installed imported-skill pointers, local plugin or skill wrappers, and any
  repo-specific conventions addenda.
- **Installed source state:** `.agent-skills/pin`, plugin manifest or
  marketplace metadata, generated imports, and whether updates come from
  source doctrine, installer rerun, or local policy.
- **Mechanism surfaces:** Agent Trigger Kit hooks, validators, session-check /
  closeout behavior, outcome-store state, MCP / index configuration, and
  harness-specific escalation or credential boundaries.
- **Public artifact boundary:** which evidence is public-safe, which evidence
  must remain private, and where durable public summary belongs.
- **Ownership disposition:** one of `agent-skills`, `operator-bootstrap`,
  `Agent Trigger Kit`, `adopting repo`, `MCP / local tooling`, or
  `defer with owner`.
- **Allowed write surface:** exact files or repos that may be changed in the
  current train; all other repos remain read-only.
- **Verification / residual plan:** cheap probes, expected gaps, and accepted
  residual owners.

This packet should be small enough to paste into a handoff and precise enough
that the next agent does not infer cross-repo authority from nearby discussion.

### 3. Adopting-Repo Overlap Audit

The first concrete audit should be read-only. It should answer whether a target
repo already has local rules that overlap with `agent-skills`, and whether the
overlap should be left local, replaced by an installed source update, or routed
to another owner.

Audit surfaces:

- entrypoints: AGENTS.md, CLAUDE.md, GEMINI.md, README, plugin marketplace
  pointers, and local command wrappers;
- imported skills or generated copies under the target repo;
- `.agent-skills/pin`, install metadata, plugin manifests, marketplace entries,
  and default / optional skill lists;
- local skill wrappers, project-scope skills, trigger rules, Cursor / Gemini /
  Claude / Codex pointers, and ATK trigger layers;
- repo memory index, lesson / audit / status files, review logs, domain
  playbooks, and private evidence locations;
- release / PR flow, branch protections, tag / publish surfaces, and whether
  the repo is public.

Classify each overlap:

- **Source doctrine update:** reusable behavior belongs in `agent-skills`, then
  target repos adopt through installer or explicit upgrade.
- **Bootstrap propagation:** user-level or machine-level instruction text
  belongs in `operator-bootstrap`.
- **Mechanism update:** validator, hook, taxonomy, plugin-source layout,
  session-check, or generated trigger behavior belongs in Agent Trigger Kit.
- **Repo-local keep:** local domain policy, audit evidence, memory, or
  repo-specific guardrails stay in the target repo.
- **Private evidence boundary:** details move to or stay in a private planning
  / audit surface; only sanitized summaries remain public.
- **No action:** overlap is benign or already pointed at the right source.

Cleanup is always opt-in. The audit may recommend deleting duplicate local
rules or generated residue, but implementation must stop for a separate
approval-bound plan before changing adopter-owned files.

### 4. Operator-Bootstrap / ATK Coordination

The v0.5.9 spec should record the recent sandbox / credential incident as a
coordination lesson:

- In sandbox, `gh auth status` reported an invalid token.
- Outside sandbox, the same command reported a valid keyring token.
- The correct doctrine behavior is to retry the same minimal command through
  the sanctioned outside-sandbox path before declaring a credential or remote
  metadata blocker.

Implementation should not edit `operator-bootstrap` or Agent Trigger Kit yet.
Instead, it should make the intake protocol require a routing decision:

- If the user-level bootstrap text is missing or too weak, route a follow-up to
  `operator-bootstrap`.
- If `session-check`, plugin layout normalization, closeout taxonomy, or
  validator behavior is wrong, route a follow-up to Agent Trigger Kit.
- If both are involved, split the work: doctrine / handoff text in
  `agent-skills`, bootstrap distribution in `operator-bootstrap`, and runtime
  checks in Agent Trigger Kit.

The implementation plan should keep those as durable residuals or ROADMAP
rows, not as hidden chat conclusions.

### 5. Public Repo Discipline Propagation

The two public tool repos raised by the user should be treated as future target
repos for the intake protocol. They should not receive direct changes in the
v0.5.9 `agent-skills` train.

The eventual target-repo application should:

1. run the intake packet against the target repo;
2. determine whether public PR / release train discipline is already covered by
   local instructions, installed `agent-skills`, or both;
3. decide whether the target should upgrade installed skills, add a local
   pointer, or change its own repo policy;
4. use that target repo's public PR / merge / release process for any actual
   change.

This sequencing lets v0.5.9 dogfood cross-repo handoff fields without turning
one `agent-skills` spec into a multi-repo edit.

### 6. Branch Cleanup Boundary

Branch cleanup is not part of this train. It remains in the ROADMAP row
`Branch / worker lifecycle hygiene`.

The merged v0.5.8 branch and any remote branch residue are evidence for the new
public PR flow and should not be deleted as an incidental side effect of this
spec. A later branch / worker lifecycle train should define:

- when merged local branches may be deleted;
- whether remote branches are cleaned by merge UI, CLI, or explicit approval;
- how worktree cleanup interacts with user-owned files;
- how worker spawn / wait / consume / close state is recorded.

## Scope

In scope for v0.5.9 implementation planning:

- Add a cross-repo integration intake protocol to the existing cross-repo
  reference map or a one-hop file linked from it.
- Add adopting-repo overlap audit categories and allowed write-surface rules.
- Add smoke / token coverage that makes the new intake discoverable from the
  installed `agent-operating-manual`.
- Update ROADMAP with a v0.5.9 Landed entry and retire or narrow
  `Adopting-repo project-scope overlap audit` only if implementation actually
  covers it.
- Preserve adjacent candidates: `Skill context loading / retrieval strategy`,
  `F2 handoff-contract file split`, `Plan/spec lifecycle header convention
  text`, `Branch / worker lifecycle hygiene`, `Private superpowers plan
  artifact boundary`, and ATK template rows.
- Bump metadata to `0.5.9` if installed doctrine changes.

Out of scope for this spec and implementation train:

- Editing `operator-bootstrap`.
- Editing Agent Trigger Kit.
- Editing Stock Scanner or any other adopting repo.
- Running install-time cleanup in adopting repos.
- Deleting local or remote branches.
- Moving `docs/superpowers/**` to a private repo.
- Implementing vector / MCP retrieval or generated trigger-surface audits.
- Changing `session-check`, validators, hooks, outcome taxonomy, or plugin
  layout normalization.
- Creating, pushing, or publishing a v0.5.9 tag.
- Retrofitting public PR / release train discipline directly into other repos
  before the intake protocol exists.

## Proposed Implementation Shape

The implementation plan should prefer this narrow slice:

1. Add a "Cross-Repo Integration Intake" section to
   `skills/agent-operating-manual/cross-repo-reference-map.md`.
2. Add concise pointer text in `skills/agent-operating-manual/README.md` only if
   the existing row does not make the new intake discoverable enough.
3. Add install smoke assertions for tokens such as `Cross-Repo Integration
   Intake`, `Allowed write surface`, and `Adopting-repo overlap audit`.
4. Update ROADMAP landed / candidate rows without touching unrelated lanes.
5. Bump plugin metadata to `0.5.9` because installed doctrine changes.

The plan should end at review before any push, PR, merge, tag, publish, branch
cleanup, or cross-repo edit.

## Verification For This Spec

Because this is a design-only increment, verification should be lightweight:

- `agent-trigger-kit session-check`
- `git diff --check`
- placeholder scan for unfinished markers
- token scan:

```bash
rg -ni 'Cross-Repo Integration Intake|Adopting-repo overlap audit|Allowed write surface|operator-bootstrap|Agent Trigger Kit|Branch / worker lifecycle hygiene|Private superpowers plan artifact boundary|Skill context loading / retrieval strategy|v0\.5\.9|0\.5\.9' docs/superpowers/specs ROADMAP.md skills README.md
```

In this source repo, `agent-trigger-kit session-check` may exit 1 only for the
documented root-source boundary:
`agent-skills: plugin directory missing`. When a relay signal is present, carry
the accepted residual:
`ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`.

## Pre-Spec Disposition

This spec incorporates the discussion that happened before the file existed.

- Tag deferral: accepted. The v0.5.7 + v0.5.8 install-facing batch remains a
  release residual; v0.5.9 planning should not create a tag.
- Operator-bootstrap concern: accepted. Bootstrap owns user-level and
  machine-level distribution, so v0.5.9 should route missing bootstrap text as
  a follow-up rather than editing that repo directly.
- ATK coordination concern: accepted. Agent Trigger Kit owns validators,
  `session-check`, outcome taxonomy, trigger mechanisms, and root-source plugin
  layout handling.
- Public tool repo propagation: accepted. Other public tool repos should use
  public PR / release train discipline, but only after a read-only intake
  packet identifies local overlap and ownership.
- "Bring repo in for integration" requirement: accepted. The adopting-repo
  overlap audit becomes the first concrete protocol before applying rules to
  other repos.
- Branch cleanup question: accepted as out of scope. Cleanup remains in
  `Branch / worker lifecycle hygiene`; no branch deletion or worktree cleanup is
  authorized by this spec.
- Sandbox / credential incident: accepted. The spec records the need to
  distinguish sandbox credential isolation from true credential failure by
  retrying the same minimal command through the sanctioned outside-sandbox path
  when policy permits.

## Review Notes

- Please check whether the spec keeps cross-repo work read-only until the
  intake packet exists.
- Please check whether operator-bootstrap, Agent Trigger Kit, and adopting-repo
  ownership boundaries match `cross-repo-reference-map.md`.
- Please check whether branch cleanup is clearly deferred and not accidentally
  authorized by the cross-repo intake.
- Please check whether the spec preserves the v0.5.7 + v0.5.8 release batch as
  a later §3.2 tag / publish train rather than reopening release scope here.
