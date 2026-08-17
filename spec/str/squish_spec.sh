#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_str_squish'
  Include ./sx.sh

  It 'デフォルト（空白文字）で normalize-space 相当の動作をすること'
    sx_str_squish res "  A	B
C  "
    The variable res should equal "A B C"
  End

  It '指定された文字セットと区切り文字で正しく動作すること'
    sx_str_squish res "//a//b///c//" "/" "/"
    The variable res should equal "a/b/c"
  End

  It '区切り文字を指定できること'
    sx_str_squish res "a   b   c" "${SX_STR_SPACE}" ","
    The variable res should equal "a,b,c"
  End

  It '空文字列に対して空文字列を返すこと'
    sx_str_squish res ""
    The variable res should equal ""
  End

  It '文字列全体が文字セットに含まれる場合は空文字列を返すこと'
    sx_str_squish res "   "
    The variable res should equal ""
  End

  It '文字セットが空の場合は元の文字列をそのまま返すこと'
    sx_str_squish res " hello world " ""
    The variable res should equal " hello world "
  End

  It '連続する文字セットが単一のセパレータに置換されること'
    sx_str_squish res "a    b   c  d" " "
    The variable res should equal "a b c d"
  End

  It '文字セットに ] が含まれる場合でも正しく動作すること'
    sx_str_squish res "]]]hello]]]world]]]" "]" "]"
    The variable res should equal "hello]world"
  End

  It '文字セットに - が含まれる場合でも正しく動作すること'
    sx_str_squish res "---hello---world---" "-" "-"
    The variable res should equal "hello-world"
  End

  It 'メタ文字が混在する文字セットを正しく扱うこと'
    sx_str_squish res "*-?!a*-?!b*-?!c*-?!?" "*-?![]" "-"
    The variable res should equal "a-b-c"
  End

  It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
    readonly ro_res_squish="fixed"
    When call sx_str_squish ro_res_squish "  hello  "
    The status should equal 77
  End

  It 'SX_CFG_SKIP_CHK=1 の時に高速モードで動作すること'
    SX_CFG_SKIP_CHK=1 sx_str_squish res "  hello  world  "
    The variable res should equal "hello world"
  End
End
