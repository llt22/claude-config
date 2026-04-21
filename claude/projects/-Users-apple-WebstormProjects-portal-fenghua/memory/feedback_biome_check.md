---
name: 提交前先跑 Biome 检查
description: 提交代码前必须先运行 npm run check（Biome 格式化+检查），不要依赖 pre-commit hook
type: feedback
---

提交前必须��手动运行 `npm run check`（Biome 格式化+lint），确认无问题后再 commit。

**Why:** pre-commit hook 虽然会自动格式化，但如果 Biome 改了文件内容（比如回退了手动修改），提交的内容可能不是预期的。之前多次出现 Biome hook 把 sourceId 等值回退的问题。

**How to apply:** 每次 `git commit` 之前，先跑 `npm run check`，确认输出无异常，再暂存和提交。
