# Cross-Repo Reference Map

This appendix routes ownership when a task crosses repository boundaries. It
does not replace sibling manual docs, repo-local instructions, release notes,
Agent Trigger Kit validators, or adopting-repo memory.

Read this file when a task asks where a change belongs, mentions
`operator-bootstrap`, Agent Trigger Kit, adopting repos, generated imported
skill copies, MCP / codebase-index tooling, or cross-repo residual ownership.

## Responsibility Map

| Layer | Owns | Does not own | Change here when | Residual / follow-up owner |
|---|---|---|---|---|
| `operator-bootstrap` | User-level and machine-level bootstrap instructions, generated instruction templates, operator distribution mechanics. | Portable doctrine, Agent Trigger Kit validators, adopting-repo local playbooks, MCP indexes. | The bootstrap source text, generated user-level instructions, or operator distribution path must change. | `operator-bootstrap` owner. |
| `agent-skills` | Portable doctrine skills, review / relay / approval semantics, dispatch economy doctrine, specs, plans, install-facing skill content, release metadata. | Runtime validators, outcome stores, hook mechanisms, adopting-repo domain memory, operator bootstrap templates, MCP graph caches. | The reusable doctrine itself should change for future adopting repos. | `agent-skills` ROADMAP or follow-up spec. |
| Agent Trigger Kit | Trigger validators, session-check and closeout behavior, outcome taxonomy, hook templates, trigger-layer implementation details. | Portable doctrine prose except mechanism docs, adopting-repo domain policy, generated imported skill copies. | Validation, session health, outcome recording, hooks, or trigger-layer mechanisms need different behavior. | Agent Trigger Kit follow-up. |
| Adopting repos | Local policy, generated imports, `.agent-skills/pin`, repo-specific memory, domain playbooks, review logs, local integration evidence. | Source doctrine for imported skills, operator bootstrap templates, shared ATK mechanisms, central MCP caches. | The change is domain-specific or only affects that repo's local workflow. | The adopting repo's own issue, ROADMAP, or audit memory. |
| MCP / codebase-index tooling | Optional discovery indexes and graph tooling for symbol, call-path, or architecture exploration. | Canonical repo memory, portable doctrine, install-time source of truth. | Tool configuration, launch, or index health needs mechanism work outside portable doctrine. | Agent Trigger Kit mechanism follow-up for validators; user or machine config for local paths; adopting repo when the config is repo-local. |

## Routing Checklist

- Portable doctrine, review semantics, relay fields, approval gates, dispatch
  economy, install-facing skill text, or release metadata: change
  `agent-skills`.
- User-level bootstrap text, machine bootstrap templates, or operator
  distribution mechanics: change `operator-bootstrap`.
- `session-check`, closeout, validators, hooks, outcome taxonomy, trigger-layer
  templates, or root-source plugin layout handling: route to Agent Trigger Kit.
- Generated imported files under an adopting repo are install artifacts. Fix the
  source in `agent-skills`, then reinstall or upgrade the adopting repo.
- Repo-local domain playbooks, local memory, audit evidence, and generated pin
  state belong to the adopting repo.
- MCP / codebase-index availability, graph state, fallback, and disclosure
  rules are documented in [`15-repo-memory.md`](15-repo-memory.md). Do not make
  this appendix a second normative home for those fallback rules.
- MCP tooling is not canonical memory; repo-owned files remain the durable
  source of truth for future agents.

## Do Not Do

- Do not edit generated imported copies in an adopting repo as a substitute for
  changing source doctrine in `agent-skills`.
- Do not create fake plugin directories to silence the known F4
  `agent-skills: plugin directory missing` Agent Trigger Kit boundary.
- Do not commit machine-local MCP paths, graph indexes, caches, usernames, or
  private local evidence to `agent-skills`.
- Do not make codebase MCP required for ordinary doctrine maintenance.
- Do not treat branch-local proposal text as effective doctrine before review
  and merge.
- Do not add install-time cross-repo lookups for this map; it is doctrine text
  inside the existing skill directory.
