#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_trim'
  Include ./sx.sh

  It '前後の空白を削除すること (デフォルト)'
    sx_str_trim res "  hello  "
    The variable res should equal "hello"
  End

  It '前後の指定された文字セットを削除すること'
    sx_str_trim res "000123000" "0"
    The variable res should equal "123"
  End

  It '文字セットに ] が含まれる場合でも正しく動作すること'
    sx_str_trim res "]]]hello]]]" "]"
    The variable res should equal "hello"
  End

  It '文字セットに - が含まれる場合でも正しく動作すること'
    sx_str_trim res "---hello---" "-"
    The variable res should equal "hello"
  End

  It 'メタ文字が混在する文字セットを正しく扱うこと (], -, *, ?, !, [)'
    sx_str_trim res "]-*?!hello]-*?!" "*-?![]"
    The variable res should equal "hello"
  End

  It '空文字列に対して空文字列を返すこと'
    sx_str_trim res ""
    The variable res should equal ""
  End

  It '文字列全体が文字セットに含まれる場合は空文字列を返すこと'
    sx_str_trim res "   "
    The variable res should equal ""
  End

  It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
    readonly ro_res_trim="fixed"
    When call sx_str_trim ro_res_trim "  hello  "
    The status should equal 77
  End

  It 'SX_CFG_SKIP_CHK=1 の時に高速モードで動作すること'
    SX_CFG_SKIP_CHK=1 sx_str_trim res "  hello  "
    The variable res should equal "hello"
  End
End
