# ==============================================================================
# 共享颜色检测模块
# source "$(dirname "${BASH_SOURCE[0]}")/_colors.sh"
# ==============================================================================

if { [[ -t 1 ]] || [[ -t 2 ]]; } && [[ -z "${NO_COLOR:-}" ]]; then
  C_RED='\033[0;31m'
  C_GREEN='\033[0;32m'
  C_YELLOW='\033[0;33m'
  C_BLUE='\033[0;34m'
  C_BOLD='\033[1m'
  C_RESET='\033[0m'
else
  # shellcheck disable=SC2034
  C_RED='' C_GREEN='' C_YELLOW='' C_BLUE='' C_BOLD='' C_RESET=''
fi
