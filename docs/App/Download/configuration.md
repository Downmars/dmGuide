
# 自动下载配置指南：结合 `transmission-cli`、`HTTrack` 与 `yt-dlp` 根据当前剪贴板内容自动下载，并在 `waybar` 显示下载进度（隐藏无下载状态时的显示）

本指南将指导你在基于 Wayland 的系统（如使用 `sway` 窗口管理器的 Arch Linux 或 Parabola GNU/Linux-libre）上，配置并使用 `transmission-cli`、`HTTrack` 和 `yt-dlp`。通过按下快捷键时获取当前剪贴板内容，根据内容类型自动选择相应的下载工具进行下载。同时，下载进度将集成显示在 `waybar` 上，当没有活跃下载任务时，相应的状态模块将隐藏，以保持界面整洁。

## 目录

1. [安装所需软件](#1-安装所需软件)
2. [创建自动下载脚本](#2-创建自动下载脚本)
    - [a. 脚本内容](#a-脚本内容)
    - [b. 赋予执行权限](#b-赋予执行权限)
3. [配置 Sway 快捷键](#3-配置-sway-快捷键)
4. [配置 Waybar 显示下载进度](#4-配置-waybar-显示下载进度)
    - [a. Transmission-CLI 下载进度显示](#a-transmission-cli-下载进度显示)
    - [b. yt-dlp 下载进度显示](#b-yt-dlp-下载进度显示)
    - [c. HTTrack 下载进度显示](#c-httrack-下载进度显示)
5. [使用方法](#5-使用方法)
6. [常见问题与解决方法](#6-常见问题与解决方法)
7. [参考资源](#7-参考资源)

---

## 1. 安装所需软件

在基于 Arch 的发行版上，使用以下命令安装所需的软件：

```bash
sudo pacman -S transmission-cli httrack yt-dlp wmenu wl-clipboard waybar jq libnotify inotify-tools
```

- **transmission-cli**：Transmission 的命令行客户端，用于下载和管理 BitTorrent 种子。
- **HTTrack**：开源的网站镜像工具，可以将整个网站下载到本地浏览。
- **yt-dlp**：`youtube-dl` 的一个分支，功能更强大，用于从 YouTube、Bilibili 及其他网站下载视频和音频。
- **wmenu**：Wayland 下的轻量级菜单工具，类似于 `dmenu` 或 `rofi`。
- **wl-clipboard**：Wayland 下的剪贴板工具，提供 `wl-copy` 和 `wl-paste` 命令。
- **waybar**：Wayland 状态栏，用于显示下载状态。
- **jq**：命令行 JSON 处理工具，用于解析 `waybar` 配置。
- **libnotify**：发送桌面通知的工具。
- **inotify-tools**：提供监控文件系统事件的命令行工具，如 `inotifywait`。

---

## 2. 创建自动下载脚本

当按下快捷键时，该脚本将获取当前剪贴板内容，判断内容类型，并调用相应的下载工具进行下载。

### a. 脚本内容

将以下内容保存为 `~/bin/auto_download.sh`：

```bash
#!/bin/bash

# 自动下载脚本：auto_download.sh
# 获取当前剪贴板内容，判断类型并触发相应下载

# 定义下载目录
TRANSMISSION_DOWNLOAD_DIR="$HOME/Downloads/Transmission"
YTDLP_DOWNLOAD_DIR="$HOME/Videos"
HTTRACK_DOWNLOAD_DIR="$HOME/Websites"

# 创建下载目录（如果不存在）
mkdir -p "$TRANSMISSION_DOWNLOAD_DIR" "$YTDLP_DOWNLOAD_DIR" "$HTTRACK_DOWNLOAD_DIR"

# 获取当前剪贴板内容
CLIP_CONTENT=$(wl-paste)

# 检查剪贴板内容是否为空
if [ -z "$CLIP_CONTENT" ]; then
    notify-send "自动下载" "剪贴板为空，无可下载内容。"
    exit 0
fi

# 判断内容类型并触发下载
if [[ "$CLIP_CONTENT" =~ ^magnet:\?xt=urn:btih: ]]; then
    # 磁力链接，使用 transmission-cli 下载
    transmission-cli "$CLIP_CONTENT" --download-dir "$TRANSMISSION_DOWNLOAD_DIR" &
    notify-send "自动下载" "已启动 Transmission 下载磁力链接。"
elif [[ "$CLIP_CONTENT" =~ \.torrent$ ]]; then
    # 种子文件链接，使用 transmission-cli 下载
    transmission-cli "$CLIP_CONTENT" --download-dir "$TRANSMISSION_DOWNLOAD_DIR" &
    notify-send "自动下载" "已启动 Transmission 下载种子文件。"
elif [[ "$CLIP_CONTENT" =~ youtube\.com|youtu\.be|vimeo\.com|dailymotion\.com|bilibili\.com|b23\.tv ]]; then
    # 视频网站链接，使用 yt-dlp 下载
    yt-dlp "$CLIP_CONTENT" -o "$YTDLP_DOWNLOAD_DIR/%(title)s.%(ext)s" &
    notify-send "自动下载" "已启动 yt-dlp 下载视频。"
elif [[ "$CLIP_CONTENT" =~ ^https?:// ]]; then
    # 其他网站链接，使用 HTTrack 镜像网站
    SITE_NAME=$(echo "$CLIP_CONTENT" | awk -F/ '{print $3}')
    httrack "$CLIP_CONTENT" -O "$HTTRACK_DOWNLOAD_DIR/$SITE_NAME" "+*.$SITE_NAME/*" -v &
    notify-send "自动下载" "已启动 HTTrack 镜像网站。"
else
    notify-send "自动下载" "剪贴板内容类型未识别，无法下载。"
fi

exit 0
```

> **说明**：
>
> - **下载目录定义**：
>   - **Transmission**：`~/Downloads/Transmission`
>   - **yt-dlp**：`~/Videos`
>   - **HTTrack**：`~/Websites`
>
> - **剪贴板内容获取**：使用 `wl-paste` 获取当前剪贴板内容。
> - **内容类型判断**：
>   - **磁力链接**（以 `magnet:?xt=urn:btih:` 开头）：使用 `transmission-cli` 进行下载。
>   - **种子文件链接**（以 `.torrent` 结尾）：使用 `transmission-cli` 进行下载。
>   - **视频链接**（包含常见视频网站域名如 YouTube、Vimeo、Dailymotion、Bilibili）：使用 `yt-dlp` 进行下载。
>   - **其他网站链接**（以 `http://` 或 `https://` 开头）：使用 `HTTrack` 镜像网站。
> - **通知**：使用 `notify-send` 发送桌面通知，告知用户下载任务已启动或无法识别内容类型。
> - **后台运行**：所有下载任务均在后台运行，不阻塞脚本的执行。
>
> **注意**：
>
> - 确保下载目录存在，脚本中已包含创建目录的命令。
> - `yt-dlp` 会自动处理 Bilibili 视频，无需单独列出。

### b. 赋予执行权限

```bash
chmod +x ~/bin/auto_download.sh
```

---

## 3. 配置 Sway 快捷键

为方便按下快捷键时触发自动下载脚本，我们将配置 `sway` 快捷键。

### a. 编辑 Sway 配置文件

打开 `sway` 配置文件，通常位于 `~/.config/sway/config`：

```bash
nano ~/.config/sway/config
```

### b. 添加快捷键绑定

在配置文件中添加以下内容：

```bash
# 自动下载
bindsym $mod+Ctrl+Shift+D exec ~/bin/auto_download.sh
```

**说明**：

- **自动下载**：按下 `$mod+Ctrl+Shift+D` 将执行 `auto_download.sh` 脚本，处理当前剪贴板内容并触发下载任务。

### c. 重新加载 Sway 配置

保存配置文件后，重新加载 `sway` 配置：

```bash
swaymsg reload
```

---

## 4. 配置 Waybar 显示下载进度

为了在 `waybar` 上实时显示当前下载任务的状态和进度，并在没有下载任务时隐藏相应的模块，我们将为每个下载工具创建自定义模块脚本，并配置 `waybar` 来调用这些脚本。

### a. Transmission-CLI 下载进度显示

#### 1. 创建 Transmission 状态脚本

将以下内容保存为 `~/.config/waybar/transmission_status.sh`：

```bash
#!/bin/bash

# Transmission 状态脚本：transmission_status.sh
# 显示当前 Transmission 下载任务数量及总进度

# 获取 Transmission 下载任务信息
STATUS=$(transmission-remote -l 2>/dev/null)

if [ $? -ne 0 ]; then
    # Transmission 未连接或未运行
    exit 0
fi

# 解析任务数量和进度
ACTIVE_TASKS=$(echo "$STATUS" | grep -E "Downloading|Seeding" | wc -l)
TOTAL_TASKS=$(echo "$STATUS" | grep -c "Total:")

# 获取总进度百分比
TOTAL_PROGRESS=$(echo "$STATUS" | grep "Total:" | awk '{print $3}')

# 如果有活跃任务，输出 JSON
if [ "$ACTIVE_TASKS" -gt 0 ]; then
    echo "{\"text\": \"🎬 Transmission: $ACTIVE_TASKS/$TOTAL_TASKS 进度: $TOTAL_PROGRESS\", \"class\": \"transmission\"}"
else
    # 无活跃任务，输出空内容以隐藏模块
    exit 0
fi
```

#### 2. 赋予执行权限

```bash
chmod +x ~/.config/waybar/transmission_status.sh
```

#### 3. 更新 Waybar 配置

编辑 `~/.config/waybar/config`，添加自定义模块 `transmission`。假设你希望将其添加到 `modules-right` 部分。

```json
{
    "layer": "top",
    "position": "top",
    "modules-right": [
        "transmission",
        "yt_dlp",
        "httrack",
        /* 其他模块 */
    ],
    "custom/transmission": {
        "exec": "~/.config/waybar/transmission_status.sh",
        "interval": 10,
        "return-type": "json",
        "format": "{}",
        "max-length": 100
    },
    /* 其他配置 */
}
```

#### 4. 配置 Waybar 样式

编辑 `~/.config/waybar/style.css`，为 Transmission 模块添加样式：

```css
#transmission {
    color: #00FF00; /* 绿色表示 Transmission 活跃 */
    background-color: rgba(0, 0, 0, 0.5); /* 半透明黑色背景 */
    padding: 2px 6px;
    border-radius: 4px;
    font-weight: bold;
}

#transmission.empty {
    /* 当没有下载任务时，无需显示 */
    display: none;
}
```

**注意**：`waybar` 默认会隐藏模块如果脚本不输出任何内容。因此，确保在没有活跃下载任务时，脚本不输出任何 JSON。

#### 5. 重新加载 Waybar

保存配置后，重新加载 `waybar` 以应用更改：

```bash
pkill waybar
waybar &
```

### b. yt-dlp 下载进度显示

#### 1. 创建 yt-dlp 状态脚本

将以下内容保存为 `~/.config/waybar/yt_dlp_status.sh`：

```bash
#!/bin/bash

# yt-dlp 状态脚本：yt_dlp_status.sh
# 显示当前 yt-dlp 下载任务数量

# 获取 yt-dlp 进程数量
YTDLP_COUNT=$(pgrep -fc yt-dlp)

# 如果有活跃下载任务，输出 JSON
if [ "$YTDLP_COUNT" -gt 0 ]; then
    echo "{\"text\": \"🎥 yt-dlp: $YTDLP_COUNT 下载中\", \"class\": \"yt_dlp\"}"
else
    # 无活跃任务，输出空内容以隐藏模块
    exit 0
fi
```

#### 2. 赋予执行权限

```bash
chmod +x ~/.config/waybar/yt_dlp_status.sh
```

#### 3. 更新 Waybar 配置

编辑 `~/.config/waybar/config`，添加自定义模块 `yt_dlp`：

```json
{
    "layer": "top",
    "position": "top",
    "modules-right": [
        "transmission",
        "yt_dlp",
        "httrack",
        /* 其他模块 */
    ],
    "custom/yt_dlp": {
        "exec": "~/.config/waybar/yt_dlp_status.sh",
        "interval": 10,
        "return-type": "json",
        "format": "{}",
        "max-length": 100
    },
    /* 其他配置 */
}
```

#### 4. 配置 Waybar 样式

编辑 `~/.config/waybar/style.css`，为 yt-dlp 模块添加样式：

```css
#yt_dlp {
    color: #FFD700; /* 金色表示 yt-dlp 活跃 */
    background-color: rgba(0, 0, 0, 0.5); /* 半透明黑色背景 */
    padding: 2px 6px;
    border-radius: 4px;
    font-weight: bold;
}

#yt_dlp.empty {
    /* 当没有下载任务时，无需显示 */
    display: none;
}
```

**说明**：`waybar` 会自动隐藏模块当脚本不输出任何内容。

#### 5. 重新加载 Waybar

```bash
pkill waybar
waybar &
```

### c. HTTrack 下载进度显示

#### 1. 创建 HTTrack 状态脚本

将以下内容保存为 `~/.config/waybar/httrack_status.sh`：

```bash
#!/bin/bash

# HTTrack 状态脚本：httrack_status.sh
# 显示当前 HTTrack 下载任务数量

# 获取 HTTrack 进程数量
HTTRACK_COUNT=$(pgrep -fc httrack)

# 如果有活跃下载任务，输出 JSON
if [ "$HTTRACK_COUNT" -gt 0 ]; then
    echo "{\"text\": \"🌐 HTTrack: $HTTRACK_COUNT 下载中\", \"class\": \"httrack\"}"
else
    # 无活跃任务，输出空内容以隐藏模块
    exit 0
fi
```

#### 2. 赋予执行权限

```bash
chmod +x ~/.config/waybar/httrack_status.sh
```

#### 3. 更新 Waybar 配置

编辑 `~/.config/waybar/config`，添加自定义模块 `httrack`：

```json
{
    "layer": "top",
    "position": "top",
    "modules-right": [
        "transmission",
        "yt_dlp",
        "httrack",
        /* 其他模块 */
    ],
    "custom/httrack": {
        "exec": "~/.config/waybar/httrack_status.sh",
        "interval": 10,
        "return-type": "json",
        "format": "{}",
        "max-length": 100
    },
    /* 其他配置 */
}
```

#### 4. 配置 Waybar 样式

编辑 `~/.config/waybar/style.css`，为 HTTrack 模块添加样式：

```css
#httrack {
    color: #1E90FF; /* 蓝色表示 HTTrack 活跃 */
    background-color: rgba(0, 0, 0, 0.5); /* 半透明黑色背景 */
    padding: 2px 6px;
    border-radius: 4px;
    font-weight: bold;
}

#httrack.empty {
    /* 当没有下载任务时，无需显示 */
    display: none;
}
```

#### 5. 重新加载 Waybar

```bash
pkill waybar
waybar &
```

---

## 5. 使用方法

### a. 按下快捷键触发自动下载

1. **复制内容到剪贴板**

   - **磁力链接**：复制以 `magnet:?xt=urn:btih:` 开头的链接。
   - **种子文件链接**：复制以 `.torrent` 结尾的 URL。
   - **视频链接**：复制包含常见视频网站域名（如 YouTube、Vimeo、Dailymotion、Bilibili）的 URL。
   - **网站链接**：复制其他网站的 URL。

2. **按下快捷键**

   按下 `$mod+Ctrl+Shift+D` 将执行 `auto_download.sh` 脚本，处理当前剪贴板内容并触发相应的下载任务。

3. **查看下载状态**

   在 `waybar` 上查看各下载工具的当前任务状态和进度：

   - **Transmission**：显示当前下载任务数量及总进度。
   - **yt-dlp**：显示当前活跃的 yt-dlp 下载任务数量。
   - **HTTrack**：显示当前活跃的 HTTrack 下载任务数量。

   **注意**：当没有活跃下载任务时，相应的模块将不会在 `waybar` 上显示，从而保持界面整洁。

### b. 手动访问剪贴板并触发下载

虽然自动下载功能已经集成，但你仍然可以手动管理下载任务：

1. **按下快捷键**

   按下 `$mod+Ctrl+Shift+D` 将执行 `auto_download.sh` 脚本，处理当前剪贴板内容并触发下载任务。

2. **查看下载状态**

   同上，通过 `waybar` 查看各下载工具的任务状态和进度。

### c. 粘贴剪贴板内容

无论是自动触发还是手动选择，复制的内容也会保存在剪贴板中，你可以在任何支持粘贴的应用中（如聊天工具、文档编辑器等）使用 `Ctrl+V` 或右键粘贴来插入内容。

---

## 6. 常见问题与解决方法

### 1. 快捷键无响应

**原因**：`sway` 快捷键配置错误或脚本路径不正确。

**解决方法**：

- 确保快捷键绑定正确指向脚本：

  ```bash
  bindsym $mod+Ctrl+Shift+D exec ~/bin/auto_download.sh
  ```

- 确保脚本路径正确，并且脚本具有执行权限：

  ```bash
  chmod +x ~/bin/auto_download.sh
  ```

- 重新加载 `sway` 配置：

  ```bash
  swaymsg reload
  ```

### 2. `transmission-cli` 无法连接种子

**原因**：防火墙或网络设置阻止了传输端口。

**解决方法**：

- 检查防火墙设置，确保 Transmission 使用的端口开放。
- 确保网络连接稳定，并且种子有足够的活跃种子。

### 3. `yt-dlp` 无法下载视频

**原因**：网站更新导致 `yt-dlp` 的解析规则失效。

**解决方法**：

- 更新 `yt-dlp` 到最新版本：

  ```bash
  yt-dlp -U
  ```

- 检查是否需要提供认证信息（如下载付费内容）。

### 4. `HTTrack` 下载不完整

**原因**：网站结构复杂，动态内容或 JavaScript 渲染的页面无法正确抓取。

**解决方法**：

- 尝试调整 `HTTrack` 的选项，如增加 `--mirror`、调整链接过滤规则。
- 对于动态内容，考虑使用其他工具或手动下载。

### 5. 自动下载未触发

**原因**：`auto_download.sh` 脚本未正确运行或快捷键配置错误。

**解决方法**：

- 确保快捷键绑定正确指向脚本，并且脚本具有执行权限。
- 检查脚本是否有错误：

  ```bash
  bash -x ~/bin/auto_download.sh
  ```

- 查看系统日志以获取错误信息（如果通过 systemd 管理服务）：

  ```bash
  journalctl --user -u auto_download.service
  ```

### 6. 下载进度未显示在 Waybar 上

**原因**：Waybar 自定义模块脚本未正确执行或配置文件错误。

**解决方法**：

- 确保所有自定义模块脚本具有执行权限：

  ```bash
  chmod +x ~/.config/waybar/*.sh
  ```

- 测试脚本是否正常工作：

  ```bash
  ~/.config/waybar/transmission_status.sh
  ~/.config/waybar/yt_dlp_status.sh
  ~/.config/waybar/httrack_status.sh
  ```

  每个脚本应输出有效的 JSON 内容（如有活跃下载任务）。

- 检查 Waybar 配置文件是否正确引用自定义模块。
- 重新加载 Waybar：

  ```bash
  pkill waybar
  waybar &
  ```

### 7. 剪贴板内容无法复制或粘贴

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

### 8. 最新的剪贴板内容未被识别

**原因**：脚本未正确获取或判断剪贴板内容。

**解决方法**：

- 确保 `auto_download.sh` 脚本正确获取当前剪贴板内容：

  ```bash
  wl-paste
  ```

- 确保剪贴板内容符合预期格式（如磁力链接、.torrent URL、视频网站 URL 或其他网站 URL）。
- 检查脚本中的正则表达式是否准确匹配内容类型，特别是新增的 Bilibili URL。
- 确保下载目录已正确创建，并且脚本中定义的路径正确。

---

## 7. 参考资源

- [Transmission 官方文档](https://transmissionbt.com/docs/)
- [HTTrack 官方网站](https://www.httrack.com/)
- [yt-dlp GitHub 仓库](https://github.com/yt-dlp/yt-dlp)
- [wmenu GitHub 仓库](https://github.com/bugaevc/wmenu)
- [wl-clipboard GitHub 仓库](https://github.com/bugaevc/wl-clipboard)
- [sway 窗口管理器文档](https://swaywm.org/docs/)
- [waybar GitHub 仓库](https://github.com/Alexays/Waybar)
- [libnotify 官方文档](https://developer.gnome.org/libnotify/stable/)
- [Arch Linux Wiki: Transmission](https://wiki.archlinux.org/title/Transmission)
- [Arch Linux Wiki: HTTrack](https://wiki.archlinux.org/title/HTTrack)
- [Arch Linux Wiki: yt-dlp](https://wiki.archlinux.org/title/Yt-dlp)
- [Arch Linux Wiki: Clipboard](https://wiki.archlinux.org/title/Clipboard)

---

## 小结

通过本指南，你已成功配置了 `transmission-cli`、`HTTrack` 和 `yt-dlp`，并结合剪贴板管理工具 `wl-clipboard` 和快捷键，实现在按下快捷键时根据当前剪贴板内容自动触发相应的下载任务的功能。同时，通过 `waybar` 的自定义模块，你可以实时查看各下载工具的任务状态和进度。当没有活跃下载任务时，相应的模块将自动隐藏，保持界面整洁。这一配置使得下载过程更加高效和便捷。

**具体包括**：

1. **自动下载触发**：通过按下快捷键 `$mod+Ctrl+Shift+D`，自动获取当前剪贴板内容，判断内容类型（磁力链接、种子文件链接、视频网站 URL 包括 Bilibili、其他网站 URL），并使用相应的下载工具启动下载任务。
2. **下载目录设置**：
   - **Transmission**：所有通过 `transmission-cli` 下载的文件将保存到 `~/Downloads/Transmission/`。
   - **yt-dlp**：所有通过 `yt-dlp` 下载的视频将保存到 `~/Videos/`。
   - **HTTrack**：所有通过 `HTTrack` 镜像的网站将保存到 `~/Websites/`。
3. **下载进度显示**：通过 `waybar` 的自定义模块脚本，实时显示 `transmission-cli`、`yt-dlp` 和 `HTTrack` 的下载任务数量和进度。
4. **隐藏无下载状态时的显示**：当没有活跃下载任务时，相应的 Waybar 模块将不显示，保持界面整洁。
5. **桌面通知**：每次下载任务启动时，通过 `notify-send` 发送桌面通知，告知用户下载状态。
6. **界面美化**：通过定制 `waybar` 的样式，使状态显示更加美观和用户友好。
7. **后台运行与稳定性**：所有下载任务在后台运行，不阻塞脚本的执行，确保监控脚本持续稳定运行。

根据个人需求，你可以进一步优化这些工具的配置，如调整下载路径、增加下载任务的管理功能、提升剪贴板处理的智能化等。若在配置过程中遇到任何问题，欢迎参考各工具的官方文档或在相关社区寻求帮助。

# 版权信息

本指南由用户基于自身经验编写，旨在分享高效的自由软件配置方法。如有转载请注明出处。

# 结束语

希望这份自动下载配置指南对你有所帮助！如果有任何问题或建议，欢迎在相关社区交流讨论。
```
