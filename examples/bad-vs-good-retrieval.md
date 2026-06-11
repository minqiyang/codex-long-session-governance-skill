# Bad Vs Good Retrieval

## Bad

```text
Read every Markdown file and all logs, then tell me what to do.
```

Why it is bad: it invites broad reads, context waste, stale summaries, and accidental exposure of irrelevant local data.

## Good

```text
Use $codex-long-session-governance. Start with repo state, then read only AGENTS.md and the current handoff if present. Search long logs by explicit error keyword and cap output to 40 matches.
```

Why it is good: it starts from current evidence, uses the lowest useful retrieval level, and caps unknown output.
