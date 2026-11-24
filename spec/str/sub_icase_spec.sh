#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_sub (icase)'
  Include ./spec/support/run.sh
  # 検証に使うフラグ定数は、対象モジュールの依存とは別に準備する。
  sxtest_run SX_STR_SUB_ICASE -- ''
  sxtest_load ./build/modules/sx_str_sub.sh

  It '英字の大小を区別せず前方から置換すること'
    When call sx_str_sub res: "Hello World" "hello" "earth" "${SX_NUM_I32_MAX}" "${SX_STR_SUB_ICASE}"
    The variable res should equal "earth World"
  End

  It '英字の大小を区別せず逆向きで置換すること'
    When call sx_str_sub res: "Hello World Hello" "hello" "earth" -1 "${SX_STR_SUB_ICASE}"
    The variable res should equal "Hello World earth"
  End

  It 'パターンの大小が異なっても一致すること'
    When call sx_str_sub res: "Hello World" "HELLO" "earth" "${SX_NUM_I32_MAX}" "${SX_STR_SUB_ICASE}"
    The variable res should equal "earth World"
  End

  It '存在しないパターンは置換しないこと'
    When call sx_str_sub res: "Hello World" "foo" "bar" "${SX_NUM_I32_MAX}" "${SX_STR_SUB_ICASE}"
    The variable res should equal "Hello World"
  End

  It '前方制限1で置換すること'
    When call sx_str_sub res: "Hello World Hello" "hello" "earth" 1 "${SX_STR_SUB_ICASE}"
    The variable res should equal "earth World Hello"
  End

  It 'デフォルト（フラグなし）では大小を区別すること'
    When call sx_str_sub res: "Hello World" "hello" "earth"
    The variable res should equal "Hello World"
  End

  It '空パターンは icase の影響を受けないこと'
    When call sx_str_sub res: "abc" "" "X" "${SX_NUM_I32_MAX}" "${SX_STR_SUB_ICASE}"
    The variable res should equal "XaXbXcX"
  End
End
