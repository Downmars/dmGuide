当然，以下是 **Taskwarrior** 命令结构中四个主要部分的详细参数列表。这四个部分分别是 **过滤器（Filter）**、**命令（Command）**、**修改（Modifications）** 和 **杂项（Miscellaneous）**。了解这些参数有助于更高效地管理和操作任务。

---

## 1. 过滤器（Filter）

**过滤器** 用于筛选特定的任务，以便对其进行查看或操作。过滤器可以基于任务的各种属性，如状态、项目、标签等。

### 常用过滤器参数

- **状态过滤器**：
  - `status:pending`：显示所有待办任务。
  - `status:completed`：显示已完成的任务。
  - `status:deleted`：显示已删除的任务。
  - `status:waiting`：显示等待中的任务。
  - `status:blocked`：显示被阻塞的任务。
  
- **项目过滤器**：
  - `project:Garden`：显示项目为 Garden 的所有任务。
  - `project:Home`：显示项目为 Home 的所有任务。

- **标签过滤器**：
  - `+home`：显示所有带有 `home` 标签的任务。
  - `+urgent`：显示所有带有 `urgent` 标签的任务。
  - `+work +urgent`：同时带有 `work` 和 `urgent` 标签的任务。

- **优先级过滤器**：
  - `priority:H`：显示高优先级任务。
  - `priority:M`：显示中优先级任务。
  - `priority:L`：显示低优先级任务。

- **日期过滤器**：
  - `due.before:2023-12-31`：显示截止日期在 2023-12-31 之前的任务。
  - `due.after:2023-01-01`：显示截止日期在 2023-01-01 之后的任务。
  - `scheduled.before:2023-12-31`：显示计划日期在 2023-12-31 之前的任务。
  - `scheduled.after:2023-01-01`：显示计划日期在 2023-01-01 之后的任务。

- **其他过滤器**：
  - `depends:5`：显示依赖任务 ID 为 5 的任务。
  - `annotations:urgent`：显示带有 `urgent` 注释的任务。
  - `uuid:abc123`：通过 UUID 精确定位任务。

### 组合过滤器

过滤器可以组合使用，以实现更精确的任务筛选。例如：

- `project:Home +urgent status:pending`：显示项目为 Home，带有 urgent 标签且状态为 pending 的所有任务。
- `priority:H or priority:M`：显示高或中优先级的任务。

### 特殊过滤器

- `all`：显示所有任务，包括待办、已完成和已删除的任务。
- `next`：显示最紧急的任务，通常根据优先级和截止日期自动排序。
- `overdue`：显示所有已逾期的任务。
- `recurring`：显示所有重复的任务。

---

## 2. 命令（Command）

**命令** 指定对筛选出的任务执行的操作。Taskwarrior 提供了多种命令，以满足不同的任务管理需求。

### 常用命令列表

- **添加任务**：
  - `add [描述]`：添加一个新任务。
    - 示例：`task add "买牛奶" project:Home +urgent`

- **修改任务**：
  - `modify [修改参数]`：修改现有任务的属性。
    - 示例：`task 1 modify project:Garden priority:H`

- **完成任务**：
  - `done`：标记任务为已完成。
    - 示例：`task 2 done`

- **删除任务**：
  - `delete`：标记任务为已删除。
    - 示例：`task 3 delete`

- **标注任务**：
  - `annotate [注释]`：为任务添加注释。
    - 示例：`task 4 annotate "与客户电话沟通"`

- **撤销操作**：
  - `undo`：撤销最近的更改。
    - 示例：`task undo`

- **复制任务**：
  - `duplicate`：复制一个任务。
    - 示例：`task 5 duplicate`

- **编辑任务**：
  - `edit`：在默认文本编辑器中编辑任务。
    - 示例：`task 6 edit`

- **获取帮助**：
  - `help`：显示高层次的帮助信息。
    - 示例：`task help`

- **显示任务信息**：
  - `info`：显示任务的详细信息。
    - 示例：`task 7 info`

- **导出任务**：
  - `export`：将任务导出为 JSON 格式。
    - 示例：`task export > tasks.json`

- **同步任务**：
  - `synchronize`：同步任务与其他实例。
    - 示例：`task synchronize`

- **配置设置**：
  - `config`：修改 Taskwarrior 的配置设置。
    - 示例：`task config editor vim`

- **显示版本**：
  - `version`：显示 Taskwarrior 的版本信息。
    - 示例：`task version`

### 组合命令

一些命令可以与过滤器组合使用，以针对特定的任务群体执行操作。例如：

- `task +home modify priority:H`：将所有带有 `home` 标签的任务的优先级设置为高。
- `task 1,3,5 done`：将任务 ID 为 1、3、5 的任务标记为已完成。

---

## 3. 修改（Modifications）

**修改参数** 用于更改任务的属性或状态。这些参数通常与特定的命令（如 `modify`）结合使用，以调整任务的详细信息。

### 常用修改参数

- **项目（Project）**：
  - `project:[项目名称]`：更改任务所属的项目。
    - 示例：`project:Garden`

- **优先级（Priority）**：
  - `priority:H`：设置为高优先级。
  - `priority:M`：设置为中优先级。
  - `priority:L`：设置为低优先级。
    - 示例：`priority:H`

- **截止日期（Due）**：
  - `due:2023-12-31`：设置任务的截止日期。
    - 示例：`due:2023-12-31`

- **计划日期（Scheduled）**：
  - `scheduled:2023-11-01`：设置任务的计划日期。
    - 示例：`scheduled:2023-11-01`

- **等待日期（Wait）**：
  - `wait:2023-10-15`：设置任务的等待日期。
    - 示例：`wait:2023-10-15`

- **直到日期（Until）**：
  - `until:2023-12-31`：设置任务的有效日期。
    - 示例：`until:2023-12-31`

- **标签（Tags）**：
  - `+tag`：添加一个标签。
  - `-tag`：移除一个标签。
    - 示例：`+urgent` 或 `-home`

- **依赖任务（Depends）**：
  - `depends:5`：设置任务依赖于任务 ID 为 5 的任务。
    - 示例：`depends:5`

- **注释（Annotations）**：
  - `annotate "注释内容"`：为任务添加注释。
    - 示例：`annotate "与客户电话沟通"`

- **描述（Description）**：
  - `description:"新描述"`：更改任务的描述。
    - 示例：`description:"购买有机牛奶"`

- **等待状态（Wait）**：
  - `wait:now`：设置任务为等待状态。
    - 示例：`wait:now`

### 批量修改

你可以对多个任务同时应用修改参数。例如：

```bash
task +home modify priority:H due:2023-12-31
```

这将把所有带有 `home` 标签的任务的优先级设置为高，并将截止日期设为 2023-12-31。

---

## 4. 杂项（Miscellaneous）

**杂项参数** 包含一些额外的选项或命令参数，用于控制命令的行为或提供附加信息。

### 常用杂项参数

- **信息（Info）**：
  - `info`：显示任务的详细信息。
    - 示例：`task 1 info`

- **导出（Export）**：
  - `export`：将任务导出为 JSON 格式，适用于备份或迁移。
    - 示例：`task export > tasks.json`

- **日志记录（Log）**：
  - `log`：记录已完成的任务。
    - 示例：`task 2 log "完成任务"`

- **帮助（Help）**：
  - `help`：显示 Taskwarrior 的帮助信息。
    - 示例：`task help`

- **配置（Config）**：
  - `config [设置]`：修改 Taskwarrior 的配置设置。
    - 示例：`task config editor vim`

- **同步（Synchronize）**：
  - `synchronize`：同步任务与其他实例（如 Taskserver）。
    - 示例：`task synchronize`

- **版本（Version）**：
  - `version`：显示 Taskwarrior 的版本信息。
    - 示例：`task version`

- **导入（Import）**：
  - `import [文件]`：从 JSON 文件导入任务。
    - 示例：`task import tasks.json`

- **导出为 JSON**：
  - `export`：将任务导出为 JSON 格式。
    - 示例：`task export > tasks.json`

- **撤销操作（Undo）**：
  - `undo`：撤销最近的更改。
    - 示例：`task undo`

### 其他杂项参数

- **执行外部命令（Execute）**：
  - `execute [命令]`：在任务上执行外部命令。
    - 示例：`task 4 execute echo "Task completed"`

- **日志（Log）**：
  - `log [描述]`：为已完成的任务添加日志描述。
    - 示例：`task 5 log "已发送电子邮件通知"`

- **显示诊断信息（Diagnostics）**：
  - `diagnostics`：显示 Taskwarrior 的诊断信息，便于故障排除。
    - 示例：`task diagnostics`

- **显示颜色支持（Colors）**：
  - `colors`：展示所有支持的颜色。
    - 示例：`task colors`

---

## 总结

通过理解 **Taskwarrior** 命令结构中的四个主要部分及其相关参数，你可以更高效地管理和操作任务。以下是对这四个部分的快速回顾：

1. **过滤器（Filter）**：用于筛选特定的任务，基于各种属性如状态、项目、标签等。
2. **命令（Command）**：指定对筛选出的任务执行的操作，如添加、修改、完成等。
3. **修改（Modifications）**：用于更改任务的属性或状态，通常与命令结合使用。
4. **杂项（Miscellaneous）**：包含额外的选项或命令参数，用于控制命令的行为或提供附加信息。

通过熟练掌握这些参数，你可以充分利用 **Taskwarrior** 的强大功能，实现高效的任务管理。如果你有任何进一步的问题或需要更多的示例，请随时提出！
