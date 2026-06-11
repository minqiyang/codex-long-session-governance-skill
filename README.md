# Codex Long Session Governance Skill

A Codex Skill for long-session context budgeting, command output protection, living handoff, truncation recovery, and repo workflow governance.

## When To Use

Use this Skill for:

- long Codex sessions
- large repos
- large logs/docs/data
- token budget issues
- stale memory / hallucination risk
- PR gate / staged workflow

Do not use it for:

- simple one-off tasks
- tiny single-file edits

## Installation

Run a dry-run first:

```powershell
.\install.ps1
```

Install explicitly:

```powershell
.\install.ps1 -Install
```

The installer copies only `SKILL.md`, `references\`, and `assets\` into:

```text
$env:USERPROFILE\.agents\skills\codex-long-session-governance
```

The `examples\` directory is repo documentation only and is not installed by `install.ps1`.

## Usage

Example prompt:

```text
请使用 $codex-long-session-governance。先检查 repo state，限制未知命令输出，避免读取 secrets/config.toml/raw data，按最小上下文推进一个 PR-sized stage。
```

## Reducing Oversized `/goal` Prompts

- Put stable rules in `AGENTS.md` or this Skill.
- Put current state in `docs/current_handoff.md` or `HANDOFF.md`.
- Put full stage details in `docs/STAGE_PLAN.md` or an equivalent stage plan.
- Put stop gates and context budget rules in controller docs.
- Keep `/goal` as a compact launch index that points to those sources.
- Run `.\audit.ps1` before committing changes.

## Safety

- No secrets should be stored in this repo.
- Do not read or copy `config.toml`.
- Do not include raw data by default.
- Byte-cap unknown command output before inspecting it.

## File Structure

```text
.
├── SKILL.md
├── README.md
├── LICENSE
├── .gitignore
├── install.ps1
├── audit.ps1
├── references\
│   └── context-budget-audit.md
├── assets\
│   └── long-session-goal-template.md
└── examples\
    ├── good-startup-prompt.md
    └── bad-vs-good-retrieval.md
```

## License

MIT License. Copyright (c) 2026 Minqi Yang.
