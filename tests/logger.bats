setup() {
  source "$(dirname "$BATS_TEST_DIRNAME")/logger.sh"
}

@test "默认 SILENT 级别不输出任何日志" {
  APP_LOG_LEVEL=SILENT
  run log_debug "debug"
  [ "$output" = "" ]
  run log_info "info"
  [ "$output" = "" ]
  run log_warn "warn"
  [ "$output" = "" ]
  run log_error "error"
  [ "$output" = "" ]
}

@test "DEBUG 级别输出所有日志到 stderr" {
  APP_LOG_LEVEL=DEBUG
  run log_debug "test debug"
  [[ "$output" =~ "test debug" ]]
}

@test "INFO 级别不输出 DEBUG" {
  APP_LOG_LEVEL=INFO
  run log_debug "should be silent"
  [ "$output" = "" ]
  run log_info "visible"
  [[ "$output" =~ "visible" ]]
}

@test "ERROR 级别只输出 ERROR" {
  APP_LOG_LEVEL=ERROR
  run log_info "hidden"
  [ "$output" = "" ]
  run log_warn "hidden"
  [ "$output" = "" ]
  run log_error "shown"
  [[ "$output" =~ "shown" ]]
}

@test "NO_COLOR 禁用颜色序列" {
  NO_COLOR=1
  run ui_header "Test" "message"
  [[ "$output" != *"\\033"* ]]
  [[ "$output" == "==> Test: message" ]]
}

@test "run_cmd 返回外部命令退出码" {
  run run_cmd "Test" "true"
  [ "$status" -eq 0 ]
  run run_cmd "Test" "false"
  [ "$status" -eq 1 ]
}

@test "run_cmd 捕获命令输出到 DEBUG 日志" {
  APP_LOG_LEVEL=DEBUG
  output=$(run_cmd "Test" "echo" "hello" 2>&1)
  [[ "$output" =~ "hello" ]]
}

@test "APP_LOG_FILE 写入文件而非 stderr" {
  local tmpfile=$(mktemp)
  APP_LOG_FILE="$tmpfile" APP_LOG_LEVEL=DEBUG
  log_info "file log test"
  [[ -s "$tmpfile" ]]
  grep -q "file log test" "$tmpfile"
  rm -f "$tmpfile"
}

@test "ui_header 正确处理带空格的参数" {
  run ui_header "My App" "start deploy"
  [[ "$output" == "==> My App: start deploy" ]]
}

@test "ui_error 同时输出到 stderr 和 log" {
  APP_LOG_LEVEL=ERROR
  run ui_error "something failed" 2>&1
  [[ "$output" == *"something failed"* ]]
}
