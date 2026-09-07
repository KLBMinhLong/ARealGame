@AGENTS.md

# Claude Code adapter

The main conversation is the sole writer and executor for an approved feature.
Use the read-only agents in `.claude/agents/` when their distinct review would materially help:
- `godot-scout`: locate actual integration points and constraints before coding.
- `gameplay-reviewer`: challenge event, physics, timing and player-facing behavior.
- `qa-reviewer`: inspect the implementation/evidence against acceptance criteria.

Pass the task path, the relevant file paths and a bounded question. Subagents do not automatically know the entire conversation.
Do not run all reviewers for every trivial edit. Do not treat a review report as executed test evidence.
If delegation is unavailable, perform a separately labeled self-review; do not pretend another agent reviewed it.
Do not change the user's chosen model or permissions. Read-only tool restrictions are configured in the subagent files, not merely requested in prose.
