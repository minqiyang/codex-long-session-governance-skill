# Long Session Goal Template

```text
/goal Continue <repo/project> from latest verified state and complete exactly one PR-sized checkpoint: <stage/task name>.

Before work:
- Use $codex-long-session-governance.
- AGENTS.md should already be loaded if present.
- First read only: <handoff>, <repo_map>, <controller>, <stage_plan>.
- Then targeted-read only files needed for this checkpoint.
- Do not broad-read long logs or generated reports.

Context:
<1-3 lines of latest verified state>

Objective:
<1-3 lines>

Scope:
- <deliverable 1>
- <deliverable 2>
- <deliverable 3>
- <deliverable 4>
- <deliverable 5>

Out of scope:
<hard no-go items>

Validation:
<commands>

Stop gates:
- dirty worktree or unrelated changes;
- open PR gate not verified merged;
- failing checks not safely fixable within scope;
- credentials, secrets, or config access required;
- destructive operation required;
- scope conflict or high-risk ambiguity;
- after PR/checkpoint is opened or completed.

Final report:
Stage, branch, commit/PR if any, files changed, checks run, issues, assumptions, updated handoff path, next recommended stage.
```
