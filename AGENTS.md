# agent-skills Source Entrypoint

This checkout is the `agent-skills` source repo for `CCC0509/agent-skills`. It is not an adopting repo, not an install target, and not a place to test self-installation.

## Source Layout

- Source doctrine lives under `skills/**`.
- Design specs and implementation plans live under `docs/superpowers/**`.
- Release metadata lives under `.claude-plugin/**`.

## Source-Repo Rules

- Do not run `./install.sh` against this repo to adopt its own skills.
- Do not edit generated imported copies in adopting repos as a substitute for source changes here.
- Normative doctrine, relay, review, approval, release, and entrypoint changes are plan-first and end in fresh review before merge.

## Effective Contract Boundary

While editing this repo, the governing contract is the last merged doctrine on `main`, plus user-level instructions and already-effective repo instructions. Branch-local changes are proposals until reviewed and merged. Proposed text may be exercised early only when it is strictly more conservative than the effective contract, and never to authorize, relax, or skip a step the effective contract requires.

Check proposal status with:

```bash
git diff --name-only "$(git merge-base HEAD origin/main)"..HEAD -- skills/ AGENTS.md CLAUDE.md GEMINI.md
```

If that command lists doctrine or entrypoint files, new text in those files is proposal text inside the branch. Inspect it, but do not treat it as already-effective authority for that same branch.

## Worktree Hygiene

- Prefer external scratch worktrees in a system temp directory outside the repo, such as `/tmp/<repo>-<branch>` or the platform equivalent.
- If a project-local worktree is needed, use ignored `.worktrees/`.
- Do not create new worktrees under `.claude/worktrees/`.
- If `.claude/worktrees/` already exists, treat it as local hygiene residue: report it, do not commit it, and do not let it influence scope review.
- Before writing files, confirm the intended checkout with `git status -sb` or `git rev-parse --show-toplevel`.
- If an edit tool does not accept a workdir or there are multiple worktrees open, use paths rooted in the intended worktree and verify `git status -sb` in both the intended worktree and the main checkout after the first edit.
- If an accidental write lands in the wrong checkout, revert only what the write changed: delete the file only if it did not exist before the write and is untracked; if it modified a tracked file, restore it with `git restore <path>` or `git checkout -- <path>`; never delete pre-existing or user-authored content. Report the incident in the handoff.

## ATK Health Boundary

Run `agent-trigger-kit session-check` before source-repo edits when available. In this source repo, an exit 1 trigger-layer failure containing `agent-skills: plugin directory missing` is a known source-repo boundary: Agent Trigger Kit reads `.claude-plugin/marketplace.json`, sees the root-level plugin layout with `source: "./"`, normalizes it to an empty plugin directory, and reports it missing even though the plugin content is the repo root.

Do not create a fake plugin directory to silence that result. Continue with docs/planning work only when ordinary repo gates still pass. Defer ATK root-`"./"` source handling, validator/session-check semantics, and plugin layout changes to Agent Trigger Kit.

When a relay signal is present and this is the only trigger-layer failure, list this canonical accepted residual:
`ATK root-source boundary / documented in AGENTS.md / mechanism owner: Agent Trigger Kit follow-up`

Verification notes may add detail, but they are not a substitute for `Accepted residuals`.
