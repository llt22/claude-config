---
name: Swiper 内部滚动冲突用 noMousewheelClass
description: Swiper 全屏滚动中子容器需要独立滚动时，优先用 noMousewheelClass 而非手动 stopPropagation
type: feedback
---

Swiper Mousewheel 模块与子容器滚动冲突时，优先使用 `noMousewheelClass` 配置项，给子容器加对应 class 即可让 Swiper 跳过该区域的 wheel 事件。

**Why:** 手动 `onWheel` + `stopPropagation` 需要自行判断滚动边界（顶/底），逻辑复杂且容易出 bug；`noMousewheelClass` 是 Swiper 原生支持的声明式方案，零额外 JS。

**How to apply:** 遇到 Swiper 全屏滚动 + 内部可滚动区域的场景时，直接在 Swiper mousewheel 配置中加 `noMousewheelClass`，在子容器加对应 class。不要写手动的 wheel 事件处理。
