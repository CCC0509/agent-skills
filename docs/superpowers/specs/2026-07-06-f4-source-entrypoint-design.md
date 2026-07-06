# F4 Source Repo Entrypoint Design

**Status:** Design spec for review.

**Goal:** Give `CCC0509/agent-skills` its own source-repo entrypoint and staging
rules so agents can safely edit doctrine without treating in-flight proposals or
adopting-repo install mechanics as the active source of truth.

## Problem

`agent-skills` is the source repo for portable doctrine, but it currently has no
repo-local `AGENTS.md`, `CLAUDE.md`, or `GEMINI.md`. Agents entering the repo must
infer whether to follow user-level bootstrap instructions, installed plugin
copies, branch-local draft doctrine, or the source files under `skills/**`.

That ambiguity caused two practical failures:

- An in-flight branch could appear to govern its own review because the edited
  doctrine sits in the same repo as the work under review.
- A worktree under `.claude/worktrees/` made local checkout state look like part
  of the repo, even though it was just agent scratch state.

There is also a repeatable source-repo health signal:

```text
agent-skills: plugin directory missing
```

`agent-trigger-kit session-check` emits this because ATK's trigger-layer
validator reads `.claude-plugin/marketplace.json` and cannot represent this
repo's root-level plugin layout: the `agent-skills` entry uses `source: "./"`,
which the validator normalizes to an empty plugin directory and reports as
missing. The plugin content is the repo root itself; nothing is missing on disk.
Whether ATK should support root sources, or this repo should express its layout
differently, is the deferred ATK follow-up. F4 only makes the boundary visible,
without changing ATK's validator or this repo's plugin layout.

## Design

Add `AGENTS.md` as the canonical source-repo entrypoint. It should be short,
operational, and specific to this repo:

- This checkout is the `agent-skills` source repo, not an adopting repo and not
  an install target.
- Source doctrine lives under `skills/**`; design specs and plans live under
  `docs/superpowers/**`; release metadata lives under `.claude-plugin/**`.
- Do not run `./install.sh` against this repo to "adopt" its own skills.
- Do not edit generated imported copies in adopting repos as a substitute for
  source changes here.
- Normative doctrine, relay, review, approval, release, and entrypoint changes
  must be plan-first and end in fresh review before merge.

Create `CLAUDE.md` and `GEMINI.md` as thin pointers to `AGENTS.md`. They should
not duplicate the full entrypoint text. This makes `AGENTS.md` the single
maintenance surface while still giving Claude Code and Gemini an obvious local
entry file.

## Effective Contract Boundary

While editing this repo, the governing contract is the last merged doctrine on
`main`, plus user-level instructions and already-effective repo instructions.
Branch-local changes are proposals until reviewed and merged. Proposed text may
be exercised early only when it is strictly more conservative than the effective
contract, and never to authorize, relax, or skip a step the effective contract
requires.

The mechanical check for proposal status is:

```bash
git diff --name-only "$(git merge-base HEAD origin/main)"..HEAD -- skills/ AGENTS.md CLAUDE.md GEMINI.md
```

If that command lists doctrine or entrypoint files, new text in those files is
proposal text inside the branch. Reviewers and implementers may inspect it, but
they must not treat it as already-effective authority for the same branch.

## Worktree Hygiene

F4 should not delete existing local worktrees. It should prevent future repo
pollution by documenting and ignoring local agent worktree directories:

- Prefer external scratch worktrees in a system temp directory outside the repo,
  such as `/tmp/<repo>-<branch>` or the platform equivalent, for planning and
  implementation work.
- If a project-local worktree is needed, use an ignored `.worktrees/` directory.
- Do not create new worktrees under `.claude/worktrees/`.
- If `.claude/worktrees/` already exists, treat it as local hygiene residue:
  report it, do not commit it, and do not let it influence scope review.
- Before writing files, confirm the intended checkout with `git status -sb` or
  `git rev-parse --show-toplevel`. If an edit tool does not accept a workdir or
  there are multiple worktrees open, use paths rooted in the intended worktree
  and verify `git status -sb` in both the intended worktree and the main
  checkout after the first edit. If an accidental write lands in the wrong
  checkout, remove only the file or change just created after confirming it is
  not user work, then report the incident in the handoff.

Add `.gitignore` entries for `.claude/worktrees/`, `/.worktrees/`, and
`/worktrees/`. This keeps the current source checkout from advertising local
agent scratch state as repo work while preserving the option to track future
intentional `.claude/` configuration files.

## ATK Health Boundary

`agent-trigger-kit session-check` remains useful at session start and closeout.
For this source repo, the current `agent-skills: plugin directory missing` result
should be classified as a known trigger-layer/source-repo boundary, not silently
ignored and not "fixed" by creating a fake plugin directory in this repo.

F4 should require agents to:

- Run `agent-trigger-kit session-check` before source-repo edits when available.
- If the only trigger-layer failure is `agent-skills: plugin directory missing`,
  record it as a known source-repo boundary in the relay `Accepted residuals`
  whenever a relay signal is present; verification notes may add detail, but
  they are not a substitute for `Accepted residuals`. Use this canonical form:
  `ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent
  Trigger Kit follow-up`.
- Continue with docs/planning work only when ordinary repo gates still pass.
- Defer changes to ATK root-`"./"` source handling, validate/session-check
  semantics, and plugin layout to an Agent Trigger Kit follow-up, because that
  is mechanism, not doctrine source text.

## Scope

In scope:

- Add `AGENTS.md` as the canonical source-repo entrypoint.
- Add `CLAUDE.md` and `GEMINI.md` as thin pointers to `AGENTS.md`.
- Add `.gitignore` entries for local agent worktree scratch directories.
- Add a source-entrypoint smoke test that checks the entrypoint, pointers,
  ignore rules, staging-boundary wording, ATK health-boundary wording, and
  absence of self-install managed blocks in root entry files.
- Add a v0.4.10 `ROADMAP.md` landed entry for F4.
- Remove or retire the F4 Extraction Candidate row after the landed entry exists.
- Bump `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` to
  `0.4.10`.

Out of scope:

- F5 cross-repo reference map content.
- operator-bootstrap template or enum changes.
- Agent Trigger Kit validator, session-check, outcome taxonomy, or plugin layout
  changes.
- Tagging or releasing `v0.4.10`.
- Deleting existing local `.claude/worktrees/**` directories.
- Installing `agent-skills` into itself or modifying adopting repos.

## Verification

Implementation should verify:

- `agent-trigger-kit session-check` result is captured. The expected current
  result is exit 1 with `agent-skills: plugin directory missing`; this is a
  documented source-repo health boundary, not an implementation blocker by
  itself.
- `./tests/install-smoke.sh`
- `./tests/source-entrypoint-smoke.sh`
- `git diff --check`
- A self-install pollution probe that fails if root `AGENTS.md`, `CLAUDE.md`, or
  `GEMINI.md` contains `<!-- agent-skills:begin -->`.
- A token scan such as:

```bash
rg -n "source repo|not an install target|last merged doctrine|proposal text|agent-skills: plugin directory missing|root-level plugin layout|\\.claude/worktrees|edit tool|self-install|v0\\.4\\.10|F4 source-repo" AGENTS.md CLAUDE.md GEMINI.md .gitignore ROADMAP.md tests .claude-plugin
```

The final implementation closeout should use `Status: review-needed` and
`User action: self-review -> to-reviewer`.

## Review Notes

- F4 intentionally handles source-repo entrypoint and staging mechanics only.
- F5 remains a separate cross-repo reference map.
- ATK mechanism changes remain separate even though F4 documents the current
  `session-check` root-source failure.
- Any existing directory under `.claude/worktrees/` is local residue. F4 should
  prevent that class of residue from appearing in status, but should not delete
  it without an explicit cleanup request.
