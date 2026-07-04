# Codex Model Adapter

Use this when Codex reads the Agent Operating Manual and reaches Claude Code
model / effort / workflow sections.

## Capability mapping

| Capability | If available in this Codex session | If unavailable |
|---|---|---|
| Fresh workers / subagents | Delegate exploration, read-back, and independent review to fresh contexts. Keep prompts scoped and ask for `path:line` evidence. | Keep the task smaller, use local commands and CI as verification, and disclose that no fresh-context review was available. |
| Per-worker model control | Use the harness-provided model selector for mechanical vs ambiguous work. Do not copy Claude aliases. | State the needed capability rather than inventing model names. |
| Parallel workers | Fan out independent finder angles and merge only verified findings. | Run the angles sequentially and write interim notes before synthesis. |
| Task-tracking surface | Use TodoWrite or the harness task tracker for current-session execution, and sync durable plan / spec checkboxes at each checkpoint or commit. | Treat the plan / spec checkbox list as the task tracker; tick completed steps as they become true and commit those ticks with the work. |
| Tool-backed verification | Prefer tests, linters, validators, GitHub checks, and command output over reasoning. | State the verification gap and do not claim pass. |

## Rules

- Do not use Claude Code model aliases as Codex facts.
- Treat this adapter as capability-based; current Codex surfaces may change.
- Use repo instructions and available tools before defaulting to generic advice.
