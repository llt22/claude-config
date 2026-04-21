---
name: feedback_biome_before_commit
description: 提交前必须先运行 biome check，不要直接 git commit
type: feedback
---

提交代码前必须先运行 `npx biome check --write` 对改动文件进行检查和自动修复。

**Why:** 用户明确要求在提交前进行 biome 检查，确保代码风格一致，避免 pre-push hook 拦截。

**How to apply:** 每次 `git commit` 之前，先对待提交的文件运行 `npx biome check --write`，确认无 error 后再提交。
