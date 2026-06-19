#!/usr/bin/env bash
# ==============================================================================
# 通用 Shell 日志库
# ==============================================================================

source "$(dirname "${BASH_SOURCE[0]}")/_colors.sh"

# -------------------- 1. 配置与初始化 --------------------
# 默认日志级别为 SILENT (DEBUG=0, INFO=1, WARN=2, ERROR=3, SILENT=4)
APP_LOG_LEVEL="${APP_LOG_LEVEL:-SILENT}"
APP_LOG_FILE="${APP_LOG_FILE:-}"

__log_level_to_num() {
  case "$1" in
    DEBUG|debug)   echo 0 ;;
    INFO|info)     echo 1 ;;
    WARN|warn)     echo 2 ;;
    ERROR|error)   echo 3 ;;
    SILENT|silent) echo 4 ;;
    *)             echo 1 ;;
  esac
}

# -------------------- 2. 核心底层日志机制 (面向开发者) --------------------
# _log <LEVEL_NUM> <LEVEL_STR> <MESSAGE>
_log() {
  local level_num=$1
  shift
  local level_str=$1
  shift
  local message="$*"

  # 每次调用时动态读取级别，支持运行时修改 APP_LOG_LEVEL
  local _current_level
  _current_level=$(__log_level_to_num "$APP_LOG_LEVEL")
  [[ $_current_level -gt $level_num ]] && return 0

  # 获取调用者的信息（类似堆栈追踪）
  local caller_file="${BASH_SOURCE[2]##*/}"
  local caller_line="${BASH_LINENO[1]}"
  local timestamp
  printf -v timestamp '%(%Y-%m-%d %H:%M:%S)T' -1

  # 格式化日志内容
  local log_line="[${timestamp}] ${level_str} -- ${caller_file}:${caller_line}: ${message}"

  # 输出目标判断
  if [[ -n "$APP_LOG_FILE" ]]; then
    local log_dir
    log_dir=$(dirname "$APP_LOG_FILE")
    if [[ ! -d "$log_dir" ]]; then
      echo "ERROR: Log directory '$log_dir' does not exist" >&2
      return 1
    fi
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
  echo -e "${C_BOLD}==> ${target}:${C_RESET} ${*:2}"
}

ui_info() {
  echo -e "    ℹ ${C_RESET}${*}"
}

ui_success() {
  echo -e "${C_GREEN}    ✔ ${C_RESET}${*}"
}

ui_warn() {
  echo -e "${C_YELLOW}    ⚠ ${C_RESET}${*}" >&2
}

ui_error() {
  echo -e "${C_RED}    ✖ ${C_RESET}${*}" >&2
  # UI 报错时，自动向日志系统追加详细信息（因为 UI 层通常没有细节）
  log_error "[UI] $*"
}

# -------------------- 6. 子进程拦截器 --------------------
# 拦截外部命令执行，分离用户输出和底层日志
# 用法: run_cmd "System" "ls" "-l" "/tmp"
run_cmd() {
  local context="$1"
  shift

  log_debug "Executing external command in [$context]: $*"

  local output
  local exit_code=0
  output=$("$@" 2>&1) || exit_code=$?

  log_debug "Command exit code: $exit_code"
  # shellcheck disable=SC2001
  log_debug "Command output:\n$(echo "$output" | sed 's/^/  /')"

  return $exit_code
}
