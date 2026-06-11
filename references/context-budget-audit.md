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
- Repo workflow governance stop conditions exist.
- Truncation recovery exists.
- Final output rules are concise.
- No secrets, `.env` content, credentials, tokens, SSH keys, API keys, or `config.toml` content are read or modified.
- No permanent helper files are created unless the repo scope explicitly allows them.
