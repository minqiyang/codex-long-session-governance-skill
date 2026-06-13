# Context Budget Audit

Use this lightweight checklist to audit a long-session governance run or the Skill itself.

- Skill triggers correctly for long Codex sessions, large repos, large logs, raw data, PR gates, stale memory, truncation risk, or token-budget concerns.
- Not-use cases are clear for simple one-off tasks, tiny single-file edits, and tasks with no long-context risk.
- Unknown command outputs are capped.
- Long files are not read in parallel.
- Raw data is pre-compacted before analysis.
- Needle map requirements are present.
- Living handoff rule exists.
- Periodic compaction rule exists.
- PR gate rule exists.
- Does a not-verified-merged PR gate pause after one current-state check rather
  than repeated polling or reclassification?
- If an automatic continuation resumes after the same PR gate and no user says
  the PR merged or asks for inspection, does Codex avoid another
  `fetch`/`gh pr list`, avoid repeating the full gate report, and avoid marking
  the goal blocked merely because the external PR gate is still pending?
- Repo workflow governance stop conditions exist.
- Truncation recovery exists.
- Final output rules are concise.
- `/goal` stays short and index-like.
- Detailed specs are placed in `STAGE_PLAN` or equivalent.
- Current state is placed in handoff rather than repeated in the prompt.
- Permanent rules are placed in `AGENTS.md` or a Skill rather than repeated every turn.
- Logs are treated as historical and not first-pass context.
- A do-not-reread list exists when the session is long or repeated.
- Optional expansions are kept out of the current checkpoint.
- Stop gates are preserved after compression.
- Validation commands are preserved after compression.
- Prompt compression removes explanation and repetition, not requirements.
- Does the policy distinguish direct merge from GitHub auto-merge?
- Does it forbid `--admin`?
- Does it require verifiable branch protection/checks/reviews?
- Does it stop when risk is medium/high/unclear?
- Does final report include risk classification and auto-merge status?
- Does the workflow avoid rerunning checks, protection queries, review queries,
  or baseline validation while a previous PR is not verified merged?
- No secrets, `.env` content, credentials, tokens, SSH keys, API keys, or `config.toml` content are read or modified.
- No permanent helper files are created unless the repo scope explicitly allows them.
