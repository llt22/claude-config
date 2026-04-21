#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Compact Hook — 当 context 压缩后重新注入项目规范，防止长对话丢失规则。
触发时机：compact、clear
"""

import json
import os
from pathlib import Path


def read_file(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8").strip()
    except (FileNotFoundError, PermissionError, OSError):
        return ""


def main():
    project_dir = Path(os.environ.get("CLAUDE_PROJECT_DIR", ".")).resolve()

    # 项目级 CLAUDE.md
    project_rules = read_file(project_dir / "CLAUDE.md")

    # 用户全局 CLAUDE.md
    global_rules = read_file(Path.home() / ".claude" / "CLAUDE.md")

    parts = []
    if global_rules:
        parts.append(f"## 全局规范（~/.claude/CLAUDE.md）\n\n{global_rules}")
    if project_rules:
        parts.append(f"## 项目规范（CLAUDE.md）\n\n{project_rules}")

    if not parts:
        return

    content = "\n\n---\n\n".join(parts)

    result = {
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": (
                "<reinject-rules>\n"
                "Context 压缩后重新注入。以下是必须严格遵守的项目规范：\n\n"
                f"{content}\n"
                "</reinject-rules>"
            ),
        }
    }

    print(json.dumps(result, ensure_ascii=False))


if __name__ == "__main__":
    main()
