#!/bin/bash

#!/usr/bin/env bash
# ==============================================================================
# 通用 Shell 日志库
# ==============================================================================

# -------------------- 1. 配置与初始化 --------------------
# 默认日志级别为 SILENT (DEBUG=0, INFO=1, WARN=2, ERROR=3, SILENT=4)
APP_LOG_LEVEL="${APP_LOG_LEVEL:-SILENT}"
APP_LOG_FILE="${APP_LOG_FILE:-}"

# 将字符串级别转换为数字
__log_level_to_num() {
  case "${1^^}" in
    DEBUG) echo 0 ;;
    INFO) echo 1 ;;
    WARN) echo 2 ;;
    ERROR) echo 3 ;;
    SILENT) echo 4 ;;
    *) echo 1 ;;
  esac
}

# 当前级别数字
_CURRENT_LOG_LEVEL=$(__log_level_to_num "$APP_LOG_LEVEL")

# -------------------- 2. 颜色与格式定义 --------------------
# 检测是否支持颜色，或遵守 NO_COLOR 标准
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  C_RED='\033[0;31m'
  C_GREEN='\033[0;32m'
  C_YELLOW='\033[0;33m'
  C_BLUE='\033[0;34m'
  C_BOLD='\033[1m'
  C_RESET='\033[0m'
else
  C_RED='' C_GREEN='' C_YELLOW='' C_BLUE='' C_BOLD='' C_RESET=''
fi

# -------------------- 3. 核心底层日志机制 (面向开发者) --------------------
# _log <LEVEL_NUM> <LEVEL_STR> <MESSAGE>
_log() {
  local level_num=$1
  shift
  local level_str=$1
  shift
  local message="$@"

  # 每次调用时动态读取级别，支持运行时修改 APP_LOG_LEVEL
  local _current_level=$(__log_level_to_num "$APP_LOG_LEVEL")
  [[ $_current_level -gt $level_num ]] && return 0

  # 获取调用者的信息（类似堆栈追踪）
  local caller_file=$(basename "${BASH_SOURCE[2]}")
  local caller_line="${BASH_LINENO[1]}"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  # 格式化日志内容
  local log_line="[${timestamp}] ${level_str} -- ${caller_file}:${caller_line}: ${message}"

  # 输出目标判断
  if [[ -n "$APP_LOG_FILE" ]]; then
    echo -e "$log_line" >>"$APP_LOG_FILE"
  else
    # 默认输出到标准错误 (STDERR)，避免污染标准输出 (STDOUT) 的管道数据
    echo -e "$log_line" >&2
  fi
}

# -------------------- 4. 公开日志 API (供业务脚本调用) --------------------
log_debug() { _log 0 "DEBUG" "$@"; }
log_info() { _log 1 "INFO" "$@"; }
log_warn() { _log 2 "WARN" "$@"; }
log_error() { _log 3 "ERROR" "$@"; }

# -------------------- 5. UI 层 (面向用户，模仿 ==> 语法) --------------------
# 注意：UI 层默认不写日志，保持用户界面干净。
# 如果需要同时记录日志，业务层应自行调用 log_info。

ui_header() {
  local target="${1:-default}"
  echo -e "${C_BOLD}==> ${target}:${C_RESET} ${@:2}"
}

ui_info() {
  echo -e "    ℹ ${C_RESET}${@}"
}

ui_success() {
  echo -e "${C_GREEN}    ✔ ${C_RESET}${@}"
}

ui_warn() {
  echo -e "${C_YELLOW}    ⚠ ${C_RESET}${@}" >&2
}

ui_error() {
  echo -e "${C_RED}    ✖ ${C_RESET}${@}" >&2
  # UI 报错时，自动向日志系统追加详细信息（因为 UI 层通常没有细节）
  log_error "[UI] $@"
}

# -------------------- 6. 子进程拦截器 --------------------
# 拦截外部命令执行，分离用户输出和底层日志
# 用法: run_cmd "System" "ls" "-l" "/tmp"
run_cmd() {
  local context="$1"
  shift
  local cmd="$@"

  # 1. 记录即将执行的命令到开发者日志
  log_debug "Executing external command in [$context]: $cmd"

  # 2. 执行命令，同时捕获 STDOUT 和 STDERR
  local output
  local exit_code
  # 使用 eval 以支持带管道或重定向的复杂命令字符串
  output=$(eval "$cmd" 2>&1)
  exit_code=$?

  # 3. 将完整的命令输出和退出码写入开发者日志
  log_debug "Command exit code: $exit_code"
  log_debug "Command output:\n$(echo "$output" | sed 's/^/  /')"

  # 4. 返回退出码供业务逻辑判断
  return $exit_code
}
