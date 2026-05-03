#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_len'
  Include ./sx.sh

  It '引数の個数を正しくカウントすること (3個)'
    When call sx_arg_len res "v1" "v2" "v3"
    The status should be success
    The variable res should equal 3
  End

  It '引数の個数を正しくカウントすること (0個)'
    When call sx_arg_len res
    The status should be success
    The variable res should equal 0
  End

  It '引数の個数を正しくカウントすること (1個)'
    When call sx_arg_len res "only one"
    The status should be success
    The variable res should equal 1
  End

  It '空文字列の引数も個数に含めること'
    When call sx_arg_len res "" ""
    The status should be success
    The variable res should equal 2
  End

  It '結果変数が読み取り専用の場合に EX_NOPERM を返すこと'
    readonly ro_res_len=0
    When call sx_arg_len ro_res_len "a" "b"
    The status should equal 77
  End

  It '結果変数が無効な名前の場合に EX_USAGE を返すこと'
    When call sx_arg_len "1invalid" "a"
    The status should equal 64
  End

  Describe 'SX_CFG_SKIP_CHK=1'
    It 'チェックをスキップして個数をカウントすること'
      SX_CFG_SKIP_CHK=1
      When call sx_arg_len res "a" "b"
      The status should be success
      The variable res should equal 2
    End
  End

  Describe '__sx_arg_len'
    It '内部関数が正しくカウントすること'
      When call __sx_arg_len res "a" "b" "c" "d"
      The status should be success
      The variable res should equal 4
    End
  End
End
