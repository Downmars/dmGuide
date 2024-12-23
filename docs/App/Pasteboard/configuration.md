
# 剪贴板管理指南：使用 `wmenu`、`wl-clipboard` 和 `cliphist` 在 Wayland 环境下高效管理剪贴板

本指南将帮助你在基于 Wayland 的系统（如使用 `sway` 窗口管理器的 Arch Linux 或 Parabola GNU/Linux-libre）上，配置并使用 `wmenu`、`wl-clipboard` 和 `cliphist` 进行剪贴板管理。配置将支持剪贴板历史记录的查看与选择，集成 `waybar` 显示剪贴板状态，并通过快捷键方便地访问剪贴板历史。

## 目录

1. [安装所需软件](#1-安装所需软件)
2. [配置 `cliphist`](#2-配置-cliphist)
3. [创建剪贴板选择脚本](#3-创建剪贴板选择脚本)
4. [配置 `waybar`](#4-配置-waybar)
5. [配置 `sway` 快捷键](#5-配置-sway-快捷键)
6. [使用方法](#6-使用方法)
7. [管理剪贴板文件](#7-管理剪贴板文件)
8. [常见问题与解决方法](#8-常见问题与解决方法)
9. [参考资源](#9-参考资源)

---

## 1. 安装所需软件

在基于 Arch 的发行版上，使用以下命令安装 `wmenu`、`wl-clipboard`、`cliphist`、`waybar` 以及其他必要工具：

```bash
sudo pacman -S wmenu wl-clipboard cliphist waybar jq libnotify
```

- **wmenu**：Wayland 下的轻量级菜单工具，类似于 `dmenu` 或 `rofi`。
- **wl-clipboard**：Wayland 下的剪贴板工具，提供 `wl-copy` 和 `wl-paste` 命令。
- **cliphist**：Wayland 下的剪贴板历史管理工具，支持记录和选择剪贴板内容。
- **waybar**：Wayland 状态栏，用于显示剪贴板状态。
- **jq**：命令行 JSON 处理工具，用于解析 `waybar` 配置。
- **libnotify**：发送桌面通知的工具。

---

## 2. 配置 `cliphist`

`cliphist` 用于管理剪贴板历史记录，并提供命令行接口供其他工具调用。

### a. 启动 `cliphist`

创建一个 systemd 用户服务来自动启动 `cliphist`：

1. **创建服务文件**

    ```bash
    mkdir -p ~/.config/systemd/user
    nano ~/.config/systemd/user/cliphist.service
    ```

2. **添加以下内容到 `cliphist.service`**

    ```ini
    [Unit]
    Description=Clipboard History Manager for Wayland

    [Service]
    ExecStart=/usr/bin/cliphist daemon

    [Install]
    WantedBy=default.target
    ```

3. **启动并启用服务**

    ```bash
    systemctl --user daemon-reload
    systemctl --user enable --now cliphist.service
    ```

### b. 配置 `cliphist`

可以通过创建配置文件来定制 `cliphist` 的行为。

1. **创建配置文件**

    ```bash
    mkdir -p ~/.config/cliphist
    nano ~/.config/cliphist/config.toml
    ```

2. **添加以下示例配置**

    ```toml
    # ~/.config/cliphist/config.toml

    [settings]
    # 最大保存的剪贴板历史数量
    max_items = 100

    # 是否启用自动清理
    auto_clean = true

    # 清理旧项目的条件
    clean_after_days = 30
    ```

    > **说明**：
    >
    > - `max_items`：最大保存的剪贴板历史数量。
    > - `auto_clean`：是否启用自动清理旧的剪贴板项。
    > - `clean_after_days`：清理超过多少天的剪贴板项。

---

## 3. 创建剪贴板选择脚本

为了通过快捷键方便地选择和粘贴剪贴板历史中的内容，我们将创建一个脚本，使用 `wmenu` 结合 `cliphist` 和 `wl-clipboard`。

### a. 脚本内容

将以下内容保存为 `~/bin/clipmenu.sh` 并赋予执行权限：

```bash
#!/bin/bash

# 剪贴板选择脚本：clipmenu.sh
# 使用 wmenu 显示剪贴板历史，选择后复制到剪贴板

# 获取剪贴板历史
HISTORY=$(cliphist list | tac)

# 使用 wmenu 选择项
SELECTED=$(echo "$HISTORY" | wmenu -p "剪贴板历史" -l 20)

# 如果有选择，复制到剪贴板
if [ -n "$SELECTED" ]; then
    echo "$SELECTED" | wl-copy
    notify-send "剪贴板" "已复制选择的内容到剪贴板"
fi

exit 0
```

### b. 赋予执行权限

```bash
chmod +x ~/bin/clipmenu.sh
```

### c. 脚本说明

- **功能**：
  - 使用 `cliphist` 获取剪贴板历史记录。
  - 使用 `wmenu` 显示历史记录供用户选择。
  - 选择后将内容复制到剪贴板，并发送通知。
- **脚本参数**：
  - `-p "剪贴板历史"`：设置 `wmenu` 的提示文字。
  - `-l 20`：设置 `wmenu` 的最大显示行数。

---

## 4. 配置 `waybar`

虽然主要的剪贴板管理通过脚本和快捷键完成，但你可以在 `waybar` 上显示当前剪贴板内容或状态。

### a. 创建自定义模块脚本（可选）

如果希望在 `waybar` 上显示最新的剪贴板内容，可以创建一个自定义脚本。

将以下内容保存为 `~/.config/waybar/clipboard.sh` 并赋予执行权限：

```bash
#!/bin/bash

# 剪贴板状态脚本：clipboard.sh
# 显示当前剪贴板内容的简要信息

CLIP=$(wl-paste)

# 获取剪贴板内容的前30个字符
DISPLAY_CLIP=$(echo "$CLIP" | head -c 30)

# 输出 JSON 格式供 waybar 使用
echo "{\"text\": \"📋 $DISPLAY_CLIP\", \"class\": \"clipboard\"}"
```

### b. 赋予执行权限

```bash
chmod +x ~/.config/waybar/clipboard.sh
```

### c. 更新 `waybar` 配置

编辑 `~/.config/waybar/config`，添加自定义模块 `clipboard`。假设你希望将其添加到 `modules-right` 部分。

```json
{
    "layer": "top",
    "position": "top",
    "modules-right": [
        "clipboard",
        /* 其他模块 */
    ],
    "custom/clipboard": {
        "exec": "~/.config/waybar/clipboard.sh",
        "interval": 5,
        "return-type": "json",
        "format": "{}",
        "max-length": 100
    },
    /* 其他配置 */
}
```

### d. 配置 `waybar` 样式（可选）

编辑 `~/.config/waybar/style.css`，为剪贴板模块添加样式：

```css
#clipboard {
    color: #00FF00; /* 绿色表示剪贴板有内容 */
    padding: 2px 6px;
    border-radius: 4px;
    font-weight: bold;
}

#clipboard.empty {
    color: #FF0000; /* 红色表示剪贴板为空 */
}
```

### e. 重新加载 `waybar`

保存配置后，重新加载 `waybar` 以应用更改：

```bash
pkill waybar
waybar &
```

> **注意**：`clipboard.sh` 脚本当前仅显示剪贴板内容的前30个字符。你可以根据需求调整显示内容或格式。

---

## 5. 配置 `sway` 快捷键

为了避免与屏幕录制快捷键冲突，我们将为剪贴板管理选择不同的快捷键组合。

### a. 编辑 `sway` 配置文件

打开 `sway` 配置文件，通常位于 `~/.config/sway/config`：

```bash
nano ~/.config/sway/config
```

### b. 添加快捷键绑定

在配置文件中添加以下内容：

```bash
# 剪贴板历史选择
bindsym $mod+Ctrl+Shift+C exec ~/bin/clipmenu.sh
```

**说明**：

- **剪贴板历史选择**：按下 `$mod+Ctrl+Shift+C` 启动剪贴板历史选择菜单。

### c. 重新加载 `sway` 配置

保存配置文件后，重新加载 `sway` 配置：

```bash
swaymsg reload
```

---

## 6. 使用方法

### a. 访问剪贴板历史

1. **按下快捷键**：按下 `$mod+Ctrl+Shift+C`。
2. **选择剪贴板内容**：
   - `wmenu` 将弹出一个菜单，列出剪贴板历史记录。
   - 使用键盘上下箭头或鼠标选择你想要的内容。
3. **复制选择的内容**：
   - 选择后，所选内容将自动复制到剪贴板。
   - 桌面通知将显示已复制的信息。

### b. 查看当前剪贴板内容

如果你在 `waybar` 上配置了剪贴板模块，可以实时查看当前剪贴板内容的简要信息。

### c. 粘贴剪贴板内容

在任何支持粘贴的应用中（如聊天工具、文档编辑器等），使用 `Ctrl+V` 或右键粘贴来插入剪贴板内容。

---

## 7. 管理剪贴板文件

`cliphist` 会自动管理剪贴板历史记录，根据配置文件中的设置进行保存和清理。

### a. 配置 `cliphist`

如前所述，可以通过 `~/.config/cliphist/config.toml` 文件配置 `cliphist` 的行为，例如最大保存数量和自动清理规则。

### b. 手动管理剪贴板历史

如果需要手动清理或导出剪贴板历史，可以使用 `cliphist` 提供的命令：

- **查看剪贴板历史**：

    ```bash
    cliphist list
    ```

- **清除剪贴板历史**：

    ```bash
    cliphist clear
    ```

- **导出剪贴板历史**：

    ```bash
    cliphist export > ~/cliphist_backup.txt
    ```

---

## 8. 常见问题与解决方法

### 1. 快捷键无响应

**原因**：`sway` 快捷键配置错误或脚本路径不正确。

**解决方法**：

- 确保快捷键绑定正确指向脚本：

    ```bash
    bindsym $mod+Ctrl+Shift+C exec ~/bin/clipmenu.sh
    ```

- 确保脚本路径正确，并且脚本具有执行权限：

    ```bash
    chmod +x ~/bin/clipmenu.sh
    ```

- 重新加载 `sway` 配置：

    ```bash
    swaymsg reload
    ```

### 2. `cliphist` 未记录剪贴板内容

**原因**：`cliphist` 服务未正确启动或配置文件错误。

**解决方法**：

- 检查 `cliphist` 服务状态：

    ```bash
    systemctl --user status cliphist.service
    ```

- 如果服务未运行，启动并启用：

    ```bash
    systemctl --user enable --now cliphist.service
    ```

- 检查配置文件 `~/.config/cliphist/config.toml` 是否正确。

### 3. `wmenu` 无法显示剪贴板历史

**原因**：脚本未正确获取剪贴板历史或 `wmenu` 未正确安装。

**解决方法**：

- 确保 `wmenu` 已正确安装：

    ```bash
    sudo pacman -S wmenu
    ```

- 测试 `wmenu` 是否正常工作：

    ```bash
    echo -e "选项1\n选项2\n选项3" | wmenu
    ```

- 确保 `cliphist` 正在记录剪贴板历史：

    ```bash
    cliphist list
    ```

### 4. 剪贴板内容无法复制或粘贴

**原因**：`wl-copy` 未正确执行或剪贴板工具未运行。

**解决方法**：

- 确保 `wl-clipboard` 已正确安装：

    ```bash
    sudo pacman -S wl-clipboard
    ```

- 测试 `wl-copy` 是否正常工作：

    ```bash
    echo "Test" | wl-copy
    wl-paste
    ```

    如果输出为 `Test`，则 `wl-copy` 正常工作。

- 确保在 Wayland 会话中运行剪贴板工具。如果使用其他剪贴板管理器，确保它们与 `wl-copy` 兼容。

### 5. 桌面通知未显示

**原因**：`notify-send` 未正确安装或通知系统未配置。

**解决方法**：

- 确保 `libnotify` 已安装：

    ```bash
    sudo pacman -S libnotify
    ```

- 测试 `notify-send` 是否正常工作：

    ```bash
    notify-send "测试通知" "如果你能看到这条消息，notify-send 正常工作。"
    ```

- 检查通知守护进程是否在运行（如 `mako`、`dunst` 等）。

### 6. `cliphist` 无法启动

**原因**：配置文件错误或权限问题。

**解决方法**：

- 检查配置文件 `~/.config/cliphist/config.toml` 是否存在且格式正确。
- 查看 `cliphist` 服务日志以获取更多信息：

    ```bash
    journalctl --user -u cliphist.service
    ```

### 7. `waybar` 上剪贴板模块不显示内容

**原因**：`clipboard.sh` 脚本未正确执行或权限问题。

**解决方法**：

- 确保 `clipboard.sh` 脚本具有执行权限：

    ```bash
    chmod +x ~/.config/waybar/clipboard.sh
    ```

- 测试脚本是否正常工作：

    ```bash
    ~/.config/waybar/clipboard.sh
    ```

    应输出类似以下内容：

    ```json
    {"text": "📋 当前剪贴板内容...", "class": "clipboard"}
    ```

- 检查 `waybar` 配置文件是否正确引用自定义模块。

---

## 9. 参考资源

- [wmenu GitHub 仓库](https://github.com/someuser/wmenu) *(请根据实际仓库地址替换)*
- [wl-clipboard GitHub 仓库](https://github.com/bugaevc/wl-clipboard)
- [cliphist GitHub 仓库](https://github.com/ah-/cliphist)
- [sway 窗口管理器文档](https://swaywm.org/docs/)
- [waybar GitHub 仓库](https://github.com/Alexays/Waybar)
- [Arch Linux wiki: Clipboard](https://wiki.archlinux.org/title/Clipboard)
- [Arch Linux wiki: cliphist](https://wiki.archlinux.org/title/Cliphist) *(如果有相关页面)*

---

## 小结

通过本指南，你已成功配置了 `wmenu`、`wl-clipboard` 和 `cliphist` 以在 Wayland 环境下高效管理剪贴板。结合 `waybar` 的剪贴板状态显示和快捷键的启动与选择功能，剪贴板管理过程变得更加便捷与直观。选择不同的快捷键组合，避免了与屏幕录制快捷键的冲突。根据个人需求，可以进一步优化剪贴板管理参数，提升使用体验。

如果在配置过程中遇到任何问题或有进一步的优化需求，欢迎参考相关工具的官方文档或寻求社区支持。

# 版权信息

本指南由用户基于自身经验编写，旨在分享高效的自由软件配置方法。如有转载请注明出处。

# 结束语

希望这份剪贴板管理指南对你有所帮助！如果有任何问题或建议，欢迎在相关社区交流讨论。
```
