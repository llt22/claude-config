#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$HOME/.agents"

ACTION="${1:-}"

usage() {
  echo "Usage: $0 <push|pull|install>"
  echo ""
  echo "  install  首次在新电脑上安装：仓库 → 本地（创建目录和软链）"
  echo "  push     本地配置 → 仓库（备份当前配置）"
  echo "  pull     仓库 → 本地（恢复配置）"
  exit 1
}

[ -z "$ACTION" ] && usage

sync_file() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  echo "  ✓ $dst"
}

sync_dir() {
  local src="$1" dst="$2"
  mkdir -p "$dst"
  cp -r "$src"/* "$dst"/ 2>/dev/null || true
  echo "  ✓ $dst/"
}

link_skill() {
  local src="$1" name="$2" target="$CLAUDE_DIR/skills/$name"
  if [ -L "$target" ] || [ -e "$target" ]; then
    rm -rf "$target"
  fi
  ln -s "$src" "$target"
  echo "  ✓ $target → $src"
}

case "$ACTION" in
  install)
    echo "=== 安装 Claude Code 配置 ==="
    mkdir -p "$CLAUDE_DIR/skills" "$AGENTS_DIR/skills"

    echo "[全局配置]"
    sync_file "$SCRIPT_DIR/claude/settings.json" "$CLAUDE_DIR/settings.json"
    sync_file "$SCRIPT_DIR/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
    sync_file "$SCRIPT_DIR/claude/RTK.md" "$CLAUDE_DIR/RTK.md"

    echo "[全局 hooks]"
    sync_dir "$SCRIPT_DIR/claude/hooks" "$CLAUDE_DIR/hooks"

    echo "[自定义 skill]"
    sync_dir "$SCRIPT_DIR/claude/skills/code-review" "$CLAUDE_DIR/skills/code-review"
    sync_dir "$SCRIPT_DIR/claude/skills/systematic-debugging" "$CLAUDE_DIR/skills/systematic-debugging"

    echo "[社区 skill]"
    for skill_dir in "$SCRIPT_DIR"/agents/skills/*/; do
      name="$(basename "$skill_dir")"
      sync_dir "$skill_dir" "$AGENTS_DIR/skills/$name"
    done

    echo "[创建软链]"
    link_skill "$AGENTS_DIR/skills/context7" "context7"
    link_skill "$AGENTS_DIR/skills/find-skills" "find-skills"
    link_skill "$AGENTS_DIR/skills/tavily-cli" "tavily-cli"

    echo "[项目 memory]"
    for project_dir in "$SCRIPT_DIR"/claude/projects/*/; do
      name="$(basename "$project_dir")"
      sync_dir "$project_dir/memory" "$CLAUDE_DIR/projects/$name/memory"
    done

    echo ""
    echo "安装完成！重启 Claude Code 生效。"
    echo "注意：settings.json 中的 API 密钥可能需要更新。"
    ;;

  push)
    echo "=== 备份本地配置 → 仓库 ==="
    echo "[全局配置]"
    cp "$CLAUDE_DIR/settings.json" "$SCRIPT_DIR/claude/settings.json"
    sed -i '' 's/"ANTHROPIC_AUTH_TOKEN": ".*"/"ANTHROPIC_AUTH_TOKEN": "<YOUR_TOKEN>"/' "$SCRIPT_DIR/claude/settings.json"
    echo "  ✓ $SCRIPT_DIR/claude/settings.json (token 已脱敏)"
    sync_file "$CLAUDE_DIR/CLAUDE.md" "$SCRIPT_DIR/claude/CLAUDE.md"
    [ -f "$CLAUDE_DIR/RTK.md" ] && sync_file "$CLAUDE_DIR/RTK.md" "$SCRIPT_DIR/claude/RTK.md"

    echo "[全局 hooks]"
    sync_dir "$CLAUDE_DIR/hooks" "$SCRIPT_DIR/claude/hooks"

    echo "[自定义 skill]"
    for skill_dir in "$CLAUDE_DIR"/skills/*/; do
      [ -L "$skill_dir" ] && continue  # 跳过软链
      name="$(basename "$skill_dir")"
      sync_dir "$skill_dir" "$SCRIPT_DIR/claude/skills/$name"
    done

    echo "[社区 skill]"
    for skill_dir in "$AGENTS_DIR"/skills/*/; do
      name="$(basename "$skill_dir")"
      sync_dir "$skill_dir" "$SCRIPT_DIR/agents/skills/$name"
    done

    echo "[项目 memory]"
    find "$CLAUDE_DIR/projects" -path "*/memory" -type d 2>/dev/null | while read dir; do
      name="$(basename "$(dirname "$dir")")"
      sync_dir "$dir" "$SCRIPT_DIR/claude/projects/$name/memory"
    done

    echo ""
    echo "备份完成！记得 git commit && git push。"
    ;;

  pull)
    echo "=== 恢复仓库配置 → 本地 ==="
    echo "[全局配置]"
    sync_file "$SCRIPT_DIR/claude/settings.json" "$CLAUDE_DIR/settings.json"
    sync_file "$SCRIPT_DIR/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
    [ -f "$SCRIPT_DIR/claude/RTK.md" ] && sync_file "$SCRIPT_DIR/claude/RTK.md" "$CLAUDE_DIR/RTK.md"

    echo "[全局 hooks]"
    sync_dir "$SCRIPT_DIR/claude/hooks" "$CLAUDE_DIR/hooks"

    echo "[自定义 skill]"
    for skill_dir in "$SCRIPT_DIR"/claude/skills/*/; do
      name="$(basename "$skill_dir")"
      sync_dir "$skill_dir" "$CLAUDE_DIR/skills/$name"
    done

    echo "[社区 skill]"
    for skill_dir in "$SCRIPT_DIR"/agents/skills/*/; do
      name="$(basename "$skill_dir")"
      sync_dir "$skill_dir" "$AGENTS_DIR/skills/$name"
    done

    echo "[项目 memory]"
    for project_dir in "$SCRIPT_DIR"/claude/projects/*/; do
      name="$(basename "$project_dir")"
      sync_dir "$project_dir/memory" "$CLAUDE_DIR/projects/$name/memory"
    done

    echo ""
    echo "恢复完成！重启 Claude Code 生效。"
    ;;

  *)
    usage
    ;;
esac
