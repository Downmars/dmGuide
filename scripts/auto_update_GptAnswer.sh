#!/bin/bash

# 设置路径
TARGET_DIR="$HOME/Projects/dmGuide/docs/App/GptAnswer"
MKDOCS_YML="$HOME/Projects/dmGuide/mkdocs.yml"

# 检查是否存在 GptAnswer 目录
if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: $TARGET_DIR does not exist."
  exit 1
fi

# 生成 nav 部分
NAV_ENTRY=""

# 遍历目录下的所有 .md 文件
for file in "$TARGET_DIR"/*.md; do
  if [ -f "$file" ]; then
    # 提取文件名
    filename=$(basename "$file")
    # 去掉文件扩展名
    basename="${filename%.*}"
    # 构造条目（每行前添加6个空格）
    NAV_ENTRY="$NAV_ENTRY      - $basename: App/GptAnswer/$filename\n"
  fi
done

# 如果有新条目，则更新 mkdocs.yml
if [ -n "$NAV_ENTRY" ]; then
  echo "Updating mkdocs.yml..."

  # 检查 mkdocs.yml 中是否已经包含 GptAnswer 部分
  if ! grep -q "GptAnswer" "$MKDOCS_YML"; then
    # 如果没有 GptAnswer 部分，则插入
    sed -i "/^nav:/a\    - GptAnswer:" "$MKDOCS_YML"
  fi

  # 使用 printf 来正确格式化并插入条目
  printf "%s" "$NAV_ENTRY" | sed -i "/GptAnswer:/a\\$(cat)" "$MKDOCS_YML"

  echo "mkdocs.yml nav section updated."
else
  echo "No .md files found in $TARGET_DIR."
fi
