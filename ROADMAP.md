# agent-skills Roadmap

This file tracks extraction candidates that should not expand the current
release scope.

## Landed

- v0.3.0: repo-memory protocol, memory-index install baseline, MCP graph-first /
  fallback doctrine, Codex / Gemini model adapters.
- v0.3.1: reviewer conduct doctrine, attribution labels for review findings,
  task-tracking capability adapters, active-clock prioritization, and
  verification side-effect / kill-switch discipline.
- v0.4.0: change-discipline doctrine for convention migrations,
  verifiability-driven commit structure, approval-bound identifiers, and public
  evidence hygiene boundaries.
- v0.4.1: reviewer opening / closeout conduct hardening plus small installer
  marker, README companion-boundary, and verify-not-self-verify wording polish.
- v0.4.2: review I/O contract for request hand-offs, assumed-type handling, and
  paste-ready reports; public evidence provenance wording; requester-side
  prompt-contract candidate absorbed into multi-angle-review.
- v0.4.3: review opening header is probeable with `Review stance:`, review
  closeout wording ends at `Next actions`, and named-absence deferral points to
  Agent Trigger Kit's durable no-report classification home.
- v0.4.4: shared hand-off request contract moved into Agent Operating Manual;
  review enum adds `plan/rule-review`, and install pointers name `plan/rule-review`.
- v0.4.5: shared relay signals define `ready-for-user-approval` for merge
  approval timing and `complete-no-action-needed` for fully closed work.
- v0.4.6: shared execution route contract tells the next agent how to execute
  remaining work without asking the user to choose routine process mechanics.
- v0.4.7: relay signals preserve accepted residuals and clarify review-needed
  versus not-ready boundaries before downstream agents act.
- v0.4.8: handoff / relay control contract clarifies `Review:` versus
  `Status:` precedence, adds `Target repo:` routing, hardens `not-ready`
  relay authority, and requires plan-first plus fresh review for normative
  control-contract changes.
- v0.4.9: relay action-owner clarity adds `User action:` routing, full-context
  copy defaults for spec / plan / review handoffs, and consistency rules so
  users know whether to self-review, forward to a reviewer, forward to an acting
  agent, reply with required text, or stop.
- v0.4.10: F4 source-repo entrypoint adds canonical root AGENTS.md guidance,
  thin Claude / Gemini pointers, local worktree scratch ignore rules, and
  source-entrypoint smoke coverage for proposal boundaries, self-install
  pollution, and the documented ATK root-source health boundary.
- v0.4.11: F5 cross-repo reference map adds a conditional
  agent-operating-manual appendix for routing operator-bootstrap, agent-skills,
  Agent Trigger Kit, adopting-repo, and MCP ownership without adding external
  repo dependencies or daily startup load.

## Extraction Candidates

| Bucket | Candidate | Likely home | Why deferred |
|---|---|---|---|
| agent-skills doctrine | Preflight / closeout self-report contract | agent-skills | Pure text doctrine, but separate from v0.2.0 skill-authoring and outcome triage. |
| agent-skills doctrine | Plan / PR lifecycle discipline: branch-first, PR stop, explicit approval, squash merge | agent-skills | High-value shared state machine; needs careful wording across consumer repos. |
| agent-skills doctrine | Plan/spec lifecycle header convention text | agent-skills | Doctrine belongs here; validator stays out of the markdown-only repo. |
| agent-skills doctrine | Shared checkout concurrency etiquette | agent-skills | Useful but outside v0.4 change-discipline scope; needs wording that fits multiple harnesses and shared-worktree policies. |
| agent-skills doctrine | Named absence statuses for missing closeout evidence | agent-skills / ATK | Agent Trigger Kit now owns the canonical mechanism home for durable no-report classification; agent-skills doctrine should still wait for the closeout self-report work so categories do not drift. |
| agent-skills doctrine | Harness warning triage contract | agent-skills | Needs more portable examples so known harness noise is classified without normalizing ignored warnings. |
| agent-skills doctrine | Probe catalog appendix | agent-skills | v0.4 adds examples inline; a full catalog should wait until enough probes justify an appendix. |
| agent-skills doctrine | Extraction-candidate closeout protocol | agent-skills | Wake condition reached by the v0.4.1 reviewer-conduct extraction and v0.4.2 review I/O contract shaping. Keep the protocol design out of v0.4.2; schedule it for v0.5.0. |
| agent-skills doctrine | F2 handoff-contract file split | agent-skills | Deferred from v0.4.8; splitting §3.1 needs anchor / link / residual scan after relay control semantics stabilize. |
| agent-skills doctrine | Branch / worker lifecycle hygiene | agent-skills | Separate from Shared checkout concurrency etiquette: the existing row covers simultaneous editing in shared checkouts; this covers worker spawn / wait / consume / close, concurrency caps, post-merge push state, and cleanup of merged worktrees / local branches after scoped work reaches review or merge; any validator mechanism belongs with ATK. |
| agent-skills doctrine | Relay copy-block completeness self-check | agent-skills | Needs a pre-handoff checklist that validates legal `Status:` values, `User action:` / `Next agent action:` pairing, a single fenced copy block when forwarding to another agent, the `Review:` contract for the immediate next agent, and preserves review findings inside the fenced copy block. |
| ATK templates | `agent-impact-file-sets.mjs` classifier template | agent-trigger-kit | Mechanism/script, not doctrine. |
| ATK templates | Plan/spec lifecycle checker template | agent-trigger-kit | Validator template belongs with trigger-layer mechanisms. |
| ATK templates | MCP config validator template | agent-trigger-kit | Reusable validator; pair with agent-skills fallback doctrine later. |
| ATK templates | Codebase MCP spawn/config/index health checker template | agent-trigger-kit | Mechanism for validating server launch, portable command config, and graph readiness belongs with tooling templates. |
| Repo-local, do not extract | Manual Smoke Attestation | adopting repo | Single-repo QA evidence convention. |
| Repo-local, do not extract | Domain playbooks, operator prompts, review-log machinery | adopting repo | Domain-bound operational memory and hooks. |
