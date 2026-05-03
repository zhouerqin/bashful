# AGENTS.md

## Overview
Single-file shell logging library (`logger.sh`) providing logging and UI functions.

## Usage
Source the library and call functions:
```bash
#!/usr/bin/env bash
source logger.sh

APP_LOG_LEVEL=DEBUG
APP_LOG_FILE=  # optional: set to write to file instead of stderr

log_debug "debug message"
log_info "info message"
log_warn "warning"
log_error "error"
```

## Environment
- `APP_LOG_LEVEL`: DEBUG (0), INFO (1), WARN (2), ERROR (3), SILENT (4) — default: SILENT
- `APP_LOG_FILE`: optional log file path (defaults to stderr)
- `NO_COLOR`: if set, disables color output

## UI Functions
- `ui_header "target"` — bold header with ==>
- `ui_info` / `ui_success` / `ui_warn` / `ui_error` — formatted messages

## Examples
```bash
bash examples.sh  # 运行示例脚本
```

## Commands
```bash
bash logger.sh  # run self-test (checks syntax)
```