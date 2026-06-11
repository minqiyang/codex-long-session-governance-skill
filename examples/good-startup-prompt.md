# Good Startup Prompt

```text
Use $codex-long-session-governance.

Goal:
Continue this large repo from the latest verified state and complete one small checkpoint. Do not rely on chat memory.

Requirements:
- Start with Level 0 repo-state checks.
- Read only Level 1 source-of-truth docs before targeted code reads.
- Byte-cap unknown output.
- Do not read secrets, config files, raw data, or full long logs.
- Stop and report if there is an open PR gate, dirty worktree, truncated output, credential need, destructive operation, or high-risk ambiguity.
- Final report should include changed files, checks run, blockers, assumptions, and next action.
```
