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
files=("$TARGET_DIR"/*.md)
file_count=${#files[@]}

for i in "${!files[@]}"; do
  file="${files[$i]}"

  if [ -f "$file" ]; then
    # 提取文件名
    filename=$(basename "$file")
    # 去掉文件扩展名
    basename="${filename%.*}"

    # 如果是最后一个文件，不加换行符，否则加换行符
    if [ $i -eq $((file_count - 1)) ]; then
      NAV_ENTRY="$NAV_ENTRY      - $basename: App/GptAnswer/$filename"
    else
      NAV_ENTRY="$NAV_ENTRY      - $basename: App/GptAnswer/$filename\n"
    fi
  fi
done

# 获取 mkdocs.yml 中现有的 GptAnswer 部分，并构建已存在的条目
EXISTING_ENTRIES=$(grep -A 1000 "GptAnswer" "$MKDOCS_YML" | grep -B 1000 "^\s*- ")

# 更新 mkdocs.yml 中的条目
update_mkdocs() {
  echo "Updating mkdocs.yml..."

  # 删除现有的 GptAnswer 部分条目（如果有）
  sed -i '/^nav:/,/^theme: /{
    /^    - GptAnswer:/,/^    - /{
        /^      - /{
            d
        }
    }
}' "$MKDOCS_YML"

  # 使用 printf 来正确格式化并插入条目
  printf "%s" "$NAV_ENTRY" | sed -i "/GptAnswer:/a\\$(cat)" "$MKDOCS_YML"

  echo "mkdocs.yml nav section updated."
}

# 如果有新条目，则更新 mkdocs.yml
if [ -n "$NAV_ENTRY" ]; then
  # 直接比较 $EXISTING_ENTRIES 和 $NAV_ENTRY 是否不同
  if [ "$EXISTING_ENTRIES" != "$NAV_ENTRY" ]; then
    # 只有在两者不同的情况下才更新
    update_mkdocs
  else
    echo "No changes detected."
  fi
else
  echo "No .md files found in $TARGET_DIR."
fi

# 监控文件变化
inotifywait -m -r -e create,delete,move,modify "$TARGET_DIR" --format "%w%f" | while read -r file; do
  # 文件创建、删除或重命名时，更新 mkdocs.yml
  bash "$0"
done
