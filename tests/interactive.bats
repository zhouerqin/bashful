setup() {
  source "$(dirname "$BATS_TEST_DIRNAME")/interactive.sh"
}

@test "ui_prompt 非 TTY 时返回默认值" {
  run ui_prompt "Enter name" "张三" < /dev/null
  [ "$output" = "张三" ]
  [ "$status" -eq 0 ]
}

@test "ui_prompt 非 TTY 无默认值时返回空" {
  run ui_prompt "Enter name" < /dev/null
  [ "$output" = "" ]
  [ "$status" -eq 0 ]
}

@test "ui_prompt_secret 非 TTY 时返回空" {
  run ui_prompt_secret "Enter pass" < /dev/null
  [ "$output" = "" ]
  [ "$status" -eq 0 ]
}

@test "ui_confirm 非 TTY 默认 y 返回 0" {
  run ui_confirm "Continue?" "y" < /dev/null
  [ "$status" -eq 0 ]
}

@test "ui_confirm 非 TTY 默认 n 返回 1" {
  run ui_confirm "Continue?" "n" < /dev/null
  [ "$status" -eq 1 ]
}

@test "ui_confirm 默认值校验拒绝非法值" {
  run ui_confirm "Continue?" "x" < /dev/null
  [[ "$output" =~ "忽略" ]]
}
