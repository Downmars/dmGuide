明白了。你希望在脚本中执行打开文件的命令（例如 `imv photo.jpg`）时，隐藏终端并仅显示图片。为了实现这一点，可以在执行打开命令时将其放入后台并与当前终端会话分离。

以下是修改后的 `fopen_fd_bat.sh` 脚本，其中在 **“使用对应的命令打开文件”** 部分加入了隐藏终端的逻辑：

```bash
#!/bin/bash
# fopen_fd_bat.sh - 使用 fd 和 bat 快速打开文件，根据文件的 MIME 类型使用不同的工具，通过配置文件管理映射

# 配置文件路径
CONFIG_FILE="$HOME/.config/fzf_config/fopen_config/fopen_mime.conf"

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Configuration file not found: $CONFIG_FILE"
  exit 1
fi

# 检查所需工具是否已安装
required_tools=(fd fzf bat file)
for tool in "${required_tools[@]}"; do
  if ! command -v "$tool" &>/dev/null; then
    echo "Error: $tool is not installed. Please install it and try again."
    exit 1
  fi
done

# 读取配置文件并构建关联数组
declare -A MIME_COMMANDS

while IFS='=' read -r mime_pattern command; do
  # 忽略空行和注释行
  [[ "$mime_pattern" =~ ^#.*$ ]] && continue
  [[ -z "$mime_pattern" || -z "$command" ]] && continue
  # 去除可能的空格
  mime_pattern=$(echo "$mime_pattern" | xargs)
  command=$(echo "$command" | xargs)
  # 添加到关联数组
  MIME_COMMANDS["$mime_pattern"]="$command"
done <"$CONFIG_FILE"

# 默认打开命令
DEFAULT_OPEN_COMMAND="xdg-open"

# 使用 fd 查找文件，并通过 fzf 选择
selected=$(fd --type f --hidden --follow | fzf --preview "bat --style=numbers --color=always {}" --height=40%)

# 如果有选择，则根据 MIME 类型打开
if [ -n "$selected" ]; then
  # 获取文件的 MIME 类型
  mime_type=$(file --mime-type -b "$selected")

  # 初始化打开命令为空
  open_cmd=""

  # 遍历配置中的 MIME 类型模式，查找匹配的命令
  for pattern in "${!MIME_COMMANDS[@]}"; do
    # 将模式中的 '*' 转换为正则表达式
    regex="^${pattern//\*/.*}$"
    if [[ "$mime_type" =~ $regex ]]; then
      open_cmd="${MIME_COMMANDS[$pattern]}"
      break
    fi
  done

  # 如果未找到匹配的命令，使用默认命令
  if [ -z "$open_cmd" ]; then
    open_cmd="$DEFAULT_OPEN_COMMAND"
  fi

  # 检查命令是否是自定义函数
  if declare -F "$open_cmd" >/dev/null; then
    # 调用自定义函数
    "$open_cmd" "$selected" & disown
  else
    # 检查命令是否存在
    if command -v "$open_cmd" &>/dev/null; then
      # 使用对应的命令打开文件并隐藏终端
      nohup "$open_cmd" "$selected" >/dev/null 2>&1 &
      disown
    else
      echo "Error: Command '$open_cmd' not found. Please install it or update the configuration file."
      exit 1
    fi
  fi

fi
```

### 主要修改部分解释

1. **使用 `nohup` 和 `disown` 运行命令**

   在执行打开命令时，我们使用 `nohup` 将命令与当前终端会话分离，并将其放入后台运行。此外，通过 `>/dev/null 2>&1` 将标准输出和标准错误重定向到空设备，避免在终端中产生输出。

   ```bash
   nohup "$open_cmd" "$selected" >/dev/null 2>&1 &
   disown
   ```

2. **在调用自定义函数时也使用 `& disown`**

   如果打开命令是一个自定义函数，我们同样需要将其放入后台并与终端分离，以确保终端不会被占用。

   ```bash
   "$open_cmd" "$selected" & disown
   ```

### 完整修改后的逻辑

- **默认打开命令**：如果没有在配置文件中找到匹配的 MIME 类型命令，将使用 `xdg-open` 作为默认命令。
- **自定义命令**：如果配置文件中定义了特定的命令（例如 `imv`），脚本将使用这些命令打开文件，并确保它们在后台运行，终端不会被占用。
- **错误处理**：如果指定的命令不存在，脚本会提示错误并退出。

### 示例配置文件 `fopen_mime.conf`

确保你的配置文件 `fopen_mime.conf` 中正确配置了 MIME 类型与打开命令的映射。例如：

```ini
image/*=imv
text/plain=gedit
application/pdf=evince
```

### 使用说明

1. **确保脚本有执行权限**

   ```bash
   chmod +x fopen_fd_bat.sh
   ```

2. **运行脚本**

   ```bash
   ./fopen_fd_bat.sh
   ```

   选择文件后，脚本将根据文件的 MIME 类型使用相应的命令打开文件，并隐藏终端窗口，只显示打开的应用程序（如图片查看器）。

### 备注

- **图形环境**：上述方法适用于图形化桌面环境。如果你在纯终端环境下运行，可能无法实现完全隐藏终端的效果。
- **自定义函数**：如果你在配置文件中使用了自定义函数作为打开命令，请确保这些函数已在脚本中定义，并且它们能够正确处理传入的文件路径。

通过上述修改，执行 `fopen_fd_bat.sh` 时，选择的文件将通过相应的命令在后台打开，终端将不会被占用或显示，达到隐藏终端只显示文件的效果。
