# Gemini Model Adapter

Use this when Gemini CLI or Gemini Code Assist reads the Agent Operating Manual
and reaches Claude Code model / effort / workflow sections.

## Capability mapping

| Capability | If available in the Gemini environment | If unavailable |
|---|---|---|
| Fresh workers / independent contexts | Use them for exploration, read-back, and review. Require concise conclusions with evidence. | Keep work scoped to the current context and rely on tests, CI, or human review for independence. |
| Model or effort controls | Map doctrine to Gemini's current documented controls. Do not copy Claude aliases. | Avoid model-selection claims; describe the reasoning difficulty and verification need. |
| Background review | Use it for review-only passes over pinned diffs or plans. | Run manual read-back with local tools and disclose the missing independent review surface. |
| Task-tracking surface | Use the environment's task tracker for current-session execution, and sync durable plan / spec checkboxes at each checkpoint or commit. | Treat the plan / spec checkbox list as the task tracker; tick completed steps as they become true and commit those ticks with the work. |
| Tool-backed verification | Treat command output and repository checks as primary. | Report the exact command that could not be run and the resulting gap. |

## Rules

- Do not claim exact Gemini model names or pricing from this doctrine.
- Prefer capability predicates over version-specific instructions.
- Follow the adopting repo's Gemini entrypoint when present.
