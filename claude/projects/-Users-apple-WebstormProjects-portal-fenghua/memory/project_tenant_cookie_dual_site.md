---
name: tenant cookie 双处维护点
description: auth/t/[tenant]/page.tsx 内联 cookie 逻辑与 sync-tenant-cookie.ts 需同步维护
type: project
---

tenant_org_id cookie 的写入/清除逻辑有两处：
1. `apps/web/src/utils/sync-tenant-cookie.ts` — 共享 helper，select-org / create-org / nav-user 使用
2. `apps/web/src/app/auth/t/[tenant]/page.tsx` (约 line 49) — 内联处理，因为该页已持有 branding 结果，调 helper 会多一次重复请求

**Why:** 两处逻辑必须保持一致（有品牌写入、无品牌清除）。当前不是 bug，但后续调整 cookie 策略时容易遗漏。

**How to apply:** 修改 cookie 策略时检查这两处是否同步。
