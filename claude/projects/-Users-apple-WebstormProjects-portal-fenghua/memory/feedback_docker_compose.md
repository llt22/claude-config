---
name: docker-compose restart
description: 用 docker-compose up -d 重启即可，不要用 down + up
type: feedback
---

EKC 服务器上重启容器用 `docker-compose -p ekc -f docker-compose.yml up -d` 即可，不要加 `down`。`down` 会尝试删除共享网络导致报错（其他容器还在用），而 `up -d` 会自动检测配置变更并重建需要更新的容器。

**Why:** `down` 删网络时会因为其他 docker-compose 项目的容器还连着同名网络而失败。
**How to apply:** 任何需要重启 EKC docker 容器的场景，只用 `up -d`，除非用户明确要求完全清理。
