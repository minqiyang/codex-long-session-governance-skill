---
name: codex-long-session-governance
description: Codex long session, context budget, byte cap, command output protection, needle map, pre-compact raw data, living handoff, retrieval policy, repo workflow governance, PR gate, truncation recovery, large logs, large repo, stale memory, hallucination risk, token budget. Use to govern evidence retrieval, output limits, handoff, and PR-stage control in long Codex repo/log/data sessions. Do not use for simple one-off tasks, tiny single-file edits, or tasks with no large repo/log/context/token risk.
---

# Codex Long Session Governance

## Purpose

Use this as a cross-repo Context Budget Governor for long Codex sessions. It limits how Codex retrieves, compresses, reads, outputs, and hands off context.

This Skill does not replace project `AGENTS.md`, repo-specific workflow docs, or business/domain Skills. It governs context handling and repo workflow discipline so those local rules can be read narrowly and followed reliably.

## When to use

Use this Skill when any of the following apply:

- long Codex or `/goal` session;
- staged repo workflow or multi-PR workflow;
- large repo or unfamiliar repo;
- long logs, long Markdown docs, generated reports, checkpoint docs, large CSV, JSON, parquet, or text dumps;
- Codex has shown or may show stale memory, hallucination, context truncation, repeated broad reads, excessive token use, or workflow drift;
- the next action must be derived from repo evidence rather than chat memory;
- the user asks to reduce token burn, manage context, avoid truncation, or create a durable handoff.

## When not to use

Do not use this Skill for:

- one-off small answers;
- tiny edits to one known file;
- tasks where the user explicitly says not to use Skills;
- tasks with no long-context, repo-governance, log-reading, data-reading, PR-gate, or token-budget concern;
- purely creative writing or translation tasks unrelated to repo workflow.

## Desired outcome

The session stays evidence-first, bounded, and resumable. Codex should choose the next action from current repo evidence, cap unknown output, pre-compact raw data and logs, update or propose a living handoff when needed, advance one PR-sized stage at a time, and stop at gates instead of drifting.

## Success criteria

- Current repo state is checked before implementation.
- Level 0 and Level 1 context are used before broad reads.
- Unknown or potentially large command output is capped.
- Long files are searched or sampled before any full read.
- Raw data and generated reports are pre-compacted into a needle map before analysis.
- Handoff state is updated or proposed before context becomes stale or oversized.
- Repo work advances one small PR-sized stage at a time.
- PR gates, dirty worktrees, truncation, destructive operations, and high-risk ambiguity stop the workflow.
- Final reports are concise and do not paste full logs, full generated reports, or raw data.

## Inputs and context to collect

Collect only the smallest useful set first:

- repo root, current branch, dirty worktree state, remotes, and recent commits;
- explicit user scope, forbidden paths, and allowed write paths;
- nearest `AGENTS.md` and first-pass handoff or repo-map docs if present;
- current PR gate state if `gh` is available and authorized;
- active stage, target files, expected checks, and stop conditions.

Do not inspect secrets, `.env` content, credentials, SSH keys, API keys, `config.toml`, or unrelated local configuration files.

## Operating principle

Use these invariants:

- Evidence over memory.
- Pre-compact before reading raw data.
- Narrow search before broad read.
- Byte-cap unknown output.
- Summarize; do not paste.
- One PR-sized stage at a time.
- Stop at merge gates.
- Never merge PRs.
- Do not rely on truncated output.
- Update handoff before context becomes stale or oversized.
- Do not create permanent helper files unless the repo scope allows it.

## Context Budget And Retrieval Policy

Use the lowest level that can answer the current question. Escalate only when the prior level is insufficient.

### Level 0: repo state only

Use low-output commands first:

- `git status --porcelain`
- `git branch --show-current`
- `git remote -v`
- `git log --oneline -15`
- `git diff --name-only`
- `git diff --stat`
- `gh pr status` or `gh pr list` only if available and authorized

### Level 1: first-pass docs only

Read only the smallest source-of-truth docs:

- `AGENTS.md`
- `README.md` summary or headings only if long
- `HANDOFF.md` if present
- `docs/current_handoff.md` if present
- `docs/repo_map.md` if present
- project-specific controller doc only if explicitly identified

### Level 2: active-stage docs only

Read only docs directly relevant to the current stage:

- active roadmap, design, or spec doc;
- relevant test or command docs;
- nearest directory-specific `AGENTS.md` if applicable.

### Level 3: targeted long-log search

For long logs, docs, and reports, use:

- `Select-String` with an explicit pattern;
- `rg` with an explicit pattern if available;
- `Get-Content -Tail N`;
- `Get-Content -TotalCount N`;
- small explicit line ranges;
- headings-only scans;
- filename and diff-stat summaries.

### Level 4: full-file read

Full-file read is allowed only if absolutely required. Before doing it, Codex must state:

- why targeted search is insufficient;
- why this specific file is needed;
- how output will be capped;
- what will be done if output is too large.

## Long-file definition

Treat these as long or risky unless proven small:

- `docs/engineering_log.md`
- `docs/decision_log.md`
- `docs/troubleshooting_log.md`
- `CHANGELOG.md`
- `reports/*.md`
- `reports/experiment_logs/*.json`
- generated reports
- checkpoint docs
- long design docs
- dependency lockfiles
- archived logs
- raw CSV, JSON, parquet, and data dumps
- `output/private`
- `node_modules`
- `.venv`, `venv`
- `dist`, `build`, `target`
- `.git` internals
- cache directories
- `__pycache__`, `.pytest_cache`, `.mypy_cache`, `.ruff_cache`, `coverage`, `htmlcov`

Default behavior:

- Do not read multiple long files in parallel.
- Do not print full generated reports.
- Do not recursively inspect excluded directories.
- Do not open raw data directly when a summary or needle map can answer the question.

## Command Output Protection

Any command with unknown or potentially large output must be capped.

PowerShell-safe patterns:

- `git status --porcelain | Select-Object -First 80`
- `git diff --name-only | Select-Object -First 120`
- `git diff --stat | Select-Object -First 120`
- `git log --oneline -20`
- `Get-Content path\to\file -TotalCount 80`
- `Get-Content path\to\file -Tail 80`
- `Select-String -Path path\to\file -Pattern "KEYWORD" | Select-Object -First 40`

For commands that may explode:

- write output to a temp file first;
- inspect only head, tail, or small ranges;
- do not paste the full temp output;
- use `$out = <COMMAND> 2>&1 | Out-String`, then `$out.Substring(0, [Math]::Min($out.Length, 6000))`.

If more context is needed, narrow the query. Do not simply increase the cap.

Default cap:

- unknown command output: 6,000 characters;
- log grep/search results: 40 matches;
- file head/tail: 80 lines;
- data sample: 20 rows max;
- final report: concise summary only.

## Pre-Compact Raw Data Policy

Never feed raw data first if the task can be answered from a compact map.

For CSV, JSON, log, report, and data-heavy tasks, require a needle map before analysis:

- row counts;
- column names;
- dtypes or schema;
- missingness/null counts;
- min/max dates;
- small sample, max 20 rows;
- top N anomalies, max 50;
- relevant filtered snippets only;
- source file paths, not full content.

If the repo already has scripts such as `repo_map.py`, `summarize_data.py`, `compact_logs.py`, `scan_errors.py`, or similar, prefer them.

If no helper exists:

- use one-off PowerShell or Python commands to summarize without printing raw data;
- create a temporary summary file only when needed;
- do not commit temporary summary files unless the task explicitly asks for a durable tool;
- if creating a durable helper script, keep it small, read-only, local-only, and documented.

## Living Handoff Policy

For long sessions, use a living handoff as the project brain.

Preferred files, in order:

- `HANDOFF.md`
- `docs/current_handoff.md`
- `docs/handoff.md`

If none exists, do not create one unless:

- the task is long-running or multi-PR;
- the user allows doc changes;
- creating it is within scope.

Handoff target size:

- under about 1,000 tokens;
- preferably under 150 lines;
- no raw logs;
- no full command output;
- no dead ends unless they prevent repeated mistakes.

Handoff must include:

- current goal;
- branch and PR gate state;
- key files;
- decisions made;
- checks run and outcomes;
- known issues;
- do-not-reread list;
- next recommended action.

End long stages with: Compact current findings into the handoff. Strip repetitions and failed paths. Keep only actionable facts needed to continue.

## Periodic Compaction Rule

For long sessions, compact manually before context gets stale:

- after 4-5 substantial turns;
- after opening a PR;
- after resolving a major blocker;
- after a large debugging branch;
- before switching stages;
- immediately after any truncated output.

Manual compaction means:

- update or propose update to handoff;
- summarize verified facts only;
- list unknowns explicitly;
- do not preserve speculation as fact;
- do not paste historical logs.

## Output Budget Policy

Default output should be short.

Do:

- summarize command results;
- report changed files;
- report checks run;
- report blockers;
- show snippets only when needed;
- show patch summary instead of full file content.

Do not:

- paste full large files;
- paste full logs;
- paste full generated reports;
- restate long plans unless the plan changed;
- include verbose narrative in final reports.

Final reports should include only relevant items from this list:

- stage;
- branch;
- commit hash if available;
- PR link if available;
- changed files;
- checks run;
- issues by severity;
- assumptions;
- next recommended stage;
- confirmation that Codex did not merge PRs.

## Repo Workflow Governance

Before implementation:

- check branch;
- check dirty worktree;
- check remotes;
- check open PR gate if tooling is available;
- read Level 1 context only;
- choose one small PR-sized stage;
- state assumptions only if needed.

During implementation:

- avoid unrelated changes;
- avoid large broad reads;
- run focused checks first;
- run full relevant checks before final;
- self-review changed files and guardrails.

Stop conditions:

- dirty worktree before new stage;
- open PR gate not verified merged;
- high/medium risk ambiguity;
- failing checks not safely fixable within scope;
- need for credentials or external access;
- destructive operation;
- scope conflict;
- after opening a PR.

Never merge PRs.

## Risk Classification

High risk:

- destructive file operations;
- credential or secrets access;
- production data;
- live or paper trading or order execution;
- schema migration;
- broad file deletion;
- uncertain merge state;
- security-sensitive changes.

Medium risk:

- large refactor;
- ambiguous requirements;
- public API changes;
- modifying generated outputs;
- changing tests to fit code;
- adding dependencies;
- creating durable helper scripts in target repo.

Low risk:

- doc-only workflow improvements;
- narrow retrieval;
- capped local validation;
- typo fixes;
- handoff updates within repo convention;
- small in-scope Skill updates.

Behavior:

- high risk: stop and ask for confirmation;
- medium risk: stop or present plan before changing;
- low risk: make a reasonable assumption, document it, continue.

## Truncation Recovery

If Codex sees or suspects `Output exceeded the available model context and was truncated`, it must:

- stop broad reading;
- not rely on truncated output;
- mark missing content as unknown;
- return to Level 0 or Level 1 context;
- reread only targeted sections;
- use byte-capped commands;
- update or propose update to handoff;
- record the issue in troubleshooting docs only if repo convention allows and task scope permits.

## Workflow guidance

Start from repo evidence, not chat memory. Use the context ladder, cap unknown output, pre-compact data-heavy inputs, and keep the active stage small enough to review and verify. When local project rules conflict with this Skill, follow the stricter rule or stop for confirmation if the conflict changes scope or risk.

## Known pitfalls

- Treating stale chat memory as current repo state.
- Reading multiple long reports or logs in parallel.
- Increasing output caps instead of narrowing the query.
- Pasting full generated reports into final answers.
- Creating durable helper files when the repo scope only allowed temporary or read-only work.
- Continuing past an unverified PR gate or dirty worktree.
- Treating sensitive-keyword scanner hits on guardrail text as secret exposure without checking whether actual values were present.

## Tools and deterministic operations

Use these local, Windows-compatible operations when relevant:

- `git status --porcelain`, `git branch --show-current`, `git remote -v`, `git log --oneline -15`, `git diff --name-only`, and `git diff --stat` for Level 0 state.
- `Select-String -SimpleMatch` for literal Windows paths or fixed strings.
- `Select-String -Pattern`, `rg` if available, `Get-Content -Tail`, and `Get-Content -TotalCount` for targeted reads.
- `gh pr status`, `gh pr list`, or `gh pr view` only when available and authorized.
- Existing repo-local summarizers such as `repo_map.py`, `summarize_data.py`, `compact_logs.py`, or `scan_errors.py` when they are present, documented, and safe for the current scope.

Do not use network access, install software, read secrets, print credentials, or read/modify `config.toml` or unrelated local configuration in order to apply this Skill.

## Verification

Before finishing a governed long-session task, check:

- only allowed paths changed;
- no secrets, `.env` content, tokens, credentials, SSH keys, API keys, `config.toml`, or forbidden config files were read or modified;
- unknown command output was capped;
- long files were targeted, sampled, or explicitly justified before full read;
- raw data was summarized through a needle map before analysis;
- handoff was updated or proposed if the session became long;
- PR gate was checked when tooling and authorization allowed it;
- no PR was merged;
- final output is concise and reports checks, changed files, blockers, assumptions, and next action.

## Skill Maintenance / Retrospective

At the end of a task:

- propose Skill updates only when a verified, reusable rule was learned;
- do not add one-off project details to this global Skill;
- put project-specific rules in that repo's `AGENTS.md` or workflow docs;
- keep this Skill concise;
- if `SKILL.md` grows too long, move examples to `references/context-budget-audit.md` or `assets/long-session-goal-template.md`.

## Update policy

After each use, update this Skill only when there is a reusable lesson:

- add newly verified pitfalls;
- refine success criteria;
- add stable commands, templates, or safe local tools;
- remove stale or wrong guidance;
- keep the file trigger-focused and cross-repo.
