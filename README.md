# Codex Long Session Governance Skill

A Codex Skill for long-session context budgeting, prompt compression, handoff splitting, command output protection, truncation recovery, and repo workflow governance.

This is a single-skill repo for the `codex-long-session-governance` Codex Skill.

## TL;DR

- This repo installs one Codex Skill: `codex-long-session-governance`.
- It helps Codex avoid oversized `/goal` prompts, broad log reads, stale memory, and token waste.
- It does not replace project-specific `AGENTS.md` files or task-specific Skills.
- It is most useful for large repos, long sessions, generated outputs, and staged PR workflows.
- It is not needed for tiny one-off edits.

## The Problem

Long Codex sessions can become expensive and unreliable when prompts, logs, reports, raw data, and tool outputs grow too large. Common failure modes include stale memory, broad rereads, context truncation, hallucinated repo state, and oversized `/goal` prompts that try to carry an entire stage specification.

## What This Skill Does

- Uses a context ladder before broad reads.
- Byte-caps unknown command output.
- Pre-compacts raw data, logs, and reports into needle maps before analysis.
- Maintains a compact living handoff.
- Uses a do-not-reread list for long or repeated sessions.
- Compresses oversized `/goal` prompts into short launch indexes.
- Places instructions in the right source: `AGENTS.md`, handoff, stage plan, controller doc, logs, or task-specific Skill.
- Enforces PR and merge gate discipline.
- Provides truncation recovery rules.

## What This Skill Does Not Do

- It does not execute trades.
- It does not fetch private data.
- It does not read secrets.
- It does not replace project-specific `AGENTS.md`.
- It does not make Codex automatically correct; it gives Codex a safer workflow.
- It is not needed for tiny one-off edits.

## Who Should Use This

Use this Skill for:

- long Codex sessions;
- large or unfamiliar repos;
- many logs, reports, generated outputs, or data files;
- repeated staged PR workflows;
- teams trying to reduce repeated prompt and context overhead;
- users who want reusable repo workflow governance.

## Who Should Not Use This

Skip this Skill for:

- one-off small questions;
- tiny single-file edits;
- non-repo creative writing;
- tasks with no context budget or repo workflow risk.

## Quick Install

Run a dry-run first:

```powershell
.\install.ps1
```

Install explicitly:

```powershell
.\install.ps1 -Install
```

The installer is dry-run by default. It only installs when `-Install` is provided.

The installer copies only `SKILL.md`, `references\`, and `assets\` into:

```text
$env:USERPROFILE\.agents\skills\codex-long-session-governance
```

The `examples\` directory is repo documentation only and is not installed by `install.ps1`.

## Verify

Run the local audit:

```powershell
.\audit.ps1
```

The audit checks:

- `SKILL.md` frontmatter;
- required description terms;
- Markdown code fences;
- sensitive-looking filenames;
- hardcoded personal paths.

## Use In Codex

Minimal prompt:

```text
Use $codex-long-session-governance. First do Level 0 repo-state checks, then read Level 1 first-pass docs. Byte-cap unknown output. Pre-compact raw data, logs, and reports into a needle map before analysis. Do not read multiple long files in parallel. Do not rely on stale memory. Update the handoff when needed. Advance exactly one PR-sized stage. Do not merge PRs.
```

## Oversized `/goal` Example

Before:

```text
/goal Continue this repo and implement the next checkpoint. Here is the full stage specification, all acceptance criteria, long rationale, optional extensions, edge cases, previous debugging history, log excerpts, validation notes, and repeated safety rules...
```

After:

```text
/goal Continue this repo from latest verified state and complete exactly one PR-sized checkpoint.

Use $codex-long-session-governance.
First read only: AGENTS.md, docs/current_handoff.md, docs/STAGE_PLAN.md, and the controller doc.
Then targeted-read only files needed for this checkpoint.
Keep scope to the stage plan, preserve stop gates, run listed validation, update handoff, and report changed files, checks, blockers, and next action.
```

The detailed specification belongs in `docs/STAGE_PLAN.md` or an equivalent stage plan. Current state belongs in `docs/current_handoff.md` or `HANDOFF.md`. Stop gates and context budget rules belong in a controller doc. Permanent rules belong in `AGENTS.md`.

## File Layout

```text
.
|-- SKILL.md
|-- README.md
|-- LICENSE
|-- .gitignore
|-- install.ps1
|-- audit.ps1
|-- references/
|   `-- context-budget-audit.md
|-- assets/
|   `-- long-session-goal-template.md
`-- examples/
    |-- good-startup-prompt.md
    `-- bad-vs-good-retrieval.md
```

- `SKILL.md`: the Codex Skill users install.
- `install.ps1`: dry-run-by-default installer for Windows PowerShell.
- `audit.ps1`: local validation for public repo safety and Skill shape.
- `assets/`: reusable prompt template assets.
- `references/`: audit checklist and supporting reference material.
- `examples/`: generic usage examples for readers; not installed by default.

## Safety Model

- No secrets in this repo.
- Do not read or copy `config.toml`.
- Do not include raw data by default.
- Cap unknown command output before inspecting it.
- Prefer summaries over full logs.
- Do not read multiple long logs in parallel.
- Treat logs as historical records, not first-pass context.

## FAQ

### Is this a Codex plugin?

No. This is a Codex Skill repo. It provides a reusable `SKILL.md`, not a plugin runtime.

### Where does it install?

By default, `install.ps1 -Install` installs to:

```text
$env:USERPROFILE\.agents\skills\codex-long-session-governance
```

### Do I need this for every task?

No. Use it for long sessions, large repos, large logs, staged PR workflows, and context-budget risk. Skip it for small one-off edits.

### Does it replace `AGENTS.md`?

No. `AGENTS.md` remains the right place for permanent repo or global behavior rules. This Skill helps Codex read and apply those rules without broad rereads.

### Can I use it in any repo?

Yes, when the repo work has long-session, context-budget, output-size, handoff, or workflow-governance risk. Local repo rules still take precedence.

### Why split `/goal` into handoff, stage-plan, and controller docs?

Because `/goal` should launch the work, not store the whole workflow. Handoff stores current state, stage plans store detailed requirements, and controller docs store reusable stop gates and context-budget rules.

## License

MIT License. Copyright (c) 2026 Minqi Yang.
