#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_sub (collation)'
  Include ./spec/support/run.sh
  # 相互排他を検証するため、3 つのフラグ定数をすべて読み込む。
  sxtest_run SX_STR_SUB_GLOB SX_STR_SUB_ICASE SX_STR_SUB_EQC SX_STR_SUB_CB -- ''
  sxtest_load ./build/modules/sx_str_sub.sh

  It 'GLOB と ICASE の同時指定は 64 を返すこと'
    When call sx_str_sub res: "Hello World" "hello" "earth" "" "$((SX_STR_SUB_GLOB | SX_STR_SUB_ICASE))"
    The status should be failure
  End

  It 'GLOB と EQC の同時指定は 64 を返すこと'
    When call sx_str_sub res: "Hello World" "hello" "earth" "" "$((SX_STR_SUB_GLOB | SX_STR_SUB_EQC))"
    The status should be failure
  End

  It 'ICASE と EQC の同時指定は 64 を返すこと'
    When call sx_str_sub res: "Hello World" "hello" "earth" "" "$((SX_STR_SUB_ICASE | SX_STR_SUB_EQC))"
    The status should be failure
  End

  It 'CB と ICASE を併用できること'
    cb_upper() {
        case "$2" in
            world) sxtest_run "$1" -- 'sx_var_set "$@"' "$1=WORLD" ;;
            *) sxtest_run "$1" -- 'sx_var_set "$@"' "$1=$2" ;;
        esac
    }
    When call sx_str_sub res: "hello world" "world" cb_upper "" "$((SX_STR_SUB_CB | SX_STR_SUB_ICASE))"
    The status should be success
    The variable res should equal "hello WORLD"
  End

  It 'CB と EQC を併用できること'
    cb_upper() {
        case "$2" in
            world) sxtest_run "$1" -- 'sx_var_set "$@"' "$1=WORLD" ;;
            *) sxtest_run "$1" -- 'sx_var_set "$@"' "$1=$2" ;;
        esac
    }
    When call sx_str_sub res: "hello world" "world" cb_upper "" "$((SX_STR_SUB_CB | SX_STR_SUB_EQC))"
    The status should be success
    The variable res should equal "hello WORLD"
  End
End
