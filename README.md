# claude-config

Claude Code 配置同步方案 —— 一个 Git 仓库 + 一个脚本，在多台设备间同步你的 Claude Code 全局配置、提示词、hooks 和 skills。

## 解决什么问题

Claude Code 的个人配置散落在 `~/.claude/` 和 `~/.agents/` 两个目录中，包括全局提示词、自定义 skill、hooks 脚本、项目 memory 等。换一台电脑，这些全部要重新配置。

本仓库提供：

- **一键安装**：新设备 clone 后执行 `./sync.sh install` 即可还原全部配置
- **一键备份**：`./sync.sh push` 将本地最新配置同步到仓库，自动脱敏 API Token
- **一键恢复**：`./sync.sh pull` 从仓库拉取配置覆盖到本地

## 仓库结构

```
claude-config/
├── claude/
│   ├── settings.json          # 全局设置（model、env、hooks）
│   ├── CLAUDE.md              # 全局提示词（执行准则、工程规则、Git 规范等）
│   ├── RTK.md                 # RTK token 压缩工具引用文档
│   ├── hooks/
│   │   └── reinject-rules.py  # compact/clear 后重新注入提示词
│   ├── skills/                # 自定义 skill
│   │   ├── code-review/       # 结构化代码审查
│   │   └── systematic-debugging/  # 系统化调试流程
│   └── projects/              # 项目级 memory（gitignore 排除，仅本地同步）
│       └── .example-project/  # 示例 memory 格式
├── agents/
│   └── skills/                # 社区 skill（tavily 系列等）
├── sync.sh                    # 同步脚本
└── README.md
```

## 快速开始

### 以本仓库为模板

1. Fork 或用本仓库做模板，创建你自己的私有仓库
2. 按需修改 `claude/CLAUDE.md`（全局提示词）和 `claude/settings.json`（全局配置）
3. 项目级 memory 已被 gitignore 排除，`sync.sh push/pull` 仍会在本地同步

### 在新设备上安装

```bash
git clone <your-repo-url>
cd claude-config
./sync.sh install
```

安装后编辑 `~/.claude/settings.json`，将 `<YOUR_TOKEN>` 替换为你的 API Token，然后重启 Claude Code。

### 日常同步

```bash
# 本地配置有更新，备份到仓库
./sync.sh push
git add -A && git commit -m "chore: 同步配置" && git push

# 在另一台设备上拉取
git pull
./sync.sh pull
```

## 核心配置说明

### 全局提示词（CLAUDE.md）

仓库中的 `claude/CLAUDE.md` 包含一套经过实践打磨的全局规范，涵盖：

| 模块 | 作用 |
|------|------|
| 执行准则 | 事实驱动、先议后动、最小改动、止损回退、完成验证 |
| 工程规则 | 命名职责、复用优先、模块边界、耦合控制、编码规范 |
| 风险控制 | 生产标准（OWASP）、向后兼容 |
| Git 规范 | 禁止自主 commit/push、Conventional Commits |
| 危险红线 | force push / reset --hard 等操作必须人工确认 |

你可以根据自己的需求修改或精简。

### Compact Hook（reinject-rules.py）

Claude Code 在长对话中会压缩上下文（compact），压缩后全局提示词和项目规范可能丢失。这个 hook 在 compact 和 clear 事件后自动重新注入 `~/.claude/CLAUDE.md` 和项目级 `CLAUDE.md`。

配置方式（已包含在 `settings.json` 中）：

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [{ "type": "command", "command": "python3 ~/.claude/hooks/reinject-rules.py", "timeout": 10 }]
      },
      {
        "matcher": "clear",
        "hooks": [{ "type": "command", "command": "python3 ~/.claude/hooks/reinject-rules.py", "timeout": 10 }]
      }
    ]
  }
}
```

### 自定义 Skill

| Skill | 触发词 | 作用 |
|-------|--------|------|
| code-review | "review"、"帮我看看代码" | 按 10 个维度结构化审查代码，输出分级问题列表 |
| systematic-debugging | "调试"、"debug"、"bug" | 强制执行 根因调查 → 模式分析 → 假设验证 → 最小修复 流程，3 次失败自动止损 |

### Token 脱敏

`sync.sh push` 会自动将 `settings.json` 中的 `ANTHROPIC_AUTH_TOKEN` 替换为 `<YOUR_TOKEN>` 占位符，确保密钥不会被提交到仓库。

## 自定义指南

### 添加新 Skill

1. 在 `claude/skills/<skill-name>/` 下创建 `SKILL.md`
2. 更新 `sync.sh` 的 install 部分（如有需要）
3. `./sync.sh push` 备份

### 添加新 Hook

1. 将脚本放到 `claude/hooks/` 下
2. 在 `claude/settings.json` 中注册 hook
3. `./sync.sh push` 备份

### 管理社区 Skill

社区 skill 存放在 `agents/skills/` 下，通过软链接注册到 `~/.claude/skills/`。需要在 `sync.sh` 的 `link_skill` 部分添加对应的软链配置。

## 注意事项

- `sync.sh push` 中的 `sed -i ''` 语法为 macOS 版本，Linux 用户需改为 `sed -i`
- 项目级 memory 的目录名包含完整路径（如 `-Users-apple-WebstormProjects-xxx`），换设备后路径不同需要手动调整
- 建议使用**私有仓库**，即使 Token 已脱敏，提示词和 memory 仍可能包含项目相关信息

## License

MIT
