# Good Startup Prompt

```text
请使用 $codex-long-session-governance。

目标：继续这个大型 repo 的一个小阶段，不要依赖聊天记忆。

要求：
- 先做 Level 0 repo-state 检查。
- 只读 Level 1 source-of-truth docs。
- 未知输出必须 byte-cap。
- 不读取 secrets、config.toml、raw data 或长日志全文。
- 如果有 open PR gate、dirty worktree、截断输出或高风险歧义，停止并报告。
- 最终只给 changed files、checks、blockers、next action。
```
