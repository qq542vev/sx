#!/bin/sh

eval "$(shellspec - -c) exit 1"

Describe 'sx_arg_range'
  Include ./sx.sh

  It '0からN-1までの参照を生成すること (Python方式: range(stop))'
    When call sx_arg_range result 3
    The variable result should eq '"${0}" "${1}" "${2}"'
    The status should be success
  End

  It '開始と終了(exclusive)を指定して参照を生成すること (Python方式: range(start, stop))'
    When call sx_arg_range result 1 4
    The variable result should eq '"${1}" "${2}" "${3}"'
    The status should be success
  End

  It '開始、終了(exclusive)、増分を指定して参照を生成すること (Python方式: range(start, stop, step))'
    When call sx_arg_range result 1 5 2
    The variable result should eq '"${1}" "${3}"'
    The status should be success
  End

  It '空の範囲の場合は空文字列を返すこと'
    When call sx_arg_range result 0
    The variable result should eq ''
    The status should be success
  End

  It '負の数値が指定された場合はエラーを返すこと'
    When call sx_arg_range result -1
    The status should eq 64
  End

  It '非数値が指定された場合はエラーを返すこと'
    When call sx_arg_range result "abc"
    The status should eq 64
  End

  It '宛先変数が読み取り専用の場合はエラーを返すこと'
    readonly ro_var=fixed
    When call sx_arg_range ro_var 3
    The status should eq 77
  End

  It '開始(start)に負の数値が指定された場合はエラーを返すこと'
    When call sx_arg_range result -1 5
    The status should eq 64
  End

  It '増分(step)に負の数値が指定された場合はエラーを返すこと'
    When call sx_arg_range result 1 5 -1
    The status should eq 64
  End

  It '増分(step)に0が指定された場合はエラーを返すこと'
    When call sx_arg_range result 1 5 0
    The status should eq 64
  End
End
