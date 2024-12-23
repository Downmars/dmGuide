# 自由软件推荐配置指南

本指南汇总了我日常使用并强烈推荐的自由软件，适用于基于 Arch 的发行版，如 Arch Linux 和 Parabola GNU/Linux-libre。每个软件类别下提供了具体推荐的软件及其基本配置和使用说明，帮助你构建一个高效、自由且安全的工作环境。


---

## 1. 发行版

### Arch Linux + Parabola GNU/Linux-libre

**Arch Linux** 是一个以简洁、灵活和用户中心化著称的滚动更新发行版，适合有一定 Linux 使用经验的用户。

**Parabola GNU/Linux-libre** 是基于 Arch 的纯自由软件发行版，移除了所有非自由软件，适合追求完全自由软件环境的用户。

**安装与配置:**

- 参考 Arch Linux [官方安装指南](https://wiki.archlinux.org/title/Installation_guide)。
- 若选择 Parabola，参考 Parabola [安装文档](https://wiki.parabola.nu/installation/installation)。

---

## 2. 视频录制

### wf-recorder + slurp

**wf-recorder** 是一个 Wayland 屏幕录制工具，支持多种视频编码格式。

**slurp** 是一个 Wayland 区域选择工具，常用于与 wf-recorder 结合选择录制区域。

**安装:**

```bash
sudo pacman -S wf-recorder slurp
```

**基本用法:**

- 选择录制区域：

  ```bash
  wf-recorder -g "$(slurp)" -f output.mp4
  ```

- 全屏录制：

  ```bash
  wf-recorder -f output.mp4
  ```

---

## 3. 屏幕截图

### grim + slurp

**grim** 是一个 Wayland 屏幕截图工具，支持选择特定区域。

**slurp** 可用于与 grim 结合选择截图区域。

**安装:**

```bash
sudo pacman -S grim slurp
```

**基本用法:**

- 选择区域截图并保存：

  ```bash
  grim -g "$(slurp)" screenshot.png
  ```

- 全屏截图：

  ```bash
  grim screenshot.png
  ```

---

## 4. 视频剪辑

### ffmpeg

**ffmpeg** 是一个功能强大的多媒体处理工具，支持视频转换、剪辑、合并等多种操作。

**安装:**

```bash
sudo pacman -S ffmpeg
```

**基本用法:**

- 剪切视频（从第10秒开始，持续20秒）：

  ```bash
  ffmpeg -i input.mp4 -ss 00:00:10 -t 00:00:20 -c copy output.mp4
  ```

- 转换视频格式：

  ```bash
  ffmpeg -i input.avi output.mp4
  ```

---

## 5. 视频封面制作

### ImageMagick (配合 Bash 脚本)

**ImageMagick** 是一个强大的图像处理工具，可用于批量生成视频封面。

**安装:**

```bash
sudo pacman -S imagemagick
```

**示例 Bash 脚本：**

```bash
#!/bin/bash

# 从视频中提取封面帧
ffmpeg -i "$1" -ss 00:00:05 -vframes 1 cover.png

# 添加文本到封面
convert cover.png -gravity south -pointsize 36 -annotate +0+10 "视频标题" cover_with_text.png
```

**使用方法:**

```bash
./create_cover.sh input_video.mp4
```

---

## 6. 数字安全

### firejail + cryptsetup + gpg + ufw

**firejail**：一个轻量级的沙箱工具，用于隔离应用程序。

**cryptsetup**：用于管理加密卷和磁盘分区。

**gpg**：GNU Privacy Guard，用于加密和签名数据。

**ufw**：Uncomplicated Firewall，简化的防火墙配置工具。

**安装:**

```bash
sudo pacman -S firejail cryptsetup gnupg ufw
```

**基本配置:**

- **firejail**：

  运行应用程序时使用 firejail 进行隔离，例如：

  ```bash
  firejail firefox
  ```

- **cryptsetup**：

  初始化加密分区：

  ```bash
  sudo cryptsetup luksFormat /dev/sdX
  sudo cryptsetup open /dev/sdX encrypted_partition
  mkfs.ext4 /dev/mapper/encrypted_partition
  ```

- **gpg**：

  生成 GPG 密钥：

  ```bash
  gpg --full-generate-key
  ```

- **ufw**：

  启用并设置默认规则：

  ```bash
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw enable
  ```

---

## 7. 窗口管理器与桌面环境

### sway

**sway** 是一个基于 Wayland 的窗口管理器，兼容 i3 配置，适用于需要高效、可定制的平铺式窗口管理环境的用户。

**安装:**

```bash
sudo pacman -S sway
```

**基本配置:**

配置文件位于 `~/.config/sway/config`，可参考 [sway 配置文档](https://github.com/swaywm/sway/wiki) 进行定制。

**启动 sway:**

在登录管理器中选择 sway，或通过 TTY 启动：

```bash
sway
```

---

## 8. 任务状态栏

### waybar

**waybar** 是一个高度可定制的 Wayland 状态栏，支持模块化配置。

**安装:**

```bash
sudo pacman -S waybar
```

**基本配置:**

配置文件位于 `~/.config/waybar/config` 和 `~/.config/waybar/style.css`，可参考 [Waybar 文档](https://github.com/Alexays/Waybar) 进行定制。

**启动 waybar:**

在 sway 配置文件中添加：

```bash
exec waybar
```

---

## 9. 命令解释器

### bash

**bash** 是 GNU 项目的 Bourne Again Shell，是大多数 Linux 发行版的默认命令行解释器。

**安装:**

```bash
sudo pacman -S bash
```

**基本使用:**

- 配置文件位于 `~/.bashrc`，可添加自定义别名和函数。

---

## 10. 终端模拟器

### foot

**foot** 是一个高性能、支持 Wayland 的终端模拟器，具有现代化的外观和高效的渲染性能。

**安装:**

```bash
sudo pacman -S foot
```

**基本配置:**

配置文件位于 `~/.config/foot/foot.ini`，可调整主题、字体等设置。

**启动 foot:**

在 sway 配置文件中添加快捷键，例如：

```bash
bindsym $mod+Return exec foot
```

---

## 11. 音频服务器

### pipewire

**PipeWire** 是一个现代化的音频和视频服务器，支持低延迟音频处理和视频流管理。

**安装:**

```bash
sudo pacman -S pipewire pipewire-pulse pipewire-alsa pipewire-jack
```

**启用服务:**

```bash
systemctl --user enable --now pipewire pipewire-pulse
```

---

## 12. 应用启动器

### wmenu

**wmenu** 是一个简单高效的 Wayland 应用启动器，支持键盘快捷键启动应用。

**安装:**

```bash
sudo pacman -S wmenu
```

**基本配置:**

在 sway 配置文件中添加快捷键，例如：

```bash
bindsym $mod+d exec wmenu
```

---

## 13. 剪贴板管理

### wmenu + wl-clipboard + cliphist

**wl-clipboard**：Wayland 下的剪贴板工具，提供 `wl-copy` 和 `wl-paste` 命令。

**cliphist**：剪贴板历史管理工具。

**安装:**

```bash
sudo pacman -S wl-clipboard cliphist
```

**基本使用:**

- 复制内容：

  ```bash
  echo "Hello World" | wl-copy
  ```

- 粘贴内容：

  ```bash
  wl-paste
  ```

- 查看剪贴板历史：

  ```bash
  cliphist
  ```

---

## 14. 地址收藏夹

### wmenu + wtype

**wtype**：模拟键盘输入的工具，常用于自动输入收藏夹条目。

**安装:**

```bash
sudo pacman -S wmenu wtype
```

**基本使用:**

通过 wmenu 选择地址并使用 wtype 输入：

```bash
selected=$(wmenu --prompt "收藏网址")
echo "$selected" | wtype
```

---

## 15. 文本编辑器

### Neovim

**Neovim** 是一个现代化、可扩展的文本编辑器，兼容 Vim 插件，适合编程和文本编辑。

**安装:**

```bash
sudo pacman -S neovim
```

**基本配置:**

配置文件位于 `~/.config/nvim/init.vim` 或 `~/.config/nvim/init.lua`，可根据需求安装插件和自定义键位。

---

## 16. 邮件客户端

### NeoMutt

**NeoMutt** 是 Mutt 的一个分支，增加了更多功能和更好的配置选项。

**安装:**

```bash
sudo pacman -S neomutt
```

**基本配置:**

配置文件位于 `~/.config/neomutt/config`，可参考 [NeoMutt 文档](https://neomutt.org/guide/configuration) 进行设置。

---

## 17. 代码编辑器

### Code-OSS / VSCodium

**VSCodium** 是一个基于 VS Code 的开源版本，移除了微软的专有部分。

**安装:**

```bash
sudo pacman -S vscodium
```

**基本使用:**

- 启动 VSCodium：

  ```bash
  codium
  ```

- 安装所需扩展，如 Python、C/C++ 等。

---

## 18. 图片查看器

### imv

**imv** 是一个轻量级的图像查看器，支持基本的图像浏览和管理功能。

**安装:**

```bash
sudo pacman -S imv
```

**基本使用:**

- 打开图像：

  ```bash
  imv image.png
  ```

- 浏览目录中的图像：

  ```bash
  imv /path/to/images/
  ```

---

## 19. 视频播放器

### mpv

**mpv** 是一个开源的、高性能的媒体播放器，支持多种格式和高级功能。

**安装:**

```bash
sudo pacman -S mpv
```

**基本使用:**

- 播放视频：

  ```bash
  mpv video.mp4
  ```

- 播放在线视频：

  ```bash
  mpv https://example.com/video
  ```

---

## 20. 音乐播放器

### MPD + MPC + Ncmpcpp

**MPD (Music Player Daemon)**：后台音乐播放服务，支持多客户端连接。

**MPC (Music Player Command)**：MPD 的命令行客户端，用于控制播放。

**Ncmpcpp**：一个基于文本的 MPD 客户端，提供友好的用户界面。

**安装:**

```bash
sudo pacman -S mpd mpc ncmpcpp
```

**基本配置:**

编辑 MPD 配置文件 `~/.config/mpd/mpd.conf`，设置音乐目录和数据库位置。

启动 MPD：

```bash
systemctl --user enable --now mpd
```

**使用方法:**

- 使用 MPC 控制播放：

  ```bash
  mpc add song.mp3
  mpc play
  ```

- 使用 Ncmpcpp 浏览和播放音乐：

  ```bash
  ncmpcpp
  ```

---

## 21. 电子书浏览

### Zathura + zathura-pdf-mupdf

**Zathura** 是一个高度可定制的 PDF 阅读器，支持键盘导航。

**安装:**

```bash
sudo pacman -S zathura zathura-pdf-mupdf
```

**基本使用:**

- 打开 PDF 文件：

  ```bash
  zathura document.pdf
  ```

---

## 22. 输入法引擎

### fcitx5 + fcitx5-chinese-addons

**Fcitx5** 是一个现代化的输入法框架，支持多种输入法和语言。

**安装:**

```bash
sudo pacman -S fcitx5 fcitx5-chinese-addons fcitx5-configtool
```

**基本配置:**

- 设置环境变量，编辑 `~/.xprofile` 或 `~/.profile` 添加：

  ```bash
  export GTK_IM_MODULE=fcitx
  export QT_IM_MODULE=fcitx
  export XMODIFIERS="@im=fcitx"
  ```

- 启动 Fcitx5：

  ```bash
  fcitx5 &
  ```

- 使用 `fcitx5-configtool` 进行输入法配置。

---

## 23. 浏览器插件

### Dark Reader + Tridactyl + uBlock Origin

**Dark Reader**：为网页提供夜间模式。

**Tridactyl**：为 Firefox 提供类似 Vim 的键盘导航。

**uBlock Origin**：高效的广告拦截器。

**安装:**

- 在浏览器中搜索并安装相应插件：

  - [Dark Reader](https://addons.mozilla.org/firefox/addon/darkreader/)
  - [Tridactyl](https://addons.mozilla.org/firefox/addon/tridactyl-vim/)
  - [uBlock Origin](https://addons.mozilla.org/firefox/addon/ublock-origin/)

**基本使用:**

- 根据插件的文档进行个性化配置和快捷键设置。

---

## 24. 本地 AI

### Ollama

**Ollama** 是一个本地运行的 AI 模型管理工具，支持在本地进行自然语言处理任务。

**安装:**

参考 Ollama [官方文档](https://ollama.com/docs/installation) 进行安装。

**基本使用:**

- 下载并管理 AI 模型。
- 使用命令行接口与模型交互。

---

## 25. RSS 订阅

### Newsboat

**Newsboat** 是一个功能强大的命令行 RSS 阅读器，支持多种订阅管理功能。

**安装:**

```bash
sudo pacman -S newsboat
```

**基本配置:**

编辑 `~/.newsboat/config` 和 `~/.newsboat/urls` 添加订阅源。

**使用方法:**

```bash
newsboat
```

---

## 26. ToDo 列表

### Taskwarrior

**Taskwarrior** 是一个命令行的任务管理工具，支持强大的任务管理和过滤功能。

**安装:**

```bash
sudo pacman -S task
```

**基本使用:**

- 添加任务：

  ```bash
  task add 完成项目报告
  ```

- 查看任务：

  ```bash
  task list
  ```

- 标记任务为完成：

  ```bash
  task 1 done
  ```

---

## 27. 日程管理

### Calcurse

**Calcurse** 是一个命令行的日历和日程管理工具，支持任务和日历视图。

**安装:**

```bash
sudo pacman -S calcurse
```

**基本使用:**

- 启动 Calcurse：

  ```bash
  calcurse
  ```

- 添加日程和事件，使用快捷键进行导航和管理。

---

## 28. 文件管理

### Ranger + GNU Coreutils

**Ranger** 是一个基于文本的文件管理器，支持键盘快捷键和多窗格视图。

**安装:**

```bash
sudo pacman -S ranger coreutils
```

**基本使用:**

- 启动 Ranger：

  ```bash
  ranger
  ```

- 使用箭头键导航，按 `?` 查看帮助。

---

## 29. 文件下载

### Transmission-cli + httrack + yt-dlp

**Transmission-cli**：命令行版的 Transmission BT 客户端。

**httrack**：网站镜像工具，支持下载整个网站。

**yt-dlp**：一个强大的 YouTube 下载工具，支持多种视频平台。

**安装:**

```bash
sudo pacman -S transmission-cli httrack yt-dlp
```

**基本使用:**

- 使用 Transmission-cli 下载种子：

  ```bash
  transmission-cli torrent-file.torrent
  ```

- 使用 httrack 镜像网站：

  ```bash
  httrack https://example.com -O /path/to/save
  ```

- 使用 yt-dlp 下载视频：

  ```bash
  yt-dlp https://youtube.com/watch?v=example
  ```

---

## 30. 定时任务

### Crontab (Cronie)

**Cronie** 是一个包含 crontab 的定时任务调度器，适用于自动化任务。

**安装:**

```bash
sudo pacman -S cronie
```

**启用服务:**

```bash
sudo systemctl enable --now cronie
```

**基本使用:**

- 编辑定时任务：

  ```bash
  crontab -e
  ```

- 示例任务（每天凌晨2点执行备份脚本）：

  ```cron
  0 2 * * * /home/user/backup.sh
  ```

---

## 31. 文件共享

### Termux (rsync + ssh) + Samba + aft-mtp-mount

**rsync + ssh**：通过 SSH 进行安全的文件同步和传输。

**Samba**：实现跨平台的文件共享，适用于 Windows 和 Linux 系统。

**aft-mtp-mount**：用于将 Android 设备通过 MTP 挂载到 Linux 系统。

**安装:**

```bash
sudo pacman -S rsync openssh samba aft-mtp-mount
```

**基本使用:**

- **rsync + ssh**：

  ```bash
  rsync -avz /local/path user@remote:/remote/path
  ```

- **Samba**：

  编辑 Samba 配置文件 `/etc/samba/smb.conf`，添加共享目录。

  启动 Samba 服务：

  ```bash
  sudo systemctl enable --now smb nmb
  ```

- **aft-mtp-mount**：

  连接 Android 设备后，使用 aft-mtp-mount 挂载：

  ```bash
  aft-mtp-mount /dev/usb/path /mnt/android
  ```

---

## 32. 打字练习

### Gtypist + Ttyper

**Gtypist**：一个传统的打字练习工具，提供多种打字课程。

**Ttyper**：一个现代化的命令行打字练习工具，支持自定义练习文本。

**安装:**

```bash
sudo pacman -S gtypist ttyper
```

**基本使用:**

- 使用 Gtypist 开始打字练习：

  ```bash
  gtypist
  ```

- 使用 Ttyper 进行自定义练习：

  ```bash
  ttyper "The quick brown fox jumps over the lazy dog."
  ```

---

# 结语

以上是我个人推荐的自由软件配置指南，希望能帮助你构建一个高效、安全且自由的工作环境。每个软件都有其独特的功能和优势，根据个人需求进行选择和配置，可以极大提升你的工作和使用体验。祝你使用愉快！

# 资源链接

- [Arch Linux 官方文档](https://wiki.archlinux.org/)
- [Parabola GNU/Linux-libre](https://www.parabola.nu/)
- [sway 窗口管理器](https://swaywm.org/)
- [Neovim 官方网站](https://neovim.io/)
- [VSCodium 官方网站](https://vscodium.com/)
- [Newsboat GitHub](https://github.com/newsboat/newsboat)
- [Taskwarrior 官方文档](https://taskwarrior.org/docs/)
- [Calcurse 官方网站](https://calcurse.org/)
- [Ranger 文件管理器](https://ranger.github.io/)
- [mpv Player](https://mpv.io/)
- [PipeWire 官方文档](https://pipewire.org/)
- [Ollama 官方文档](https://ollama.com/docs)

---

希望这份指南对你有所帮助！如果有任何问题或建议，欢迎交流讨论。
