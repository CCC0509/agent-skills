# F5 Cross-Repo Reference Map Design

**Status:** Design spec for review.

**Goal:** Add a standalone cross-repo ownership map to `agent-skills` so agents
can route doctrine, bootstrap, mechanism, adopting-repo, and MCP questions
without editing the wrong repository or turning optional tooling into canonical
memory.

## Problem

F4 made this repo's source-entrypoint boundary explicit, but agents still need a
portable way to answer "which repo owns this?" when a task mentions several
layers at once:

- `operator-bootstrap` user / machine bootstrap text.
- `agent-skills` portable doctrine.
- Agent Trigger Kit mechanism such as validators, session-check, outcome stores,
  hooks, and trigger-layer templates.
- Adopting repos that contain local playbooks, imported skill copies, domain
  memory, and repo-specific review evidence.
- MCP or codebase-index tools that may help exploration but are not canonical
  repo memory.

Without a map, a future agent can easily edit generated imported copies in an
adopting repo, ask for mechanism changes in `agent-skills`, or commit
machine-local MCP configuration while trying to solve a portable doctrine
problem.

There are also related but separate operator concerns: subagent / worker
lifecycle, post-merge push / cleanup state, and relay copy-block completeness.
Those topics affect dispatch economy and handoff quality, but they are not the
same problem as cross-repo ownership. F5 should create durable trackers for
them without expanding this release into new lifecycle or relay doctrine.

## Design

Add a standalone appendix:

```text
skills/agent-operating-manual/cross-repo-reference-map.md
```

This appendix is the canonical F5 content. It should be referenced from the
agent-operating-manual README and trigger shim, but it should not become a
must-read file for every session. Agents should read it when a task crosses repo
boundaries, asks "where does this belong?", mentions MCP / codebase-memory
state, or needs to route residuals across doctrine, bootstrap, mechanism, and
adopting-repo owners.

The appendix should contain:

- A short purpose statement: this file routes ownership; it does not replace
  sibling manual docs, repo-local instructions, release notes, ATK validators,
  or adopting-repo memory.
- A responsibility table with these rows: `operator-bootstrap`, `agent-skills`,
  Agent Trigger Kit, adopting repos, and MCP / codebase-index tooling.
- For each row: what the layer owns, what it does not own, when to change it,
  and the correct residual / follow-up owner.
- A routing checklist for common requests, including portable doctrine,
  bootstrap templates, validator/session-check behavior, imported skill copies,
  repo-local domain playbooks, codebase MCP availability, and optional graph
  indexes.
- A "do not do" list covering generated imported-copy edits, fake ATK plugin
  directories, committed machine-local paths, committed MCP caches, and treating
  branch-local proposal text as effective doctrine.

## Ownership Rules

The appendix should define these stable boundaries.

`operator-bootstrap` owns user-level and machine-level bootstrap instructions,
templates, and deployment mechanics. It does not own portable doctrine or
runtime validators. Change it only when the bootstrap source text, generated
user-level instructions, or operator distribution path must change.

`agent-skills` owns portable doctrine skills, review / relay / approval
semantics, dispatch economy doctrine, source specs and plans, install-facing
skill content, and release metadata. It does not own ATK validators, outcome
stores, repo-local domain playbooks, operator bootstrap templates, or MCP graph
caches.

Agent Trigger Kit owns mechanism: trigger validators, session-check and closeout
behavior, outcome taxonomy, hook templates, and trigger-layer implementation
details. It does not own portable doctrine prose except where mechanism docs
need to explain the mechanism itself. F4's root-source session-check boundary
and plugin-version-freshness advisory stay with this owner.

Adopting repos own local policy, generated imports, `.agent-skills/pin`,
repo-specific memory, domain playbooks, review logs, and local integration
evidence. Generated imported files are install artifacts, not source-of-truth
doctrine. Portable fixes flow back to `agent-skills`; local fixes stay in the
adopting repo.

MCP / codebase-index tooling is optional discovery infrastructure. It can help
trace symbols, call paths, and architecture, but it is not canonical memory and
must not be required for ordinary doctrine maintenance. The appendix should
route graph-state, fallback, and disclosure rules to
`skills/agent-operating-manual/15-repo-memory.md` instead of creating a second
normative home for those rules. Machine-local MCP paths, indexes, and caches
should not be committed to `agent-skills` by default.

## Lifecycle And Relay Follow-Ups

F5 should add a ROADMAP Extraction Candidate row for `Branch / worker lifecycle
hygiene`. The row should route to `agent-skills` unless implementation later
proves that a mechanism portion belongs in Agent Trigger Kit.

The deferred topic should cover worker lifecycle language such as spawn / wait /
consume / close, concurrency caps, when to prefer inline execution for small
plans, how Codex surfaces should report unavailable fresh-context workers,
post-merge push state, and cleanup of merged worktrees / local branches. Its
`Why deferred` wording must distinguish it from the existing `Shared checkout
concurrency etiquette` candidate: that existing row is about simultaneous
editing in shared checkouts, while this follow-up is about worker and branch
lifecycle after scoped work reaches review or merge.

F5 should also add a ROADMAP Extraction Candidate row for `Relay copy-block
completeness self-check`. The row should route to `agent-skills` and capture the
need for a pre-handoff checklist that validates the relay `Status:` enum, the
`User action:` / `Next agent action:` pairing, the single fenced copy block when
`to-reviewer` or `to-agent` is used, and the `Review:` contract for the
immediate next agent. F5 must not define those relay rules in the appendix body
beyond pointing to the durable follow-up.

## Scope

In scope:

- Add `skills/agent-operating-manual/cross-repo-reference-map.md`.
- Add a conditional pointer from `skills/agent-operating-manual/README.md`.
- Add a conditional pointer from `skills/agent-operating-manual/SKILL.md`
  without making the appendix part of the default Must Read set.
- Add smoke coverage for the source appendix, README pointer, SKILL pointer,
  installed-copy presence, and key ownership tokens.
- Add a v0.4.11 `ROADMAP.md` landed entry for F5.
- Remove or retire the F5 Extraction Candidate row after the landed entry
  exists.
- Add a `Branch / worker lifecycle hygiene` Extraction Candidate row.
- Add a `Relay copy-block completeness self-check` Extraction Candidate row.
- Bump `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` to
  `0.4.11`.

Out of scope:

- Editing `operator-bootstrap`.
- Editing Agent Trigger Kit validators, session-check, outcome taxonomy, hook
  templates, or plugin layout.
- Editing adopting repos or generated imported skill copies.
- Installing or configuring codebase MCP servers.
- Committing MCP indexes, caches, machine-local paths, usernames, or private
  local evidence.
- Changing worker lifecycle, post-merge push / cleanup, or relay copy-block
  doctrine beyond adding the durable extraction candidates.
- Tagging or releasing `v0.4.11`.

## Verification

Implementation should verify:

- `agent-trigger-kit session-check` at session start and closeout. The expected
  current source-repo boundary remains exit 1 with `agent-skills: plugin
  directory missing`; if closeout also reports the plugin-version-freshness
  advisory from the same root-source cause, relay it as the existing ATK
  residual family.
- `./tests/install-smoke.sh`
- The F5 smoke test added by implementation, covering source reference-map
  tokens, README pointer, SKILL pointer, installed-copy presence, and key
  ownership tokens.
- A smoke assertion that `skills/agent-operating-manual/SKILL.md` keeps the
  appendix out of the default `Must Read` list; the appendix pointer should
  appear only in a conditional section.
- A smoke assertion that the Extraction Candidates table no longer contains the
  F5 cross-repo reference map row after the v0.4.11 landed entry exists.
- `git diff --check`
- A public-evidence hygiene scan that fails on committed absolute local paths,
  home-directory names, or usernames in the new spec / plan / appendix text.
- A token scan such as:

```bash
rg -n "cross-repo reference map|operator-bootstrap|Agent Trigger Kit|adopting repos|codebase MCP|15-repo-memory\\.md|not canonical memory|Branch / worker lifecycle hygiene|Relay copy-block completeness self-check|Must Read|v0\\.4\\.11|0\\.4\\.11" skills/agent-operating-manual ROADMAP.md tests .claude-plugin
```

The final implementation closeout should use `Status: review-needed`,
`User action: self-review -> to-reviewer`, and `Review: full`.

## Review Notes

- Other repos do not need direct edits for F5. The map may name external owners,
  but implementation must keep all committed changes inside `agent-skills`.
- Codebase MCP remains optional tooling. F5 should document how to route and
  disclose availability, not install a server, require a graph index, or
  duplicate the canonical fallback rules in `15-repo-memory.md`.
- Subagent limit, post-merge push / cleanup, and relay copy-block completeness
  behavior are intentionally tracked as follow-up candidates, not solved inside
  F5.
- The appendix must avoid becoming daily startup load. It is a conditional
  reference for cross-repo routing questions, not part of the default Must Read
  set.
- The circular install-dependency concern is addressed by making F5 a
  doctrine-text appendix inside the existing skill directory. Implementation
  should not add new external repo dependencies or install-time cross-repo
  lookups.
