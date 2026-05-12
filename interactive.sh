#!/usr/bin/env bash
# ==============================================================================
# 交互式输入工具库
# ==============================================================================

# 检测是否支持颜色
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

# ------------------------------------------------------------------------------
# 显示提示并读取用户输入，支持默认值
# 参数:
#   $1 - 提示文本
#   $2 - 默认值（可选）
# 返回:
#   用户输入的值，若无输入则返回默认值
# ------------------------------------------------------------------------------
ui_prompt() {
  local prompt="$1"
  local default="${2:-}"
  local input
  
  if [[ -n "$default" ]]; then
    read -p "$(echo -e "    ? ${C_BLUE}${prompt}${C_RESET} [${C_YELLOW}${default}${C_RESET}]: ")" input
  else
    read -p "$(echo -e "    ? ${C_BLUE}${prompt}${C_RESET}: ")" input
  fi
  
  echo "${input:-$default}"
}

# ------------------------------------------------------------------------------
# 显示提示并读取用户输入（隐藏输入，用于密码等敏感信息）
# 参数:
#   $1 - 提示文本
# 返回:
#   用户输入的值
# ------------------------------------------------------------------------------
ui_prompt_secret() {
  local prompt="$1"
  local input
  
  read -sp "$(echo -e "    ? ${C_BLUE}${prompt}${C_RESET}: ")" input
  echo ""
  echo "$input"
}

# ------------------------------------------------------------------------------
# 显示确认提示（是/否）
# 参数:
#   $1 - 提示文本
#   $2 - 默认值（可选，y/n），未设置则强制要求用户输入
# 返回:
#   0 表示确认，1 表示取消
# ------------------------------------------------------------------------------
ui_confirm() {
  local prompt="$1"
  local default="$2"
  local input
  
  if [[ -n "$default" && "$default" != "y" && "$default" != "n" ]]; then
    echo -e "${C_YELLOW}    ⚠ ui_confirm: 默认值必须是 'y' 或 'n'，当前值 '$default' 将被忽略${C_RESET}" >&2
    default=""
  fi
  
  local default_display
  if [[ "$default" == "y" ]]; then
    default_display="[Y/n]"
  elif [[ "$default" == "n" ]]; then
    default_display="[y/N]"
  else
    default_display="[y/n]"
  fi
  
  while true; do
    read -n 1 -p "$(echo -e "    ? ${C_BLUE}${prompt}${C_RESET} ${C_YELLOW}${default_display}${C_RESET}")" input
    
    if [[ "$input" == $'\n' ]]; then
      if [[ -n "$default" ]]; then
        input="$default"
      else
        echo ""
        continue
      fi
    fi
    
    if [[ "$input" == "y" ]]; then
      return 0
    elif [[ "$input" == "n" ]]; then
      return 1
    fi
  done
}
