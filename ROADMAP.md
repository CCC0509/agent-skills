# agent-skills Roadmap

This file tracks extraction candidates that should not expand the current
release scope.

## Landed

- v0.3.0: repo-memory protocol, memory-index install baseline, MCP graph-first /
  fallback doctrine, Codex / Gemini model adapters.

## v0.3+ Extraction Candidates

| Bucket | Candidate | Likely home | Why deferred |
|---|---|---|---|
| agent-skills doctrine | Preflight / closeout self-report contract | agent-skills | Pure text doctrine, but separate from v0.2.0 skill-authoring and outcome triage. |
| agent-skills doctrine | Plan / PR lifecycle discipline: branch-first, PR stop, explicit approval, squash merge | agent-skills | High-value shared state machine; needs careful wording across consumer repos. |
| agent-skills doctrine | Plan/spec lifecycle header convention text | agent-skills | Doctrine belongs here; validator stays out of the markdown-only repo. |
| ATK templates | `agent-impact-file-sets.mjs` classifier template | agent-trigger-kit | Mechanism/script, not doctrine. |
| ATK templates | Plan/spec lifecycle checker template | agent-trigger-kit | Validator template belongs with trigger-layer mechanisms. |
| ATK templates | MCP config validator template | agent-trigger-kit | Reusable validator; pair with agent-skills fallback doctrine later. |
| ATK templates | Codebase MCP spawn/config/index health checker template | agent-trigger-kit | Mechanism for validating server launch, portable command config, and graph readiness belongs with tooling templates. |
| Repo-local, do not extract | Manual Smoke Attestation | adopting repo | Single-repo QA evidence convention. |
| Repo-local, do not extract | Domain playbooks, operator prompts, review-log machinery | adopting repo | Domain-bound operational memory and hooks. |
