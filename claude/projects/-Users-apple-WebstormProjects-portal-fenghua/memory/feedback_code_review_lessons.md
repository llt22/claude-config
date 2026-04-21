---
name: Code Review Lessons from Clawith Integration
description: 反复 review 暴露的系统性编码习惯问题及改进措施
type: feedback
---

Clawith 集成经历十几轮 review，暴露的不是个别 bug，而是编码思维模式的系统性缺陷。

## 问题

1. **只看 happy path**：写 fetch 不想超时，写 mutex 不想多实例，写 toast 不想边界输入。
   **Why:** 急于完成功能，没有在写完后做"如果出错了呢"的自检。
   **How to apply:** 每个函数写完后，过一遍：超时、并发、错误响应、边界输入、资源泄漏。

2. **改一处不查上下游**：加了 clawithSsoReady 字段但没 grep 所有读取点，导致 syncClawithOrgCreate 漏掉 IdP 重试。
   **Why:** 只盯着当前文件改动，没有追踪字段的完整读写链。
   **How to apply:** 改 schema 或加字段后，grep 所有读写点逐个确认联动。

3. **抽象时机滞后**：provision 逻辑写了两遍才提取。
   **Why:** 第一次写时觉得"场景不同"，实际核心流程完全一致。
   **How to apply:** 逻辑出现第二次时就提取，不要等 reviewer 指出。

4. **安全模式不复用**：validateClawithAgentUrl 已用 origin 比较，SSO route 却用 startsWith。
   **Why:** 写新文件时没有检索项目中已有的同类安全模式。
   **How to apply:** 涉及 URL 校验、输入过滤等安全逻辑时，先搜项目已有实现，复用同一模式。

5. **错误信息不完整**：所有 Clawith API 错误只有 HTTP 状态码，没有 response body。
   **Why:** 开发时 console 能看到完整错误，没想到生产排障只有日志。
   **How to apply:** 外部 API 调用失败时，始终记录 response body（截断）到错误消息。
