#!/usr/bin/env bash
# ==============================================================================
# logger.sh 使用示例 - 展示核心设计哲学
# ==============================================================================

set -euo pipefail

source logger.sh
source interactive.sh

echo "========================================"
echo "【演示 1】默认静默：普通用户看到什么？"
echo "========================================"
# 不设置任何环境变量，默认 SILENT
ui_header "Deploy" "开始部署应用"
ui_info  "正在加载配置..."
ui_success "配置加载完成"
ui_info  "正在启动服务..."
ui_success "服务启动成功"
echo ""
echo "你看到的就是普通用户看到的一切 —— 干净简洁。"
echo ""

echo "========================================"
echo "【演示 2】开发者按需开启日志"
echo "========================================"
echo "# 设置 APP_LOG_LEVEL=DEBUG 后："
export APP_LOG_LEVEL=DEBUG
log_info "开始解析配置文件 /etc/app.conf"
log_debug "文件内容: {port: 8080, mode: production}"
log_debug "环境变量: $(env | grep -E '^(PATH|HOME)=' | head -1)"
echo ""

echo "========================================"
echo "【演示 3】UI 与 Log 分离的精妙之处"
echo "========================================"
echo "# run_cmd 执行外部命令时："
echo "# - 用户只看到 ui_success/ ui_error 的结果"
echo "# - 开发者能看到 log_debug 中的完整过程"
echo ""
echo "【用户看到的】"
ui_header "System" "检查网络连接"
if run_cmd "Ping" "ping -c 1 -W 1 127.0.0.1" >/dev/null 2>&1; then
    ui_success "网络正常"
else
    ui_error "连接失败"
fi
echo ""
echo "【开发者看到的】（设置 APP_LOG_LEVEL=DEBUG）"
log_debug "Executing external command in [Ping]: ping -c 1 -W 1 127.0.0.1"
log_debug "Command exit code: 0"
log_debug "Command output:"
log_debug "  PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data."
log_debug "  64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.029 ms"
log_debug ""
log_debug "  --- 127.0.0.1 ping statistics ---"
log_debug "  1 packets transmitted, 1 received, 0% packet loss, time 0ms"
echo ""

echo "========================================"
echo "【演示 4】异常处理的双向机制"
echo "========================================"
echo "# ui_error 给用户看人话，log_error 给开发者看细节"
echo ""
run_cmd "Config" "test" "-f" "/nonexistent.conf" 2>/dev/null || true
ui_error "配置文件不存在"
log_error "Failed to open /nonexistent.conf: No such file or directory"
log_error "Stacktrace:"
log_error "  at parse_config (/src/main.go:42)"
log_error "  at main (/src/main.go:15)"
echo ""

echo "========================================"
echo "【演示 5】写入日志文件"
echo "========================================"
export APP_LOG_FILE="/tmp/demo.log"
log_info "这条写入文件"
log_debug "调试信息也写入文件"
echo "(已写入 $APP_LOG_FILE)"
echo ""
export APP_LOG_FILE=
echo ""

echo "========================================"
echo "【演示 6】用户交互输入"
echo "========================================"
echo "# ui_prompt 提示用户输入，支持默认值"
echo ""
ui_header "Setup" "交互式配置"

# 带默认值的输入
NAME=$(ui_prompt "请输入您的名字" "张三")
echo "您输入的名字: $NAME"

# 不带默认值的输入
EMAIL=$(ui_prompt "请输入邮箱")
echo "您输入的邮箱: $EMAIL"

# 确认提示
if ui_confirm "是否保存配置？"; then
    ui_success "配置已保存"
else
    ui_warn "配置未保存"
fi

echo ""

echo "========================================"
echo "【全部示例执行完毕】"
echo "========================================"