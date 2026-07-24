# Workflow Adoption Framework, Public Evidence Hygiene, and Evidence Seeds

Continues [`26-fresh-gate.md`](26-fresh-gate.md), itself continuing
[`25-change-discipline.md`](25-change-discipline.md). Split out only for
the ~250-line cap in `40-maintenance.md` §4; no rule text changed from the
original §3.5, §4, and Evidence Seeds.

---

## §3.5 Workflow Adoption Framework

Workflow adoption applies before an agent first plans or performs approval-bound PR publication or update, merge, tag, release, deploy, publish, rollback, cleanup, promotion, install, plugin refresh, imported-copy update, or cross-agent workflow handoff work in an adopting repo, and before review handoffs that change workflow authority.

Workflow adoption is read-only by default. It discovers the repo's existing workflow, maps it to canonical gates, or initializes a conservative repo-local workflow profile when no workflow is found. It does not authorize release, deploy, publish, rollback, install, plugin refresh, promotion, cleanup, public push, merge, tag, imported-copy update, live probe, credentialed check, or external-service action.

Ordinary low-risk docs work does not need a workflow adoption pass unless it changes workflow authority, review gates, approval gates, promotion boundaries, release or deploy behavior, cleanup permission, or a receiver-specific handoff.

### Task 0 Incident Capture

Any workflow-adoption formal spec or implementation plan starts with Task 0 incident capture. Capture relevant handoff, relay, review, source-evidence, or multi-recipient failures before generalizing workflow rules.

Task 0 must name which receiver needed which evidence, classify whether the failure was missing durable evidence, missing copy-block content, surface mismatch, authority mismatch, optional-probe bundling, or policy block, and record whether the incident is verified, author-attested, or pending optional re-probe.

Task 0 creates pressure cases. It does not run optional probes, external-service prompt execution, plugin refresh, public actions, installs, deploys, releases, credentialed checks, or cleanup unless a later reviewed plan and exact gate authorize that action.

### Workflow Inventory

Minimum repo-local evidence must be checked before claiming no workflow exists:

- root entrypoint instructions such as `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, or repo equivalents;
- README, CONTRIBUTING, lifecycle, runbook, operations, release, deploy, rollback, and cleanup docs;
- package scripts, Makefiles, task files, justfiles, Docker files, compose files, CI configs, and deployment configs;
- GitHub, CI, release, changelog, version, branch, and tag documentation;
- existing specs, plans, review records, status memory, roadmaps, ledgers, and promotion attestations;
- plugin, imported-copy, installer, marketplace, harness, generated trigger layer, cleanup, migration, artifact inventory, or retention docs.

If a relevant surface is absent, record absence as a checked fact. If it exists but cannot be read under current permissions, record the blocker and stop or continue only within the remaining safe read-only scope.

Remote metadata, hosted CI, branch protection, release surfaces, package registries, deployment platforms, credential state, and live production state may be useful, but workflow adoption does not authorize checking them. When remote or credentialed evidence remains unverified, the profile must say which local inventory was completed and which facts remain unverified.

No workflow found is not permission to proceed.

### Workflow Profile

The workflow profile is the durable repo-local artifact that records what was found and how it maps to gates.

Default profile home:

- first choice: the adopting repo's canonical playbook section;
- fallback: `lifecycle/workflow-profile.md`;
- override: any repo-local home declared by the adopting repo's entrypoint, playbook, or reviewed plan.

Use one profile state:

- existing workflow mapped;
- partial workflow mapped;
- initialized because no workflow found;
- blocked pending owner decision;
- out of scope for this repo.

The profile should cover repo identity and owner, source evidence refs, profile state and date, PR/review/branch/merge workflow, tag/release/publish/package/marketplace/app-store workflow, deploy/environment/production-command/rollback workflow, cleanup workflow, install/plugin-refresh/imported-copy/runtime-tool workflow, private evidence and promotion workflow, capability and execution-surface preflight requirements, exact approval objects, verification commands, evidence destinations, accepted residuals, and open owner decisions.

The profile is descriptive before prescriptive. It must not invent a deploy workflow, release cadence, promotion permission, cleanup authority, or remote permission to fill a blank.

An absent-workflow profile must include the repo-local evidence checked, action classes checked, surfaces not checked and why, whether remote or credentialed evidence remains unverified, the default stop point for the action class, the owner decision needed to initialize a workflow, and any safe next planning step.

### Canonical Gate Map

Canonical gate map:

- PR, review, branch, and merge map to branch/head identity, reviewed-range carry-forward when hosted metadata is created from reviewed content, plan/rule-review or full review, exact merge approval naming the object, pre-merge freshness and object checks, merge-shape proof when needed, and public/private evidence placement.
- tag, release, publish, package, marketplace, and app-store map to reviewed release candidate identity, exact tag approval, tag freshness, tag identity, separate tag-push approval when needed, post-tag smoke, publish inventory, exact publish approval naming the surface and object, and post-publish verification or accepted residuals.
- deploy, production command, environment switch, and rollback map to execution-surface and capability preflight, permission/account/credential/environment/policy boundaries, exact approval naming the target environment or revision, pre-action freshness or artifact identity, post-action observation, and audit memory.
- cleanup for branches, worktrees, generated residue, temp consumers, private evidence, outcome stores, and artifacts maps to cleanup freshness, preservation or abandonment proof, and exact approval unless a reviewed local policy defines a narrow safe class.
- install, plugin refresh, imported-copy update, and runtime tool setup map to install-surface classification, exact consent for user/global/plugin surfaces, source tag or ref, local verification, registry or closeout records when applicable, and reload or restart boundaries.
- private evidence, public-safe attestation, and promotion map to private evidence retained by the owning repo or workspace, public-safe attestation for public objects backed by private evidence, a public-safe attestation and an adopting-repo-owned promotion ledger or equivalent, exact approval for public action, and hygiene rules that keep private evidence out of public surfaces.

Local repo rules can be stricter than the canonical gate map. Workflow adoption must not weaken stricter local rules, and it must not weaken portable gates to match local habit.

Surface-sensitive workflow actions must call capability/surface preflight before route or execution decisions. If preflight fails or is unavailable, record the gap and stop; do not broaden to another surface.

### Split Handoffs And Provenance

Receiver-specific handoff splitting is mandatory when one receiver is reviewer-facing and another is acting-agent-facing, one packet is approval-bound, one surface is user-executed, one receiver needs private source evidence another should not receive, one receiver handles an optional incident probe, or authority differs between receivers.

Each packet must carry the receiver role, target repo and object, source evidence needed by that receiver, authority held by that receiver, exact next action or review request, relevant accepted residuals and blockers, and the review contract required by relay doctrine. Shared facts may be duplicated for reliability. One bundle must not ask a reviewer, user, acting agent, and optional incident verifier to infer which authority belongs to them.

Session provenance minimum:

- session role;
- execution surface category;
- source evidence received;
- authority held;
- actions performed and actions explicitly not performed;
- verification performed and verification gaps;
- policy, credential, egress, capability, or freshness blockers;
- next receiver and review contract when another agent must continue.

Never store secret values, tokens, keys, raw credential-store output, private account identifiers, or raw private logs as durable workflow evidence.

Do not put private workspace paths, raw private review blocks, organization identifiers, or absolute local paths in public doctrine or public attestations.

Structured fixtures, validators, closeout capture, copy-block lint, generated trigger-layer support, and durable taxonomy belong to a later reviewed mechanism plan.

## §4 Public Evidence Hygiene

Doctrine releases can cite evidence, but public evidence must be sanitized.

Treat public references as provenance pointers unless the public artifact itself
contains the full, reviewable evidence. A PR number, commit, or tag can say where
a decision came from; it must not imply that private logs, local paths, or
credentialed probes are publicly verifiable. Keep raw private evidence in the
adopting repo's audit memory and publish only the sanitized conclusion plus the
public-safe pointer.

Allowed in public doctrine / PR bodies:

- public repo name
- public PR number
- public commit hash
- public tag
- sanitized outcome labels, such as `byte-identity passed`

Not allowed in public doctrine / PR bodies:

- absolute local filesystem paths
- usernames or home-directory names
- hostnames, private network names, Tailscale hosts, or machine IDs
- private repo paths or private artifact paths
- raw logs, account identifiers, IP addresses, order IDs, or secret-like values

When evidence is local or private, write a compact public summary and keep the
raw detail in the adopting repo's audit memory.

## Evidence Seeds

| Evidence | Why it matters | Public-safe form |
|---|---|---|
| stock-scanner PR #163 | convention/adoption migration used byte-identity, trigger-layer, docs, and post-merge gates | `stock-scanner PR #163 / commit a4be2d68` |
| v0.3.1 reviewer hardening | release kept related doctrine in one small scope and deferred unrelated candidates | `agent-skills v0.3.1` |
| approval-bound merge flow | PR closeout requires explicit approval for the PR number before squash merge | `approval-bound PR number` |
