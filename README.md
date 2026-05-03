# logger.sh

一个专为现代 Shell CLI 工具设计的轻量级日志库。它基于**"UI 与 Log 彻底分离"**和**"默认绝对静默"**的核心架构，确保普通用户享受干净优雅的交互体验，而开发者在排查问题时可以通过环境变量瞬间获取最深层的执行细节。

## ✨ 核心特性

- **默认静默**：底层日志默认级别为 `SILENT`，不产生任何冗余输出，把终端完全留给 UI。
- **UI/Log 分离**：面向用户的格式化输出（UI）与面向开发者的结构化日志严格解耦。
- **子进程拦截**：内置 `run_cmd` 函数，自动记录外部命令的执行参数、退出码和完整输出。
- **零依赖**：纯 Bash 实现，无任何第三方依赖。
- **标准兼容**：自动检测终端颜色支持，完美遵守 [`NO_COLOR`](https://no-color.org/) 标准。
- **安全管道**：严格区分 STDOUT（用于数据返回）和 STDERR（用于 UI 和日志），不影响 `$()` 捕获。

## 🚀 快速上手

将 `logger.sh` 放入您的项目目录，并在脚本中引入：

```bash
#!/usr/bin/env bash
source "./logger.sh"

ui_header "MyApp" "开始执行任务"
ui_success "一切正常"
```

## 🧠 核心设计哲学

这个库建立了一套现代命令行工具的**心智模型**——它并不只是把 `echo` 封装成带颜色的函数。

---

### 1. 默认静默是最高级的克制

传统的日志库默认是 `INFO` 或 `DEBUG`，导致普通用户的屏幕被无关紧要的内部状态淹没。本库默认为 `SILENT`，这意味着：**底层日志是开发者按需拉取的上下文，而不是工具向用户强行推送的垃圾信息**。没有设置环境变量，就一个字都不准漏。

---

### 2. CLI 设计也是 UI 设计

文字用于传递精确信息，符号（`==>`, `✔`, `⚠`, `✖`）用于传递**情绪和状态**。当日志快速滚动时，用户不需要逐字阅读，通过边缘视觉就能瞬间判断出阶段边界和成败结果。

---

### 3. 动作入日志，结果不上屏

以执行外部命令为例（`run_cmd`）：满屏的原始输出、退出码等繁琐过程属于**"动作"**，它们只能存在于底层日志中；而最终提取出的"配置成功"或"连接失败"属于**"结果"**，才配展示在 UI 层。绝对不能把底层的执行过程直接泼给用户。

---

### 4. 异常处理的双向机制

当系统崩溃时，绝不能指望"降低日志级别"来让用户看到报错。正确的做法是**双管齐下**：

- 调用 `ui_error` → 强制给用户看人话总结（产品功能）
- 调用 `log_error` → 记录堆栈细节（开发功能）

---

### 5. 保持单向事件的纯粹性

日志库严格只处理**"已经发生或正在发生的单向事实"**。诸如 `Y/N` 确认等交互输入属于"双向阻塞 I/O"，不属于日志的范畴。不越界去写交互函数，才能保证库在无终端环境（如 CI/CD、Cron 后台）下的绝对通用安全。

---

## 📖 API 参考

### UI 层（面向用户）

| 函数 | 说明 |
|------|------|
| `ui_header <target> <message>` | 打印阶段标题（带有 `==>` 前缀） |
| `ui_info <message>` | 打印普通信息（带有 `ℹ` 前缀） |
| `ui_success <message>` | 打印成功状态（带有 `✔` 前缀） |
| `ui_warn <message>` | 打印警告状态（带有 `⚠` 前缀，输出到 STDERR） |
| `ui_error <message>` | 打印错误状态（带有 `✖` 前缀，输出到 STDERR，并自动向 Log 层同步记录） |

### Log 层（面向开发者）

| 函数 | 说明 |
|------|------|
| `log_debug <message>` | 极度详尽的底层细节（如变量值、命令执行过程） |
| `log_info <message>` | 有意义的中性业务流转状态 |
| `log_warn <message>` | 潜在的非预期状态，但流程可继续 |
| `log_error <message>` | 导致流程中断的错误细节 |

### 工具函数

| 函数 | 说明 |
|------|------|
| `run_cmd <context> <command>` | 执行外部命令的拦截器。自动将命令、退出码、输出写入 `DEBUG` 日志，并返回命令的退出码 |

## ⚙️ 配置（环境变量）

由于 CLI 工具的配置文件通常需要跟随项目共享，本库**不支持通过配置文件设置日志级别**，一律通过环境变量按需开启：

---

### `APP_LOG_LEVEL`

控制 Log 层的输出门槛。默认值为 `SILENT`。

可选值（由低到高）：`DEBUG` → `INFO` → `WARN` → `ERROR` → `SILENT`

```bash
# 普通用户执行（什么都不用加）
./my_script.sh

# 开发者看业务流转
APP_LOG_LEVEL=INFO ./my_script.sh

# 开发者深度排查（看子过程和底层细节）
APP_LOG_LEVEL=DEBUG ./my_script.sh
```

---

### `APP_LOG_FILE`

指定日志输出文件。开启后，Log 层的内容将不再打印到终端，而是追加写入该文件。UI 层不受影响。

```bash
# 收集日志用于提 Issue
APP_LOG_LEVEL=DEBUG APP_LOG_FILE=debug.log ./my_script.sh
```

---

### `NO_COLOR`

设置此变量将禁用所有颜色和 Unicode 符号输出，适合在 CI/CD 流水线或纯文本重定向时使用。

```bash
NO_COLOR=1 ./my_script.sh > output.txt
```

---

## 💡 高级示例

以下示例展示了如何在业务中组合使用 API：

```bash
#!/usr/bin/env bash
set -e
source "./logger.sh"

CONFIG_FILE="/etc/my_app/conf.yaml"

# 1. 检查前置条件（缺少配置文件时直接报错退出）
[[ ! -f "$CONFIG_FILE" ]] && { ui_error "缺少配置文件 $CONFIG_FILE"; exit 1; }

ui_header "Server" "初始化环境"

# 2. 底层细节（默认用户看不到，DEBUG 模式下可见）
log_info "开始解析配置..."
log_debug "目标文件: $CONFIG_FILE"

# 3. 执行外部命令（使用拦截器，不用手动记日志）
if run_cmd "Sysctl" "sysctl -w net.core.somaxconn=65535"; then
    ui_success "内核参数配置完成"
else
    # 异常处理：UI 给结论，Log 里有详情（如果开了 DEBUG 的话）
    ui_error "内核参数设置失败，请检查权限"
    exit 1
fi

ui_header "Server" "启动完成"
```

---

## License

MIT